import 'dart:ffi';

import 'marshal/marshal.dart' as marshal;
import 'types/types.dart';

/// Counterpart: swisseph::Ephemeris
final class Ephemeris implements Finalizable {
  final Pointer<Void> _handle;
  bool _closed = false;

  static final _finalizer = NativeFinalizer(marshal.swissephFreeFnPtr);

  /// Counterpart: swisseph::Ephemeris::new
  Ephemeris(EphemerisConfig config) : _handle = marshal.createHandle(config) {
    _finalizer.attach(this, _handle, detach: this);
  }

  void _checkOpen() {
    if (_closed) {
      throw StateError('Ephemeris has been closed');
    }
  }

  /// Counterpart: swisseph::Ephemeris::calc_ut
  CalcResult calcUt(JdUt1 jd, Body body, CalcFlags flags) {
    _checkOpen();
    return marshal.calcUt(_handle, jd.value, body.rawValue, flags.value);
  }

  /// Counterpart: swisseph::Ephemeris::calc_ut_with_config
  CalcResult calcUtWithConfig(
    JdUt1 jd,
    Body body,
    CalcFlags flags,
    EphemerisConfig config,
  ) {
    _checkOpen();
    return marshal.calcUtWithConfig(
      _handle,
      jd.value,
      body.rawValue,
      flags.value,
      config,
    );
  }

  /// Counterpart: swisseph::Ephemeris::calc
  CalcResult calc(JdTt jd, Body body, CalcFlags flags) {
    _checkOpen();
    return marshal.calc(_handle, jd.value, body.rawValue, flags.value);
  }

  /// Counterpart: swisseph::Ephemeris::calc_with_config
  CalcResult calcWithConfig(
    JdTt jd,
    Body body,
    CalcFlags flags,
    EphemerisConfig config,
  ) {
    _checkOpen();
    return marshal.calcWithConfig(
      _handle,
      jd.value,
      body.rawValue,
      flags.value,
      config,
    );
  }

  /// Counterpart: swisseph::Ephemeris::calc_pctr
  CalcResult calcPctr(JdTt jd, Body body, Body center, CalcFlags flags) {
    _checkOpen();
    return marshal.calcPctr(
      _handle,
      jd.value,
      body.rawValue,
      center.rawValue,
      flags.value,
    );
  }

  /// Counterpart: swisseph_ffi::swisseph_free
  ///
  /// Release the native handle. Idempotent; use-after-close throws
  /// [StateError]. A [NativeFinalizer] backstop ensures cleanup if this
  /// method is never called.
  void close() {
    if (_closed) return;
    _closed = true;
    _finalizer.detach(this);
    marshal.freeHandle(_handle);
  }

  /// Counterpart: swisseph::Ephemeris::delta_t
  double deltaT(JdUt1 jd) {
    _checkOpen();
    return marshal.deltaT(_handle, jd.value);
  }

  /// Counterpart: swisseph::Ephemeris::time_equ
  double timeEqu(double tjdUt) {
    _checkOpen();
    return marshal.timeEqu(_handle, tjdUt);
  }

  /// Counterpart: swisseph::Ephemeris::lmt_to_lat
  double lmtToLat(double tjdLmt, double geolon) {
    _checkOpen();
    return marshal.lmtToLat(_handle, tjdLmt, geolon);
  }

  /// Counterpart: swisseph::Ephemeris::lat_to_lmt
  double latToLmt(double tjdLat, double geolon) {
    _checkOpen();
    return marshal.latToLmt(_handle, tjdLat, geolon);
  }

  /// Counterpart: swisseph::Ephemeris::get_planet_name
  String getPlanetName(Body body) {
    _checkOpen();
    return marshal.getPlanetName(_handle, body.rawValue);
  }

  /// Counterpart: swisseph::Ephemeris::utc_to_jd
  UtcToJd utcToJd(UtcComponents utc, CalendarType cal) {
    _checkOpen();
    return marshal.utcToJd(
      _handle,
      utc.year,
      utc.month,
      utc.day,
      utc.hour,
      utc.minute,
      utc.second,
      cal.value,
    );
  }

  /// Counterpart: swisseph::Ephemeris::jdet_to_utc
  UtcComponents jdetToUtc(JdTt jd, CalendarType cal) {
    _checkOpen();
    return marshal.jdetToUtc(_handle, jd.value, cal.value);
  }

  /// Counterpart: swisseph::Ephemeris::jdut1_to_utc
  UtcComponents jdut1ToUtc(JdUt1 jd, CalendarType cal) {
    _checkOpen();
    return marshal.jdut1ToUtc(_handle, jd.value, cal.value);
  }

  // -----------------------------------------------------------------------
  // Houses
  // -----------------------------------------------------------------------

  /// Counterpart: swisseph::Ephemeris::houses
  HouseResult houses(JdUt1 jd, double geolat, double geolon, HouseSystem hsys) {
    _checkOpen();
    return marshal.housesEx2(
      _handle,
      jd.value,
      0, // no flags
      geolat,
      geolon,
      hsys.charCode,
    );
  }

