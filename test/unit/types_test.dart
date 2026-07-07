import 'package:swisseph_rs/swisseph_rs.dart';
import 'package:test/test.dart';

void main() {
  group('Body', () {
    test('planet raw values', () {
      expect(Body.sun.rawValue, 0);
      expect(Body.moon.rawValue, 1);
      expect(Body.pluto.rawValue, 9);
    });

    test('asteroid raw value offset', () {
      const eros = Body.asteroid(AsteroidId(433));
      expect(eros.rawValue, 10433);
    });
  });

  group('CalcFlags', () {
    test('bitwise or', () {
      final flags = CalcFlags.speed | CalcFlags.equatorial;
      expect(flags.contains(CalcFlags.speed), isTrue);
      expect(flags.contains(CalcFlags.equatorial), isTrue);
    });
  });

  group('JdUt1 / JdTt', () {
    test('extension types hold value', () {
      const jd = JdUt1(2451545.0);
      expect(jd.value, 2451545.0);
    });
  });
}
