import 'dart:ffi';
import 'dart:io' show Platform;

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
// FFI typedefs — C signature then Dart signature for each function.
// ---------------------------------------------------------------------------

// swisseph_version() -> *const c_char
typedef _SwissephVersionC = Pointer<Utf8> Function();
typedef _SwissephVersionDart = Pointer<Utf8> Function();

// swisseph_config_default(config: *mut SweConfig)
typedef _SwissephConfigDefaultC = Void Function(Pointer<SweConfig> config);
typedef _SwissephConfigDefaultDart = void Function(Pointer<SweConfig> config);

// swisseph_new(config, out, err_buf, err_cap) -> i32
typedef _SwissephNewC =
    Int32 Function(
      Pointer<SweConfig> config,
      Pointer<Pointer<Void>> out,
      Pointer<Utf8> errBuf,
      Size errCap,
    );
typedef _SwissephNewDart =
    int Function(
      Pointer<SweConfig> config,
      Pointer<Pointer<Void>> out,
      Pointer<Utf8> errBuf,
      int errCap,
    );

// swisseph_free(handle)
typedef _SwissephFreeC = Void Function(Pointer<Void> handle);
typedef _SwissephFreeDart = void Function(Pointer<Void> handle);

// swisseph_share(handle, out, err_buf, err_cap) -> i32
typedef _SwissephShareC =
    Int32 Function(
      Pointer<Void> handle,
      Pointer<Pointer<Void>> out,
      Pointer<Utf8> errBuf,
      Size errCap,
    );
typedef _SwissephShareDart =
    int Function(
      Pointer<Void> handle,
      Pointer<Pointer<Void>> out,
      Pointer<Utf8> errBuf,
      int errCap,
    );

// swisseph_calc_ut(handle, tjd_ut, ipl, iflag, geopos, sid_mode,
//                  xx, flags_used, err_buf, err_cap) -> i32
typedef _SwissephCalcUtC =
    Int32 Function(
      Pointer<Void> handle,
      Double tjdUt,
      Int32 ipl,
      Int32 iflag,
      Pointer<Double> geopos,
      Pointer<SweSidMode> sidMode,
      Pointer<Double> xx,
      Pointer<Int32> flagsUsed,
      Pointer<Utf8> errBuf,
      Size errCap,
    );
typedef _SwissephCalcUtDart =
    int Function(
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

// ---------------------------------------------------------------------------
// Bindings class — typed lookups, zero logic.
// ---------------------------------------------------------------------------

/// Native FFI bindings to swisseph-ffi. Declarations only — no logic.
final class SwissephBindings {
  final DynamicLibrary _lib;

  SwissephBindings(this._lib);

  late final swissephVersion = _lib
      .lookupFunction<_SwissephVersionC, _SwissephVersionDart>(
        'swisseph_version',
      );

  late final swissephConfigDefault = _lib
      .lookupFunction<_SwissephConfigDefaultC, _SwissephConfigDefaultDart>(
        'swisseph_config_default',
      );

  late final swissephNew = _lib.lookupFunction<_SwissephNewC, _SwissephNewDart>(
    'swisseph_new',
  );

  late final swissephFree = _lib
      .lookupFunction<_SwissephFreeC, _SwissephFreeDart>('swisseph_free');

  late final swissephShare = _lib
      .lookupFunction<_SwissephShareC, _SwissephShareDart>('swisseph_share');

  late final swissephCalcUt = _lib
      .lookupFunction<_SwissephCalcUtC, _SwissephCalcUtDart>(
        'swisseph_calc_ut',
      );

  /// Raw native function pointer for [NativeFinalizer].
  late final swissephFreeFnPtr = _lib
      .lookup<NativeFunction<Void Function(Pointer<Void>)>>('swisseph_free');
}

/// Load the native swisseph_rs library.
SwissephBindings loadBindings() {
  final name = Platform.isLinux
      ? 'libswisseph_rs_dart.so'
      : Platform.isMacOS
      ? 'libswisseph_rs_dart.dylib'
      : 'swisseph_rs_dart.dll';
  final lib = DynamicLibrary.open(name);
  return SwissephBindings(lib);
}
