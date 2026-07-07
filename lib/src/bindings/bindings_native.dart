@DefaultAsset('package:swisseph_rs/swisseph_rs.dart')
library;

import 'dart:ffi';

import 'package:ffi/ffi.dart';

// ---------------------------------------------------------------------------
// #[repr(C)] struct mirrors — layout must match swisseph-ffi exactly.
// ---------------------------------------------------------------------------

/// Mirrors `swisseph-ffi/src/config.rs::SweConfig`.
final class SweConfig extends Struct {
  @Int32()
  external int ephemerisSource;

  external Pointer<Utf8> ephePath;
  external Pointer<Utf8> jplFilename;
  external Pointer<Utf8> leapSecondsFile;

  @Bool()
  external bool hasSidereal;
  @Int32()
  external int sidMode;
  @Double()
  external double sidT0;
  @Double()
  external double sidAyanT0;

  @Bool()
  external bool hasTopo;
  @Double()
  external double geolon;
  @Double()
  external double geolat;
  @Double()
  external double altitude;

  @Double()
  external double tidalAcceleration;
  @Double()
  external double deltaTUserdef;

  external Pointer<Int32> asteroidNumbers;
  @Size()
  external int asteroidNumbersLen;
  external Pointer<Int32> planetMoonNumbers;
  @Size()
  external int planetMoonNumbersLen;
  external Pointer<Int32> extraLeapSeconds;
  @Size()
  external int extraLeapSecondsLen;

  @Int32()
  external int astroModelPrecLongterm;
  @Int32()
  external int astroModelPrecShortterm;
  @Int32()
  external int astroModelNutation;
  @Int32()
  external int astroModelBias;
  @Int32()
  external int astroModelJplhor;
  @Int32()
  external int astroModelJplhora;
  @Int32()
  external int astroModelSiderealTime;
  @Int32()
  external int astroModelDeltaT;
}

/// Mirrors `swisseph-ffi/src/lib.rs::SweSidMode`.
final class SweSidMode extends Struct {
  @Int32()
  external int sidMode;
  @Double()
  external double t0;
  @Double()
  external double ayanT0;
}

// ---------------------------------------------------------------------------
// @Native bindings — resolved via the native-assets protocol.
// ---------------------------------------------------------------------------

@Native<Pointer<Utf8> Function()>(symbol: 'swisseph_version')
external Pointer<Utf8> swissephVersion();

@Native<Void Function(Pointer<SweConfig>)>(symbol: 'swisseph_config_default')
external void swissephConfigDefault(Pointer<SweConfig> config);

@Native<
  Int32 Function(
    Pointer<SweConfig>,
    Pointer<Pointer<Void>>,
    Pointer<Utf8>,
    Size,
  )
>(symbol: 'swisseph_new')
external int swissephNew(
  Pointer<SweConfig> config,
  Pointer<Pointer<Void>> out,
  Pointer<Utf8> errBuf,
  int errCap,
);

@Native<Void Function(Pointer<Void>)>(symbol: 'swisseph_free')
external void swissephFree(Pointer<Void> handle);

@Native<
  Int32 Function(Pointer<Void>, Pointer<Pointer<Void>>, Pointer<Utf8>, Size)
>(symbol: 'swisseph_share')
external int swissephShare(
  Pointer<Void> handle,
  Pointer<Pointer<Void>> out,
  Pointer<Utf8> errBuf,
  int errCap,
);

@Native<
  Int32 Function(
    Pointer<Void>,
    Double,
    Int32,
    Int32,
    Pointer<Double>,
    Pointer<SweSidMode>,
    Pointer<Double>,
    Pointer<Int32>,
    Pointer<Utf8>,
    Size,
  )
>(symbol: 'swisseph_calc_ut')
external int swissephCalcUt(
  Pointer<Void> handle,
  double tjdUt,
  int ipl,
  int iflag,
  Pointer<Double> geopos,
  Pointer<SweSidMode> sidMode,
  Pointer<Double> xx,
  Pointer<Int32> flagsUsed,
  Pointer<Utf8> errBuf,
  int errCap,
);

@Native<
  Int32 Function(
    Pointer<Void>,
    Double,
    Int32,
    Int32,
    Pointer<Double>,
    Pointer<SweSidMode>,
    Pointer<Double>,
    Pointer<Int32>,
    Pointer<Utf8>,
    Size,
  )
>(symbol: 'swisseph_calc')
external int swissephCalc(
  Pointer<Void> handle,
  double tjdEt,
  int ipl,
  int iflag,
  Pointer<Double> geopos,
  Pointer<SweSidMode> sidMode,
  Pointer<Double> xx,
  Pointer<Int32> flagsUsed,
  Pointer<Utf8> errBuf,
  int errCap,
);

