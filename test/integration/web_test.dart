// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

@TestOn('browser')
library;

import 'dart:js_interop';
import 'dart:typed_data';

import 'package:swisseph_rs/swisseph_rs.dart';
import 'package:test/test.dart';

extension type _Response(JSObject _) implements JSObject {
  external JSPromise<JSArrayBuffer> arrayBuffer();
  external bool get ok;
}

@JS('fetch')
external JSPromise<_Response> _jsFetch(JSString url);

Future<Uint8List> _fetchBytes(String url) async {
  final response = await _jsFetch(url.toJS).toDart;
  if (!response.ok) throw StateError('Fetch failed: $url');
  final buffer = await response.arrayBuffer().toDart;
  return buffer.toDart.asUint8List();
}

void main() {
  setUpAll(() async {
    await initializeWasm('../../wasm/swisseph_ffi');
  });

  group('Moshier (no files)', () {
    late Ephemeris eph;

    setUp(() {
      eph = Ephemeris(const EphemerisConfig());
    });
    tearDown(() => eph.close());

    test('Sun at J2000 — positional agreement', () {
      final r = eph.calcUt(const JdUt1(2451545.0), Body.sun, CalcFlags.speed);
      expect(r.longitude, closeTo(280.36891967534336, 1e-9));
      expect(r.longitudeSpeed, closeTo(1.0194320944233946, 1e-9));
      expect(r.distance, closeTo(0.9833276448202026, 1e-12));
    });

    test('Moon returns reasonable longitude', () {
      final r = eph.calcUt(const JdUt1(2451545.0), Body.moon, CalcFlags.speed);
      expect(r.longitude, greaterThanOrEqualTo(0));
      expect(r.longitude, lessThan(360));
      expect(r.longitudeSpeed, closeTo(13.0, 2.0));
    });

    test('houses Placidus', () {
      final r = eph.houses(
        const JdUt1(2451545.0),
        47.37,
        8.55,
        HouseSystem.placidus,
      );
      expect(r.cusps.length, 13);
      for (var i = 1; i < r.cusps.length; i++) {
        expect(r.cusps[i], greaterThanOrEqualTo(0));
        expect(r.cusps[i], lessThan(360));
      }
    });

    test('eclipse search', () {
      final r = eph.solEclipseWhenGlob(const JdUt1(2451545.0), CalcFlags.speed);
      expect(r.timeMaximum, greaterThan(2451545.0));
    });
  });

  group('lifecycle', () {
    test('constructs with Moshier', () {
      final eph = Ephemeris(const EphemerisConfig());
      eph.close();
    });

    test('close() is idempotent', () {
      final eph = Ephemeris(const EphemerisConfig());
      eph.close();
      eph.close();
    });

    test('use-after-close throws StateError', () {
      final eph = Ephemeris(const EphemerisConfig());
      eph.close();
      expect(
        () => eph.calcUt(const JdUt1(2451545.0), Body.sun, CalcFlags.speed),
        throwsStateError,
      );
    });
  });

  group('native-only surface', () {
    test('share() throws UnsupportedError', () {
      final eph = Ephemeris(const EphemerisConfig());
      addTearDown(eph.close);
      expect(() => eph.share(), throwsUnsupportedError);
    });
  });

  group('Swiss-file path (MEMFS)', () {
    test('missing staged file throws FileNotFoundException', () {
      expect(
        () => Ephemeris(
          const EphemerisConfig(
            ephemerisSource: EphemerisSource.swiss,
            ephePath: '/nonexistent',
          ),
        ),
        throwsA(isA<FileNotFoundException>()),
      );
    });

    test('loadEpheFile → construct → calc', () async {
      late final Uint8List bytes;
      try {
        bytes = await _fetchBytes('../../ephe/sepl_18.se1');
      } on StateError {
        markTestSkipped('sepl_18.se1 not served (ephe/ symlink outside root)');
        return;
      }
      loadEpheFile('sepl_18.se1', bytes);
      final eph = Ephemeris(
        const EphemerisConfig(
          ephemerisSource: EphemerisSource.swiss,
          ephePath: '/ephe',
        ),
      );
      addTearDown(eph.close);
      final r = eph.calcUt(const JdUt1(2451545.0), Body.sun, CalcFlags.speed);
      expect(r.longitude, closeTo(280.369, 0.001));
      expect(r.distance, closeTo(0.983, 0.001));
    });

    test('loadEpheFile rejects path traversal', () {
      expect(
        () => loadEpheFile('../etc/passwd', Uint8List(0)),
        throwsArgumentError,
      );
      expect(
        () => loadEpheFile('foo/bar.se1', Uint8List(0)),
        throwsArgumentError,
      );
      expect(() => loadEpheFile('..', Uint8List(0)), throwsArgumentError);
      expect(() => loadEpheFile('', Uint8List(0)), throwsArgumentError);
    });
  });
}
