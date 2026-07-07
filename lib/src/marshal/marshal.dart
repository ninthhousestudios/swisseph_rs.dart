import 'dart:ffi';

import 'package:ffi/ffi.dart';

import '../bindings/bindings.dart';
import '../types/types.dart';

/// Native function pointer for [NativeFinalizer] registration.
Pointer<NativeFinalizerFunction> get swissephFreeFnPtr =>
    Native.addressOf<NativeFunction<Void Function(Pointer<Void>)>>(
      swissephFree,
    );

// ---------------------------------------------------------------------------
// Error handling
// ---------------------------------------------------------------------------

const _errBufSize = 256;

/// Check an FFI return code; throw on negative.
void _checkResult(int code, Pointer<Utf8> errBuf) {
  if (code < 0) {
    final msg = errBuf.toDartString();
    throw exceptionFromCode(code, msg);
  }
}

// ---------------------------------------------------------------------------
// Config marshaling
// ---------------------------------------------------------------------------

/// Allocate and fill a [SweConfig] from a Dart [EphemerisConfig].
/// The returned pointer is valid for the lifetime of [arena].
Pointer<SweConfig> marshalConfig(Arena arena, EphemerisConfig config) {
  final c = arena<SweConfig>();
  c.ref.ephemerisSource = config.ephemerisSource.value;
  c.ref.ephePath = config.ephePath != null
      ? config.ephePath!.toNativeUtf8(allocator: arena)
      : nullptr;
  c.ref.jplFilename = config.jplFilename != null
      ? config.jplFilename!.toNativeUtf8(allocator: arena)
      : nullptr;
  c.ref.leapSecondsFile = config.leapSecondsFile != null
      ? config.leapSecondsFile!.toNativeUtf8(allocator: arena)
      : nullptr;
  c.ref.hasSidereal = config.siderealMode != null;
  var sidBits = config.siderealBits.value;
  if (config.siderealT0IsUt) sidBits |= SiderealBits.userUt.value;
  c.ref.sidMode = (config.siderealMode?.value ?? 0) | sidBits;
  c.ref.sidT0 = config.siderealT0;
  c.ref.sidAyanT0 = config.siderealAyanT0;
  c.ref.hasTopo = config.topographic != null;
  c.ref.geolon = config.topographic?.longitude ?? 0;
  c.ref.geolat = config.topographic?.latitude ?? 0;
  c.ref.altitude = config.topographic?.altitude ?? 0;
  c.ref.tidalAcceleration = config.tidalAcceleration ?? double.nan;
  c.ref.deltaTUserdef = config.deltaTUserdef ?? double.nan;

  if (config.asteroidNumbers.isNotEmpty) {
    final arr = arena<Int32>(config.asteroidNumbers.length);
    for (var i = 0; i < config.asteroidNumbers.length; i++) {
      arr[i] = config.asteroidNumbers[i];
    }
    c.ref.asteroidNumbers = arr;
    c.ref.asteroidNumbersLen = config.asteroidNumbers.length;
  } else {
    c.ref.asteroidNumbers = nullptr;
    c.ref.asteroidNumbersLen = 0;
  }

  if (config.planetMoonNumbers.isNotEmpty) {
    final arr = arena<Int32>(config.planetMoonNumbers.length);
    for (var i = 0; i < config.planetMoonNumbers.length; i++) {
      arr[i] = config.planetMoonNumbers[i];
    }
    c.ref.planetMoonNumbers = arr;
    c.ref.planetMoonNumbersLen = config.planetMoonNumbers.length;
  } else {
    c.ref.planetMoonNumbers = nullptr;
    c.ref.planetMoonNumbersLen = 0;
  }

  if (config.extraLeapSeconds.isNotEmpty) {
    final arr = arena<Int32>(config.extraLeapSeconds.length);
    for (var i = 0; i < config.extraLeapSeconds.length; i++) {
      arr[i] = config.extraLeapSeconds[i];
    }
    c.ref.extraLeapSeconds = arr;
    c.ref.extraLeapSecondsLen = config.extraLeapSeconds.length;
  } else {
    c.ref.extraLeapSeconds = nullptr;
    c.ref.extraLeapSecondsLen = 0;
  }

  c.ref.astroModelPrecLongterm = config.astroModels?.precLongterm.value ?? 0;
  c.ref.astroModelPrecShortterm = config.astroModels?.precShortterm.value ?? 0;
  c.ref.astroModelNutation = config.astroModels?.nutation.value ?? 0;
  c.ref.astroModelBias = config.astroModels?.bias.value ?? 0;
  c.ref.astroModelJplhor = config.astroModels?.jplhorMode.value ?? 0;
  c.ref.astroModelJplhora = config.astroModels?.jplhoraMode.value ?? 0;
  c.ref.astroModelSiderealTime = config.astroModels?.siderealTime.value ?? 0;
  c.ref.astroModelDeltaT = config.astroModels?.deltaT.value ?? 0;
  return c;
}