@Native<
  Int32 Function(
    Pointer<Void>,
    Double,
    Int32,
    Int32,
    Int32,
    Pointer<Double>,
    Pointer<Int32>,
    Pointer<Utf8>,
    Size,
  )
>(symbol: 'swisseph_calc_pctr')
external int swissephCalcPctr(
  Pointer<Void> handle,
  double tjdEt,
  int ipl,
  int iplctr,
  int iflag,
  Pointer<Double> xx,
  Pointer<Int32> flagsUsed,
  Pointer<Utf8> errBuf,
  int errCap,
);

// ---------------------------------------------------------------------------
// Date/time functions (handle-free unless noted)
// ---------------------------------------------------------------------------

@Native<Double Function(Int32, Int32, Int32, Double, Int32)>(
  symbol: 'swisseph_julday',
)
external double swissephJulday(
  int year,
  int month,
  int day,
  double hour,
  int gregflag,
);

@Native<
  Void Function(
    Double,
    Int32,
    Pointer<Int32>,
    Pointer<Int32>,
    Pointer<Int32>,
    Pointer<Double>,
  )
>(symbol: 'swisseph_revjul')
external void swissephRevjul(
  double jd,
  int gregflag,
  Pointer<Int32> year,
  Pointer<Int32> month,
  Pointer<Int32> day,
  Pointer<Double> hour,
);

@Native<
  Int32 Function(
    Int32,
    Int32,
    Int32,
    Double,
    Int8,
    Pointer<Double>,
    Pointer<Utf8>,
    Size,
  )
>(symbol: 'swisseph_date_conversion')
external int swissephDateConversion(
  int year,
  int month,
  int day,
  double hour,
  int cal,
  Pointer<Double> tjd,
  Pointer<Utf8> errBuf,
  int errCap,
);

@Native<Int32 Function(Double)>(symbol: 'swisseph_day_of_week')
external int swissephDayOfWeek(double jd);

@Native<
  Void Function(
    Int32,
    Int32,
    Int32,
    Int32,
    Int32,
    Double,
    Double,
    Pointer<Int32>,
    Pointer<Int32>,
    Pointer<Int32>,
    Pointer<Int32>,
    Pointer<Int32>,
    Pointer<Double>,
  )
>(symbol: 'swisseph_utc_time_zone')
external void swissephUtcTimeZone(
  int iyear,
  int imonth,
  int iday,
  int ihour,
  int imin,
  double dsec,
  double dTimezone,
  Pointer<Int32> oyear,
  Pointer<Int32> omonth,
  Pointer<Int32> oday,
  Pointer<Int32> ohour,
  Pointer<Int32> omin,
  Pointer<Double> osec,
);

@Native<
  Int32 Function(
    Pointer<Void>,
    Int32,
    Int32,
    Int32,
    Int32,
    Int32,
    Double,
    Int32,
    Pointer<Double>,
    Pointer<Utf8>,
    Size,
  )
>(symbol: 'swisseph_utc_to_jd')
external int swissephUtcToJd(
  Pointer<Void> handle,
  int year,
  int month,
  int day,
  int hour,
  int min,
  double sec,
  int gregflag,
  Pointer<Double> dret,
  Pointer<Utf8> errBuf,
  int errCap,
);

@Native<
  Void Function(
    Pointer<Void>,
    Double,
    Int32,
    Pointer<Int32>,
    Pointer<Int32>,
    Pointer<Int32>,
    Pointer<Int32>,
    Pointer<Int32>,
    Pointer<Double>,
  )
>(symbol: 'swisseph_jdet_to_utc')
external void swissephJdetToUtc(
  Pointer<Void> handle,
  double tjdEt,
  int gregflag,
  Pointer<Int32> year,
  Pointer<Int32> month,
  Pointer<Int32> day,
  Pointer<Int32> hour,
  Pointer<Int32> min,
  Pointer<Double> sec,
);

@Native<
  Void Function(
    Pointer<Void>,
    Double,
    Int32,
    Pointer<Int32>,
    Pointer<Int32>,
    Pointer<Int32>,
    Pointer<Int32>,
    Pointer<Int32>,
    Pointer<Double>,
  )
>(symbol: 'swisseph_jdut1_to_utc')
external void swissephJdut1ToUtc(
  Pointer<Void> handle,
  double tjdUt,
  int gregflag,
  Pointer<Int32> year,
  Pointer<Int32> month,
  Pointer<Int32> day,
  Pointer<Int32> hour,
  Pointer<Int32> min,
  Pointer<Double> sec,
);

