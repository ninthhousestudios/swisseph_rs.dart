@TestOn('browser')
library;

import 'package:swisseph_rs/swisseph_rs.dart';
import 'package:test/test.dart';

void main() {
  setUpAll(() async {
    await initializeWasm();
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
      expect(r.cusps.length, 12);
      for (final cusp in r.cusps) {
        expect(cusp, greaterThanOrEqualTo(0));
        expect(cusp, lessThan(360));
      }
    });

    test('eclipse search', () {
      final r = eph.solEclipseWhenGlob(const JdUt1(2451545.0), CalcFlags.speed);
      expect(r.maximum.value, greaterThan(2451545.0));
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
  });
}