// ---------------------------------------------------------------------------
// Result unmarshaling
// ---------------------------------------------------------------------------

/// Unpack a 6-element double array + flags into a [CalcResult].
CalcResult unmarshalCalcResult(Pointer<Double> xx, int flagsUsed) {
  return CalcResult(
    longitude: xx[0],
    latitude: xx[1],
    distance: xx[2],
    longitudeSpeed: xx[3],
    latitudeSpeed: xx[4],
    distanceSpeed: xx[5],
    flagsUsed: CalcFlags(flagsUsed),
  );
}

// ---------------------------------------------------------------------------
// High-level FFI call wrappers (the only Dart↔FFI meeting point).
// ---------------------------------------------------------------------------

/// Create an ephemeris handle from config. Throws [SweException] on failure.
Pointer<Void> createHandle(EphemerisConfig config) {
  return using((arena) {
    final sweConfig = marshalConfig(arena, config);
    final errBuf = arena<Uint8>(_errBufSize).cast<Utf8>();
    final out = arena<Pointer<Void>>();
    final code = swissephNew(sweConfig, out, errBuf, _errBufSize);
    _checkResult(code, errBuf);
    return out.value;
  });
}

/// Release an ephemeris handle. Null-safe on the native side.
void freeHandle(Pointer<Void> handle) {
  swissephFree(handle);
}

/// Call `swisseph_calc_ut` and return a typed [CalcResult].
CalcResult calcUt(Pointer<Void> handle, double tjdUt, int ipl, int iflag) {
  return using((arena) {
    final xx = arena<Double>(6);
    final flagsUsed = arena<Int32>();
    final errBuf = arena<Uint8>(_errBufSize).cast<Utf8>();
    final code = swissephCalcUt(
      handle,
      tjdUt,
      ipl,
      iflag,
      nullptr,
      nullptr,
      xx,
      flagsUsed,
      errBuf,
      _errBufSize,
    );
    _checkResult(code, errBuf);
    return unmarshalCalcResult(xx, flagsUsed.value);
  });
}

/// Call `swisseph_calc_ut` with per-call config overrides.
CalcResult calcUtWithConfig(
  Pointer<Void> handle,
  double tjdUt,
  int ipl,
  int iflag,
  EphemerisConfig config,
) {
  return using((arena) {
    final xx = arena<Double>(6);
    final flagsUsed = arena<Int32>();
    final errBuf = arena<Uint8>(_errBufSize).cast<Utf8>();

    Pointer<Double> geopos = nullptr;
    if (config.topographic case final topo?) {
      geopos = arena<Double>(3);
      geopos[0] = topo.longitude;
      geopos[1] = topo.latitude;
      geopos[2] = topo.altitude;
    }

    Pointer<SweSidMode> sidMode = nullptr;
    if (config.siderealMode != null) {
      sidMode = arena<SweSidMode>();
      var bits = config.siderealBits.value;
      if (config.siderealT0IsUt) bits |= SiderealBits.userUt.value;
      sidMode.ref.sidMode = config.siderealMode!.value | bits;
      sidMode.ref.t0 = config.siderealT0;
      sidMode.ref.ayanT0 = config.siderealAyanT0;
    }

    final code = swissephCalcUt(
      handle,
      tjdUt,
      ipl,
      iflag,
      geopos,
      sidMode,
      xx,
      flagsUsed,
      errBuf,
      _errBufSize,
    );
    _checkResult(code, errBuf);
    return unmarshalCalcResult(xx, flagsUsed.value);
  });
}

/// Call `swisseph_calc` and return a typed [CalcResult].
CalcResult calc(Pointer<Void> handle, double tjdEt, int ipl, int iflag) {
  return using((arena) {
    final xx = arena<Double>(6);
    final flagsUsed = arena<Int32>();
    final errBuf = arena<Uint8>(_errBufSize).cast<Utf8>();
    final code = swissephCalc(
      handle,
      tjdEt,
      ipl,
      iflag,
      nullptr,
      nullptr,
      xx,
      flagsUsed,
      errBuf,
      _errBufSize,
    );
    _checkResult(code, errBuf);
    return unmarshalCalcResult(xx, flagsUsed.value);
  });
}