@Native<Double Function(Pointer<Void>, Double)>(symbol: 'swisseph_deltat')
external double swissephDeltat(Pointer<Void> handle, double tjdUt);

@Native<
  Int32 Function(Pointer<Void>, Double, Pointer<Double>, Pointer<Utf8>, Size)
>(symbol: 'swisseph_time_equ')
external int swissephTimeEqu(
  Pointer<Void> handle,
  double tjdUt,
  Pointer<Double> e,
  Pointer<Utf8> errBuf,
  int errCap,
);

@Native<
  Int32 Function(
    Pointer<Void>,
    Double,
    Double,
    Pointer<Double>,
    Pointer<Utf8>,
    Size,
  )
>(symbol: 'swisseph_lmt_to_lat')
external int swissephLmtToLat(
  Pointer<Void> handle,
  double tjdLmt,
  double geolon,
  Pointer<Double> tjdLat,
  Pointer<Utf8> errBuf,
  int errCap,
);

@Native<
  Int32 Function(
    Pointer<Void>,
    Double,
    Double,
    Pointer<Double>,
    Pointer<Utf8>,
    Size,
  )
>(symbol: 'swisseph_lat_to_lmt')
external int swissephLatToLmt(
  Pointer<Void> handle,
  double tjdLat,
  double geolon,
  Pointer<Double> tjdLmt,
  Pointer<Utf8> errBuf,
  int errCap,
);

@Native<
  Int32 Function(Pointer<Void>, Int32, Pointer<Utf8>, Size, Pointer<Utf8>, Size)
>(symbol: 'swisseph_get_planet_name')
external int swissephGetPlanetName(
  Pointer<Void> handle,
  int ipl,
  Pointer<Utf8> buf,
  int cap,
  Pointer<Utf8> errBuf,
  int errCap,
);

@Native<
  Void Function(
    Double,
    Int32,
    Pointer<Int32>,
    Pointer<Int32>,
    Pointer<Int32>,
    Pointer<Double>,
    Pointer<Int32>,
  )
>(symbol: 'swisseph_split_deg')
external void swissephSplitDeg(
  double ddeg,
  int roundflag,
  Pointer<Int32> deg,
  Pointer<Int32> min,
  Pointer<Int32> sec,
  Pointer<Double> secfr,
  Pointer<Int32> sign,
);

// ---------------------------------------------------------------------------
// Houses & Gauquelin
// ---------------------------------------------------------------------------

@Native<
  Int32 Function(
    Pointer<Void>,
    Double,
    Int32,
    Double,
    Double,
    Int32,
    Pointer<Double>,
    Pointer<Double>,
    Pointer<Double>,
    Pointer<Double>,
    Pointer<Utf8>,
    Size,
  )
>(symbol: 'swisseph_houses_ex2')
external int swissephHousesEx2(
  Pointer<Void> handle,
  double tjdUt,
  int iflag,
  double geolat,
  double geolon,
  int hsys,
  Pointer<Double> cusps,
  Pointer<Double> ascmc,
  Pointer<Double> cuspSpeed,
  Pointer<Double> ascmcSpeed,
  Pointer<Utf8> errBuf,
  int errCap,
);

@Native<
  Int32 Function(
    Double,
    Double,
    Double,
    Int32,
    Pointer<Double>,
    Pointer<Double>,
    Pointer<Double>,
    Pointer<Double>,
    Pointer<Double>,
    Pointer<Utf8>,
    Size,
  )
>(symbol: 'swisseph_houses_armc_ex2')
external int swissephHousesArmcEx2(
  double armc,
  double geolat,
  double eps,
  int hsys,
  Pointer<Double> sundec,
  Pointer<Double> cusps,
  Pointer<Double> ascmc,
  Pointer<Double> cuspSpeed,
  Pointer<Double> ascmcSpeed,
  Pointer<Utf8> errBuf,
  int errCap,
);

@Native<
  Int32 Function(
    Double,
    Double,
    Double,
    Int32,
    Pointer<Double>,
    Pointer<Double>,
    Pointer<Double>,
    Pointer<Utf8>,
    Size,
  )
>(symbol: 'swisseph_house_pos')
external int swissephHousePos(
  double armc,
  double geolat,
  double eps,
  int hsys,
  Pointer<Double> xpin,
  Pointer<Double> sundec,
  Pointer<Double> hpos,
  Pointer<Utf8> errBuf,
  int errCap,
);

