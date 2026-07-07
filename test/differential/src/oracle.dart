import 'package:swisseph/swisseph.dart' as swe;

class OracleCalcResult {
  final double longitude;
  final double latitude;
  final double distance;
  final double longitudeSpeed;
  final double latitudeSpeed;
  final double distanceSpeed;

  OracleCalcResult._fromSwe(swe.CalcResult r)
    : longitude = r.longitude,
      latitude = r.latitude,
      distance = r.distance,
      longitudeSpeed = r.longitudeSpeed,
      latitudeSpeed = r.latitudeSpeed,
      distanceSpeed = r.distanceSpeed;
}

class Oracle {
  final swe.SwissEph _swe;

  Oracle() : _swe = swe.SwissEph.find();

  OracleCalcResult calcUt(double jdUt, int body, int flags) {
    final result = _swe.calcUt(jdUt, body, flags);
    return OracleCalcResult._fromSwe(result);
  }

  OracleCalcResult calcUtSidereal(
    double jdUt,
    int body,
    int flags,
    int sidMode, {
    double t0 = 0,
    double ayanT0 = 0,
  }) {
    _swe.setSidMode(sidMode, t0: t0, ayanT0: ayanT0);
    final result = _swe.calcUt(jdUt, body, flags | swe.seFlgSidereal);
    _swe.setSidMode(0);
    return OracleCalcResult._fromSwe(result);
  }

  void close() => _swe.close();
}
