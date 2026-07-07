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

  double julday(
    int year,
    int month,
    int day,
    double hour, {
    bool gregorian = true,
  }) {
    return _swe.julday(year, month, day, hour, gregorian: gregorian);
  }

  ({int year, int month, int day, double hour}) revjul(
    double jd, {
    bool gregorian = true,
  }) {
    final r = _swe.revjul(jd, gregorian: gregorian);
    return (year: r.year, month: r.month, day: r.day, hour: r.hour);
  }

  double? dateConversion(
    int year,
    int month,
    int day,
    double hour, {
    bool gregorian = true,
  }) {
    return _swe.dateConversion(year, month, day, hour, gregorian: gregorian);
  }

  int dayOfWeek(double jd) {
    return _swe.dayOfWeek(jd);
  }

  ({int year, int month, int day, int hour, int min, double sec}) utcTimeZone(
    int year,
    int month,
    int day,
    int hour,
    int min,
    double sec,
    double timezone,
  ) {
    final r = _swe.utcTimeZone(year, month, day, hour, min, sec, timezone);
    return (
      year: r.year,
      month: r.month,
      day: r.day,
      hour: r.hour,
      min: r.min,
      sec: r.sec,
    );
  }

  ({double et, double ut1}) utcToJd(
    int year,
    int month,
    int day,
    int hour,
    int min,
    double sec, {
    bool gregorian = true,
  }) {
    final r = _swe.utcToJd(
      year,
      month,
      day,
      hour,
      min,
      sec,
      gregorian: gregorian,
    );
    return (et: r.et, ut1: r.ut1);
  }

  ({int year, int month, int day, int hour, int min, double sec}) jdetToUtc(
    double jdEt, {
    bool gregorian = true,
  }) {
    final r = _swe.jdetToUtc(jdEt, gregorian: gregorian);
    return (
      year: r.year,
      month: r.month,
      day: r.day,
      hour: r.hour,
      min: r.min,
      sec: r.sec,
    );
  }

  ({int year, int month, int day, int hour, int min, double sec}) jdut1ToUtc(
    double jdUt, {
    bool gregorian = true,
  }) {
    final r = _swe.jdToUtc(jdUt, gregorian: gregorian);
    return (
      year: r.year,
      month: r.month,
      day: r.day,
      hour: r.hour,
      min: r.min,
      sec: r.sec,
    );
  }

  double deltat(double jd) {
    return _swe.deltat(jd);
  }

  double timeEqu(double jd) {
    return _swe.timeEqu(jd);
  }

  double lmtToLat(double jdLmt, double geolon) {
    return _swe.lmtToLat(jdLmt, geolon);
  }

  double latToLmt(double jdLat, double geolon) {
    return _swe.latToLmt(jdLat, geolon);
  }

  String getPlanetName(int body) {
    return _swe.getPlanetName(body);
  }

  ({int degrees, int minutes, int seconds, double secondsFraction, int sign})
  splitDeg(double degrees, int roundFlag) {
    final r = _swe.splitDeg(degrees, roundFlag);
    return (
      degrees: r.degrees,
      minutes: r.minutes,
      seconds: r.seconds,
      secondsFraction: r.secondsFraction,
      sign: r.sign,
    );
  }

  void close() => _swe.close();
}