@Native<Int32 Function(Int32, Pointer<Utf8>, Size, Pointer<Utf8>, Size)>(
  symbol: 'swisseph_house_name',
)
external int swissephHouseName(
  int hsys,
  Pointer<Utf8> buf,
  int cap,
  Pointer<Utf8> errBuf,
  int errCap,
);

@Native<
  Int32 Function(
    Pointer<Void>,
    Double,
    Int32,
    Pointer<Utf8>,
    Int32,
    Int32,
    Pointer<Double>,
    Double,
    Double,
    Pointer<Double>,
    Pointer<Utf8>,
    Size,
  )
>(symbol: 'swisseph_gauquelin_sector')
external int swissephGauquelinSector(
  Pointer<Void> handle,
  double tjdUt,
  int ipl,
  Pointer<Utf8> starname,
  int iflag,
  int imeth,
  Pointer<Double> geopos,
  double atpress,
  double attemp,
  Pointer<Double> dgsect,
  Pointer<Utf8> errBuf,
  int errCap,
);

// ---------------------------------------------------------------------------
// Ayanamsa
// ---------------------------------------------------------------------------

@Native<
  Int32 Function(
    Pointer<Void>,
    Double,
    Int32,
    Pointer<SweSidMode>,
    Pointer<Double>,
    Pointer<Int32>,
    Pointer<Utf8>,
    Size,
  )
>(symbol: 'swisseph_get_ayanamsa_ex')
external int swissephGetAyanamsaEx(
  Pointer<Void> handle,
  double tjdEt,
  int iflag,
  Pointer<SweSidMode> sidMode,
  Pointer<Double> daya,
  Pointer<Int32> flagsUsed,
  Pointer<Utf8> errBuf,
  int errCap,
);

@Native<
  Int32 Function(
    Pointer<Void>,
    Double,
    Int32,
    Pointer<SweSidMode>,
    Pointer<Double>,
    Pointer<Int32>,
    Pointer<Utf8>,
    Size,
  )
>(symbol: 'swisseph_get_ayanamsa_ex_ut')
external int swissephGetAyanamsaExUt(
  Pointer<Void> handle,
  double tjdUt,
  int iflag,
  Pointer<SweSidMode> sidMode,
  Pointer<Double> daya,
  Pointer<Int32> flagsUsed,
  Pointer<Utf8> errBuf,
  int errCap,
);

@Native<Double Function(Pointer<Void>, Double, Pointer<SweSidMode>)>(
  symbol: 'swisseph_get_ayanamsa',
)
external double swissephGetAyanamsa(
  Pointer<Void> handle,
  double tjdEt,
  Pointer<SweSidMode> sidMode,
);

@Native<Double Function(Pointer<Void>, Double, Pointer<SweSidMode>)>(
  symbol: 'swisseph_get_ayanamsa_ut',
)
external double swissephGetAyanamsaUt(
  Pointer<Void> handle,
  double tjdUt,
  Pointer<SweSidMode> sidMode,
);

@Native<Int32 Function(Int32, Pointer<Utf8>, Size, Pointer<Utf8>, Size)>(
  symbol: 'swisseph_get_ayanamsa_name',
)
external int swissephGetAyanamsaName(
  int sidModeRaw,
  Pointer<Utf8> buf,
  int cap,
  Pointer<Utf8> errBuf,
  int errCap,
);

// ---------------------------------------------------------------------------
// Eclipses & occultations
// ---------------------------------------------------------------------------

@Native<
  Int32 Function(
    Pointer<Void>,
    Double,
    Int32,
    Pointer<Double>,
    Pointer<Double>,
    Pointer<Utf8>,
    Size,
  )
>(symbol: 'swisseph_sol_eclipse_where')
external int swissephSolEclipseWhere(
  Pointer<Void> handle,
  double tjdUt,
  int ifl,
  Pointer<Double> geopos,
  Pointer<Double> attr,
  Pointer<Utf8> errBuf,
  int errCap,
);

@Native<
  Int32 Function(
    Pointer<Void>,
    Double,
    Int32,
    Pointer<Double>,
    Pointer<Double>,
    Pointer<Utf8>,
    Size,
  )
>(symbol: 'swisseph_sol_eclipse_how')
external int swissephSolEclipseHow(
  Pointer<Void> handle,
  double tjdUt,
  int ifl,
  Pointer<Double> geopos,
  Pointer<Double> attr,
  Pointer<Utf8> errBuf,
  int errCap,
);

@Native<
  Int32 Function(
    Pointer<Void>,
    Double,
    Int32,
    Int32,
    Int32,
    Pointer<Double>,
    Pointer<Utf8>,
    Size,
  )