/// Call `swisseph_calc` with per-call config overrides.
CalcResult calcWithConfig(
  Pointer<Void> handle,
  double tjdEt,
  int ipl,
  int iflag,
  EphemerisConfig config,
) {
  return using((arena) {
    final xx = arena<Double>(6);
    final flagsUsed = arena<Int32>();
    final errBuf = arena<Uint8>(_errBufSize).cast<Utf8>();

    Pointer<Double> geopos = nullptr;
    if (config.topographic case final topo?) {
      geopos = arena<Double>(3);
      geopos[0] = topo.longitude;
      geopos[1] = topo.latitude;
      geopos[2] = topo.altitude;
    }

    Pointer<SweSidMode> sidMode = nullptr;
    if (config.siderealMode != null) {
      sidMode = arena<SweSidMode>();
      var bits = config.siderealBits.value;
      if (config.siderealT0IsUt) bits |= SiderealBits.userUt.value;
      sidMode.ref.sidMode = config.siderealMode!.value | bits;
      sidMode.ref.t0 = config.siderealT0;
      sidMode.ref.ayanT0 = config.siderealAyanT0;
    }

    final code = swissephCalc(
      handle,
      tjdEt,
      ipl,
      iflag,
      geopos,
      sidMode,
      xx,
      flagsUsed,
      errBuf,
      _errBufSize,
    );
    _checkResult(code, errBuf);
    return unmarshalCalcResult(xx, flagsUsed.value);
  });
}

/// Call `swisseph_calc_pctr` and return a typed [CalcResult].
CalcResult calcPctr(
  Pointer<Void> handle,
  double tjdEt,
  int ipl,
  int iplctr,
  int iflag,
) {
  return using((arena) {
    final xx = arena<Double>(6);
    final flagsUsed = arena<Int32>();
    final errBuf = arena<Uint8>(_errBufSize).cast<Utf8>();
    final code = swissephCalcPctr(
      handle,
      tjdEt,
      ipl,
      iplctr,
      iflag,
      xx,
      flagsUsed,
      errBuf,
      _errBufSize,
    );
    _checkResult(code, errBuf);
    return unmarshalCalcResult(xx, flagsUsed.value);
  });
}

/// Read the engine version string from the native library.
String engineVersion() {
  return swissephVersion().toDartString();
}

// ---------------------------------------------------------------------------
// Date/time free functions
// ---------------------------------------------------------------------------

/// Call `swisseph_julday`.
double julday(int year, int month, int day, double hour, int gregflag) {
  return swissephJulday(year, month, day, hour, gregflag);
}

/// Call `swisseph_revjul` and return components.
({int year, int month, int day, double hour}) revjul(double jd, int gregflag) {
  return using((arena) {
    final y = arena<Int32>();
    final m = arena<Int32>();
    final d = arena<Int32>();
    final h = arena<Double>();
    swissephRevjul(jd, gregflag, y, m, d, h);
    return (year: y.value, month: m.value, day: d.value, hour: h.value);
  });
}

/// Call `swisseph_date_conversion`. Throws on invalid date.
double dateConversion(int year, int month, int day, double hour, int cal) {
  return using((arena) {
    final tjd = arena<Double>();
    final errBuf = arena<Uint8>(_errBufSize).cast<Utf8>();
    final code = swissephDateConversion(
      year,
      month,
      day,
      hour,
      cal,
      tjd,
      errBuf,
      _errBufSize,
    );
    _checkResult(code, errBuf);
    return tjd.value;
  });
}

/// Call `swisseph_day_of_week`.
int dayOfWeek(double jd) {
  return swissephDayOfWeek(jd);
}

/// Call `swisseph_utc_time_zone` and return [UtcComponents].
UtcComponents utcTimeZone(
  int year,
  int month,
  int day,
  int hour,
  int minute,
  double second,
  double tzOffset,
) {
  return using((arena) {
    final oy = arena<Int32>();
    final om = arena<Int32>();
    final od = arena<Int32>();
    final oh = arena<Int32>();
    final omin = arena<Int32>();
    final osec = arena<Double>();
    swissephUtcTimeZone(
      year,
      month,
      day,
      hour,
      minute,
      second,
      tzOffset,
      oy,
      om,
      od,
      oh,
      omin,
      osec,
    );
    return UtcComponents(
      year: oy.value,
      month: om.value,
      day: od.value,
      hour: oh.value,
      minute: omin.value,
      second: osec.value,
    );
  });
}

