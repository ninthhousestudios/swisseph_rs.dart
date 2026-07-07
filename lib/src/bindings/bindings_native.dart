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