>(symbol: 'swisseph_sol_eclipse_when_glob')
external int swissephSolEclipseWhenGlob(
  Pointer<Void> handle,
  double tjdStart,
  int ifl,
  int ifltype,
  int backward,
  Pointer<Double> tret,
  Pointer<Utf8> errBuf,
  int errCap,
);

@Native<
  Int32 Function(
    Pointer<Void>,
    Double,
    Int32,
    Pointer<Double>,
    Int32,
    Pointer<Double>,
    Pointer<Double>,
    Pointer<Utf8>,
    Size,
  )
>(symbol: 'swisseph_sol_eclipse_when_loc')
external int swissephSolEclipseWhenLoc(
  Pointer<Void> handle,
  double tjdStart,
  int ifl,
  Pointer<Double> geopos,
  int backward,
  Pointer<Double> tret,
  Pointer<Double> attr,
  Pointer<Utf8> errBuf,
  int errCap,
);

@Native<
  Int32 Function(
    Pointer<Void>,
    Double,
    Int32,
    Pointer<Double>,
    Pointer<Double>,
    Pointer<Utf8>,
    Size,
  )
>(symbol: 'swisseph_lun_eclipse_how')
external int swissephLunEclipseHow(
  Pointer<Void> handle,
  double tjdUt,
  int ifl,
  Pointer<Double> geopos,
  Pointer<Double> attr,
  Pointer<Utf8> errBuf,
  int errCap,
);

@Native<
  Int32 Function(
    Pointer<Void>,
    Double,
    Int32,
    Int32,
    Int32,
    Pointer<Double>,
    Pointer<Utf8>,
    Size,
  )
>(symbol: 'swisseph_lun_eclipse_when')
external int swissephLunEclipseWhen(
  Pointer<Void> handle,
  double tjdStart,
  int ifl,
  int ifltype,
  int backward,
  Pointer<Double> tret,
  Pointer<Utf8> errBuf,
  int errCap,
);

@Native<
  Int32 Function(
    Pointer<Void>,
    Double,
    Int32,
    Pointer<Double>,
    Int32,
    Pointer<Double>,
    Pointer<Double>,
    Pointer<Utf8>,
    Size,
  )
>(symbol: 'swisseph_lun_eclipse_when_loc')
external int swissephLunEclipseWhenLoc(
  Pointer<Void> handle,
  double tjdStart,
  int ifl,
  Pointer<Double> geopos,
  int backward,
  Pointer<Double> tret,
  Pointer<Double> attr,
  Pointer<Utf8> errBuf,
  int errCap,
);

@Native<
  Int32 Function(
    Pointer<Void>,
    Double,
    Int32,
    Pointer<Utf8>,
    Int32,
    Pointer<Double>,
    Pointer<Double>,
    Pointer<Utf8>,
    Size,
  )
>(symbol: 'swisseph_lun_occult_where')
external int swissephLunOccultWhere(
  Pointer<Void> handle,
  double tjdUt,
  int ipl,
  Pointer<Utf8> starname,
  int ifl,
  Pointer<Double> geopos,
  Pointer<Double> attr,
  Pointer<Utf8> errBuf,
  int errCap,
);

@Native<
  Int32 Function(
    Pointer<Void>,
    Double,
    Int32,
    Pointer<Utf8>,
    Int32,
    Int32,
    Int32,
    Pointer<Double>,
    Pointer<Utf8>,
    Size,
  )
>(symbol: 'swisseph_lun_occult_when_glob')
external int swissephLunOccultWhenGlob(
  Pointer<Void> handle,
  double tjdStart,
  int ipl,
  Pointer<Utf8> starname,
  int ifl,
  int ifltype,
  int backward,
  Pointer<Double> tret,
  Pointer<Utf8> errBuf,
  int errCap,
);

@Native<
  Int32 Function(
    Pointer<Void>,
    Double,
    Int32,
    Pointer<Utf8>,
    Int32,
    Pointer<Double>,
    Int32,
    Pointer<Double>,
    Pointer<Double>,
    Pointer<Utf8>,
    Size,
  )
>(symbol: 'swisseph_lun_occult_when_loc')
external int swissephLunOccultWhenLoc(
  Pointer<Void> handle,
  double tjdStart,
  int ipl,
  Pointer<Utf8> starname,
  int ifl,
  Pointer<Double> geopos,
  int backward,
  Pointer<Double> tret,
  Pointer<Double> attr,
  Pointer<Utf8> errBuf,
  int errCap,
);