/// Call `swisseph_utc_to_jd` and return [UtcToJd].
UtcToJd utcToJd(
  Pointer<Void> handle,
  int year,
  int month,
  int day,
  int hour,
  int min,
  double sec,
  int gregflag,
) {
  return using((arena) {
    final dret = arena<Double>(2);
    final errBuf = arena<Uint8>(_errBufSize).cast<Utf8>();
    final code = swissephUtcToJd(
      handle,
      year,
      month,
      day,
      hour,
      min,
      sec,
      gregflag,
      dret,
      errBuf,
      _errBufSize,
    );
    _checkResult(code, errBuf);
    return UtcToJd(tt: JdTt(dret[0]), ut1: JdUt1(dret[1]));
  });
}

/// Call `swisseph_jdet_to_utc` and return [UtcComponents].
UtcComponents jdetToUtc(Pointer<Void> handle, double tjdEt, int gregflag) {
  return using((arena) {
    final y = arena<Int32>();
    final m = arena<Int32>();
    final d = arena<Int32>();
    final h = arena<Int32>();
    final min = arena<Int32>();
    final sec = arena<Double>();
    swissephJdetToUtc(handle, tjdEt, gregflag, y, m, d, h, min, sec);
    return UtcComponents(
      year: y.value,
      month: m.value,
      day: d.value,
      hour: h.value,
      minute: min.value,
      second: sec.value,
    );
  });
}

/// Call `swisseph_jdut1_to_utc` and return [UtcComponents].
UtcComponents jdut1ToUtc(Pointer<Void> handle, double tjdUt, int gregflag) {
  return using((arena) {
    final y = arena<Int32>();
    final m = arena<Int32>();
    final d = arena<Int32>();
    final h = arena<Int32>();
    final min = arena<Int32>();
    final sec = arena<Double>();
    swissephJdut1ToUtc(handle, tjdUt, gregflag, y, m, d, h, min, sec);
    return UtcComponents(
      year: y.value,
      month: m.value,
      day: d.value,
      hour: h.value,
      minute: min.value,
      second: sec.value,
    );
  });
}

/// Call `swisseph_deltat`.
double deltaT(Pointer<Void> handle, double tjdUt) {
  return swissephDeltat(handle, tjdUt);
}

/// Call `swisseph_time_equ`.
double timeEqu(Pointer<Void> handle, double tjdUt) {
  return using((arena) {
    final e = arena<Double>();
    final errBuf = arena<Uint8>(_errBufSize).cast<Utf8>();
    final code = swissephTimeEqu(handle, tjdUt, e, errBuf, _errBufSize);
    _checkResult(code, errBuf);
    return e.value;
  });
}

/// Call `swisseph_lmt_to_lat`.
double lmtToLat(Pointer<Void> handle, double tjdLmt, double geolon) {
  return using((arena) {
    final tjdLat = arena<Double>();
    final errBuf = arena<Uint8>(_errBufSize).cast<Utf8>();
    final code = swissephLmtToLat(
      handle,
      tjdLmt,
      geolon,
      tjdLat,
      errBuf,
      _errBufSize,
    );
    _checkResult(code, errBuf);
    return tjdLat.value;
  });
}

/// Call `swisseph_lat_to_lmt`.
double latToLmt(Pointer<Void> handle, double tjdLat, double geolon) {
  return using((arena) {
    final tjdLmt = arena<Double>();
    final errBuf = arena<Uint8>(_errBufSize).cast<Utf8>();
    final code = swissephLatToLmt(
      handle,
      tjdLat,
      geolon,
      tjdLmt,
      errBuf,
      _errBufSize,
    );
    _checkResult(code, errBuf);
    return tjdLmt.value;
  });
}

/// Call `swisseph_get_planet_name`.
String getPlanetName(Pointer<Void> handle, int ipl) {
  return using((arena) {
    final buf = arena<Uint8>(256).cast<Utf8>();
    final errBuf = arena<Uint8>(_errBufSize).cast<Utf8>();
    final code = swissephGetPlanetName(
      handle,
      ipl,
      buf,
      256,
      errBuf,
      _errBufSize,
    );
    _checkResult(code, errBuf);
    return buf.toDartString();
  });
}