  /// Counterpart: swisseph::Ephemeris::houses_ex2
  HouseResult housesEx2(
    JdUt1 jd,
    CalcFlags flags,
    double geolat,
    double geolon,
    HouseSystem hsys,
  ) {
    _checkOpen();
    return marshal.housesEx2(
      _handle,
      jd.value,
      flags.value,
      geolat,
      geolon,
      hsys.charCode,
    );
  }

  /// Counterpart: swisseph::Ephemeris::gauquelin_sector
  double gauquelinSector(
    JdUt1 jd,
    Body body,
    CalcFlags flags,
    int method,
    double geolon,
    double geolat,
    double geoalt, {
    double atpress = 0,
    double attemp = 0,
  }) {
    _checkOpen();
    return marshal.gauquelinSector(
      _handle,
      jd.value,
      body.rawValue,
      flags.value,
      method,
      geolon,
      geolat,
      geoalt,
      atpress,
      attemp,
    );
  }

  // -----------------------------------------------------------------------
  // Ayanamsa
  // -----------------------------------------------------------------------

  /// Counterpart: swisseph::Ephemeris::get_ayanamsa_ex
  double getAyanamsaEx(JdTt jd, CalcFlags flags) {
    _checkOpen();
    return marshal.getAyanamsaEx(_handle, jd.value, flags.value);
  }

  /// Counterpart: swisseph::Ephemeris::get_ayanamsa_ex_with_config
  double getAyanamsaExWithConfig(
    JdTt jd,
    CalcFlags flags,
    EphemerisConfig config,
  ) {
    _checkOpen();
    return marshal.getAyanamsaExWithConfig(
      _handle,
      jd.value,
      flags.value,
      config,
    );
  }

  /// Counterpart: swisseph::Ephemeris::get_ayanamsa_ut
  double getAyanamsaUt(JdUt1 jd, CalcFlags flags) {
    _checkOpen();
    return marshal.getAyanamsaUt(_handle, jd.value, flags.value);
  }

  /// Counterpart: swisseph::Ephemeris::get_ayanamsa
  double getAyanamsa(JdTt jd) {
    _checkOpen();
    return marshal.getAyanamsa(_handle, jd.value);
  }

  /// Counterpart: swisseph::Ephemeris (share via Arc clone)
  ///
  /// Returns a token sendable to another isolate. Native-only.
  Object share() {
    _checkOpen();
    throw UnimplementedError('share not yet implemented');
  }
}

/// Counterpart: swisseph::swisseph_version
String get engineVersion => marshal.engineVersion();

/// Counterpart: swisseph::date::julday
JdUt1 julday(int year, int month, int day, double hour, CalendarType cal) {
  return JdUt1(marshal.julday(year, month, day, hour, cal.value));
}

/// Counterpart: swisseph::date::revjul
({int year, int month, int day, double hour}) revjul(
  double jd,
  CalendarType cal,
) {
  return marshal.revjul(jd, cal.value);
}

/// Counterpart: swisseph::date::date_conversion
JdUt1 dateConversion(
  int year,
  int month,
  int day,
  double hour,
  CalendarType cal,
) {
  final calChar = cal == CalendarType.gregorian ? 0x67 : 0x6A; // 'g' or 'j'
  return JdUt1(marshal.dateConversion(year, month, day, hour, calChar));
}

/// Counterpart: swisseph::date::day_of_week
int dayOfWeek(double jd) {
  return marshal.dayOfWeek(jd);
}

/// Counterpart: swisseph::date::utc_time_zone
UtcComponents utcTimeZone(UtcComponents input, double tzOffset) {
  return marshal.utcTimeZone(
    input.year,
    input.month,
    input.day,
    input.hour,
    input.minute,
    input.second,
    tzOffset,
  );
}

/// Counterpart: swisseph::math::split_degrees
DegreeParts splitDegrees(double ddeg, SplitDegFlags flags) {
  return marshal.splitDegrees(ddeg, flags.value);
}

/// Counterpart: swisseph::math::normalize_degrees
double normalizeDegrees(double x) {
  var result = x % 360.0;
  if (result < 0) result += 360.0;
  return result;
}

/// Counterpart: swisseph::houses::houses_armc
HouseResult housesArmc(
  double armc,
  double geolat,
  double eps,
  HouseSystem hsys,
) {
  return marshal.housesArmcEx2(armc, geolat, eps, hsys.charCode);
}

/// Counterpart: swisseph::houses::house_pos
double housePos(
  double armc,
  double geolat,
  double eps,
  HouseSystem hsys,
  double bodyLon,
  double bodyLat,
) {
  return marshal.housePos(armc, geolat, eps, hsys.charCode, bodyLon, bodyLat);
}

/// Counterpart: swisseph::types::HouseSystem::name
String houseName(HouseSystem hsys) {
  return marshal.houseName(hsys.charCode);
}

/// Counterpart: swisseph::types::SiderealMode::name
String getAyanamsaName(SiderealMode sidMode) {
  return marshal.getAyanamsaName(sidMode.value);
}
