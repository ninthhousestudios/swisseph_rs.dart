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

  OracleCalcResult.fromFields({
    required this.longitude,
    required this.latitude,
    required this.distance,
    required this.longitudeSpeed,
    required this.latitudeSpeed,
    required this.distanceSpeed,
  });
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
    try {
      final result = _swe.calcUt(jdUt, body, flags | swe.seFlgSidereal);
      return OracleCalcResult._fromSwe(result);
    } finally {
      _swe.setSidMode(0);
    }
  }

  OracleCalcResult calc(double jdEt, int body, int flags) {
    final result = _swe.calc(jdEt, body, flags);
    return OracleCalcResult._fromSwe(result);
  }

  OracleCalcResult calcSidereal(
    double jdEt,
    int body,
    int flags,
    int sidMode, {
    double t0 = 0,
    double ayanT0 = 0,
  }) {
    _swe.setSidMode(sidMode, t0: t0, ayanT0: ayanT0);
    try {
      final result = _swe.calc(jdEt, body, flags | swe.seFlgSidereal);
      return OracleCalcResult._fromSwe(result);
    } finally {
      _swe.setSidMode(0);
    }
  }

  OracleCalcResult calcTopo(
    double jdEt,
    int body,
    int flags,
    double geolon,
    double geolat,
    double altitude,
  ) {
    _swe.setTopo(geolon, geolat, altitude);
    final result = _swe.calc(jdEt, body, flags | swe.seFlgTopoCtr);
    return OracleCalcResult._fromSwe(result);
  }

  OracleCalcResult calcUtTopo(
    double jdUt,
    int body,
    int flags,
    double geolon,
    double geolat,
    double altitude,
  ) {
    _swe.setTopo(geolon, geolat, altitude);
    final result = _swe.calcUt(jdUt, body, flags | swe.seFlgTopoCtr);
    return OracleCalcResult._fromSwe(result);
  }

  OracleCalcResult calcPctr(double jdEt, int body, int centerBody, int flags) {
    final result = _swe.calcPctr(jdEt, body, centerBody, flags);
    return OracleCalcResult._fromSwe(result);
  }

  void close() => _swe.close();
}