/// Call `swisseph_split_deg` and return [DegreeParts].
DegreeParts splitDegrees(double ddeg, int roundflag) {
  return using((arena) {
    final deg = arena<Int32>();
    final min = arena<Int32>();
    final sec = arena<Int32>();
    final secfr = arena<Double>();
    final sign = arena<Int32>();
    swissephSplitDeg(ddeg, roundflag, deg, min, sec, secfr, sign);
    return DegreeParts(
      degrees: deg.value,
      minutes: min.value,
      seconds: sec.value,
      secondFraction: secfr.value,
      sign: sign.value,
    );
  });
}

// ---------------------------------------------------------------------------
// Houses
// ---------------------------------------------------------------------------

/// Unmarshal a 10-element ascmc array into [AscMc].
AscMc _unmarshalAscMc(Pointer<Double> p) {
  return AscMc(
    ascendant: p[0],
    mc: p[1],
    armc: p[2],
    vertex: p[3],
    equatorialAscendant: p[4],
    coascendantKoch: p[5],
    coascendantMunkasey: p[6],
    polarAscendant: p[7],
  );
}

/// Unmarshal cusps from a native 37-element buffer into a Dart list.
/// The list length is 37 for Gauquelin (hsys 0x47), 13 otherwise.
List<double> _unmarshalCusps(Pointer<Double> p, int hsys) {
  final len = hsys == 0x47 ? 37 : 13;
  return [for (var i = 0; i < len; i++) p[i]];
}

/// Call `swisseph_houses_ex2` and return a typed [HouseResult].
HouseResult housesEx2(
  Pointer<Void> handle,
  double tjdUt,
  int iflag,
  double geolat,
  double geolon,
  int hsys,
) {
  return using((arena) {
    final cusps = arena<Double>(37);
    final ascmc = arena<Double>(10);
    final cuspSpeed = arena<Double>(37);
    final ascmcSpeed = arena<Double>(10);
    final errBuf = arena<Uint8>(_errBufSize).cast<Utf8>();
    final code = swissephHousesEx2(
      handle,
      tjdUt,
      iflag,
      geolat,
      geolon,
      hsys,
      cusps,
      ascmc,
      cuspSpeed,
      ascmcSpeed,
      errBuf,
      _errBufSize,
    );
    _checkResult(code, errBuf);
    return HouseResult(
      cusps: _unmarshalCusps(cusps, hsys),
      cuspSpeeds: _unmarshalCusps(cuspSpeed, hsys),
      ascmc: _unmarshalAscMc(ascmc),
      ascmcSpeeds: _unmarshalAscMc(ascmcSpeed),
    );
  });
}

/// Call `swisseph_houses_armc_ex2` (handle-free) and return a [HouseResult].
HouseResult housesArmcEx2(double armc, double geolat, double eps, int hsys) {
  return using((arena) {
    final cusps = arena<Double>(37);
    final ascmc = arena<Double>(10);
    final cuspSpeed = arena<Double>(37);
    final ascmcSpeed = arena<Double>(10);
    final errBuf = arena<Uint8>(_errBufSize).cast<Utf8>();
    final code = swissephHousesArmcEx2(
      armc,
      geolat,
      eps,
      hsys,
      nullptr, // sundec
      cusps,
      ascmc,
      cuspSpeed,
      ascmcSpeed,
      errBuf,
      _errBufSize,
    );
    _checkResult(code, errBuf);
    return HouseResult(
      cusps: _unmarshalCusps(cusps, hsys),
      cuspSpeeds: _unmarshalCusps(cuspSpeed, hsys),
      ascmc: _unmarshalAscMc(ascmc),
      ascmcSpeeds: _unmarshalAscMc(ascmcSpeed),
    );
  });
}

/// Call `swisseph_house_pos` (handle-free) and return the house position.
double housePos(
  double armc,
  double geolat,
  double eps,
  int hsys,
  double bodyLon,
  double bodyLat,
) {
  return using((arena) {
    final xpin = arena<Double>(2);
    xpin[0] = bodyLon;
    xpin[1] = bodyLat;
    final hpos = arena<Double>();
    final errBuf = arena<Uint8>(_errBufSize).cast<Utf8>();
    final code = swissephHousePos(
      armc,
      geolat,
      eps,
      hsys,
      xpin,
      nullptr, // sundec
      hpos,
      errBuf,
      _errBufSize,
    );
    _checkResult(code, errBuf);
    return hpos.value;
  });
}

