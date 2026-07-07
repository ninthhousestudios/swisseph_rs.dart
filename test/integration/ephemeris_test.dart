import 'package:swisseph_rs/swisseph_rs.dart';
import 'package:test/test.dart';

void main() {
  group('Ephemeris lifecycle', () {
    test('constructs with Moshier (no files needed)', () {
      final eph = Ephemeris(const EphemerisConfig());
      addTearDown(eph.close);
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

    test('bad ephePath throws FileNotFoundException', () {
      expect(
        () => Ephemeris(
          const EphemerisConfig(
            ephemerisSource: EphemerisSource.swiss,
            ephePath: '/nonexistent/path',
          ),
        ),
        throwsA(isA<FileNotFoundException>()),
      );
    });
  });

  group('engineVersion', () {
    test('returns non-empty string', () {
      expect(engineVersion, isNotEmpty);
    });
  });

  group('calcUt Sun longitude', () {
    late Ephemeris eph;

    setUp(() {
      eph = Ephemeris(const EphemerisConfig());
    });

    tearDown(() => eph.close());

    test('Moshier: Sun at J2000 epoch', () {
      final result = eph.calcUt(
        const JdUt1(2451545.0),
        Body.sun,
        CalcFlags.speed,
      );
      // Sun longitude at J2000.0 (2000-01-01 12:00 UT) ~ 280.36°
      // Coarse sanity check first; exact oracle comparison follows.
      expect(result.longitude, closeTo(280.36, 0.1));
      expect(result.longitudeSpeed, closeTo(1.0, 0.2));
      expect(result.distance, closeTo(0.983, 0.01));
    });

    test('Moshier: Sun returns speed components when SPEED flag set', () {
      final result = eph.calcUt(
        const JdUt1(2451545.0),
        Body.sun,
        CalcFlags.speed,
      );
      expect(result.longitudeSpeed, isNot(0.0));
    });

    test('Moshier: Moon returns reasonable longitude', () {
      final result = eph.calcUt(
        const JdUt1(2451545.0),
        Body.moon,
        CalcFlags.speed,
      );
      expect(result.longitude, greaterThanOrEqualTo(0));
      expect(result.longitude, lessThan(360));
      expect(result.longitudeSpeed, closeTo(13.0, 2.0));
    });
  });
}