/// Call `swisseph_house_name` (handle-free) and return the name string.
String houseName(int hsys) {
  return using((arena) {
    final buf = arena<Uint8>(256).cast<Utf8>();
    final errBuf = arena<Uint8>(_errBufSize).cast<Utf8>();
    final code = swissephHouseName(hsys, buf, 256, errBuf, _errBufSize);
    _checkResult(code, errBuf);
    return buf.toDartString();
  });
}

/// Call `swisseph_gauquelin_sector` and return the sector number.
double gauquelinSector(
  Pointer<Void> handle,
  double tjdUt,
  int ipl,
  int iflag,
  int imeth,
  double geolon,
  double geolat,
  double geoalt,
  double atpress,
  double attemp,
) {
  return using((arena) {
    final geopos = arena<Double>(3);
    geopos[0] = geolon;
    geopos[1] = geolat;
    geopos[2] = geoalt;
    final dgsect = arena<Double>();
    final errBuf = arena<Uint8>(_errBufSize).cast<Utf8>();
    final code = swissephGauquelinSector(
      handle,
      tjdUt,
      ipl,
      nullptr, // starname (null for planets)
      iflag,
      imeth,
      geopos,
      atpress,
      attemp,
      dgsect,
      errBuf,
      _errBufSize,
    );
    _checkResult(code, errBuf);
    return dgsect.value;
  });
}

// ---------------------------------------------------------------------------
// Ayanamsa
// ---------------------------------------------------------------------------

/// Call `swisseph_get_ayanamsa_ex` and return the ayanamsa value.
double getAyanamsaEx(Pointer<Void> handle, double tjdEt, int iflag) {
  return using((arena) {
    final daya = arena<Double>();
    final errBuf = arena<Uint8>(_errBufSize).cast<Utf8>();
    final code = swissephGetAyanamsaEx(
      handle,
      tjdEt,
      iflag,
      nullptr, // use handle's configured sidereal mode
      daya,
      nullptr, // flagsUsed
      errBuf,
      _errBufSize,
    );
    _checkResult(code, errBuf);
    return daya.value;
  });
}

/// Call `swisseph_get_ayanamsa_ex` with per-call sidereal mode override.
double getAyanamsaExWithConfig(
  Pointer<Void> handle,
  double tjdEt,
  int iflag,
  EphemerisConfig config,
) {
  return using((arena) {
    final daya = arena<Double>();
    final errBuf = arena<Uint8>(_errBufSize).cast<Utf8>();

    Pointer<SweSidMode> sidMode = nullptr;
    if (config.siderealMode != null) {
      sidMode = arena<SweSidMode>();
      var bits = config.siderealBits.value;
      if (config.siderealT0IsUt) bits |= SiderealBits.userUt.value;
      sidMode.ref.sidMode = config.siderealMode!.value | bits;
      sidMode.ref.t0 = config.siderealT0;
      sidMode.ref.ayanT0 = config.siderealAyanT0;
    }

    final code = swissephGetAyanamsaEx(
      handle,
      tjdEt,
      iflag,
      sidMode,
      daya,
      nullptr,
      errBuf,
      _errBufSize,
    );
    _checkResult(code, errBuf);
    return daya.value;
  });
}

/// Call `swisseph_get_ayanamsa_ex_ut` and return the ayanamsa value.
double getAyanamsaUt(Pointer<Void> handle, double tjdUt, int iflag) {
  return using((arena) {
    final daya = arena<Double>();
    final errBuf = arena<Uint8>(_errBufSize).cast<Utf8>();
    final code = swissephGetAyanamsaExUt(
      handle,
      tjdUt,
      iflag,
      nullptr,
      daya,
      nullptr,
      errBuf,
      _errBufSize,
    );
    _checkResult(code, errBuf);
    return daya.value;
  });
}

/// Call `swisseph_get_ayanamsa` (legacy, no flags).
double getAyanamsa(Pointer<Void> handle, double tjdEt) {
  final result = swissephGetAyanamsa(handle, tjdEt, nullptr);
  if (result.isNaN) {
    throw const CErrorException('swisseph_get_ayanamsa returned NaN');
  }
  return result;
}

/// Call `swisseph_get_ayanamsa_name` (handle-free) and return the name.
String getAyanamsaName(int sidModeRaw) {
  return using((arena) {
    final buf = arena<Uint8>(256).cast<Utf8>();
    final errBuf = arena<Uint8>(_errBufSize).cast<Utf8>();
    final code = swissephGetAyanamsaName(
      sidModeRaw,
      buf,
      256,
      errBuf,
      _errBufSize,
    );
    _checkResult(code, errBuf);
    return buf.toDartString();
  });
}
