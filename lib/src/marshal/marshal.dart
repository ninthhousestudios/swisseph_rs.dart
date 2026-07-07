import 'dart:ffi';

import 'package:ffi/ffi.dart';

import '../bindings/bindings.dart';
import '../types/types.dart';

// ---------------------------------------------------------------------------
// Singleton bindings — loaded once, shared across all Ephemeris instances.
// ---------------------------------------------------------------------------

late final SwissephBindings _bindings;
var _bindingsLoaded = false;

SwissephBindings _ensureBindings() {
  if (!_bindingsLoaded) {
    _bindings = loadBindings();
    _bindingsLoaded = true;
  }
  return _bindings;
}

/// Native function pointer for [NativeFinalizer] registration.
Pointer<NativeFinalizerFunction> get swissephFreeFnPtr =>
    _ensureBindings().swissephFreeFnPtr.cast();

// ---------------------------------------------------------------------------
// Error handling
// ---------------------------------------------------------------------------

const _errBufSize = 256;

/// Construct a typed [SweException] from an FFI error code and message.
/// Codes match `swisseph-ffi/src/error.rs::SweErrorCode`.
SweException exceptionFromCode(int code, String message) => switch (code) {
  -1 => InvalidBodyException(message),
  -2 => UnsupportedFlagsException(message),
  -3 => InvalidHouseSystemException(message),
  -4 => InvalidSiderealModeException(message),
  -5 => InvalidCalendarTypeException(message),
  -6 => InvalidDateException(message),
  -7 => EphemerisNotAvailableException(message),
  -8 => BeyondEphemerisLimitsException(message),
  -9 => FileNotFoundException(message),
  -10 => FileFormatException(message),
  -11 => CircumpolarBodyException(message),
  -12 => InvalidTimeException(message),
  -13 => InvalidLeapSecondException(message),
  -14 => UnsupportedEphemerisException(message),
  -15 => SiderealModeRequiresFixedStarsException(message),
  -16 => CErrorException(message),
  -90 => EnginePanicException(message),
  -91 => InvalidArgException(message),
  -99 => InternalException(message),
  _ => UnknownSweException(code, message),
};

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
  c.ref.ephemerisSource = config.ephemerisSource.index;
  c.ref.ephePath = config.ephePath != null
      ? config.ephePath!.toNativeUtf8(allocator: arena)
      : nullptr;
  c.ref.jplFilename = nullptr;
  c.ref.leapSecondsFile = nullptr;
  c.ref.hasSidereal = config.siderealMode != null;
  c.ref.sidMode = config.siderealMode?.mode ?? 0;
  c.ref.sidT0 = config.siderealMode?.t0 ?? 0;
  c.ref.sidAyanT0 = config.siderealMode?.ayanT0 ?? 0;
  c.ref.hasTopo = config.topographic != null;
  c.ref.geolon = config.topographic?.longitude ?? 0;
  c.ref.geolat = config.topographic?.latitude ?? 0;
  c.ref.altitude = config.topographic?.altitude ?? 0;
  c.ref.tidalAcceleration = double.nan;
  c.ref.deltaTUserdef = double.nan;
  c.ref.asteroidNumbers = nullptr;
  c.ref.asteroidNumbersLen = 0;
  c.ref.planetMoonNumbers = nullptr;
  c.ref.planetMoonNumbersLen = 0;
  c.ref.extraLeapSeconds = nullptr;
  c.ref.extraLeapSecondsLen = 0;
  c.ref.astroModelPrecLongterm = 0;
  c.ref.astroModelPrecShortterm = 0;
  c.ref.astroModelNutation = 0;
  c.ref.astroModelBias = 0;
  c.ref.astroModelJplhor = 0;
  c.ref.astroModelJplhora = 0;
  c.ref.astroModelSiderealTime = 0;
  c.ref.astroModelDeltaT = 0;
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
  final b = _ensureBindings();
  return using((arena) {
    final sweConfig = marshalConfig(arena, config);
    final errBuf = arena<Uint8>(_errBufSize).cast<Utf8>();
    final out = arena<Pointer<Void>>();
    final code = b.swissephNew(sweConfig, out, errBuf, _errBufSize);
    _checkResult(code, errBuf);
    return out.value;
  });
}

/// Release an ephemeris handle. Null-safe on the native side.
void freeHandle(Pointer<Void> handle) {
  _ensureBindings().swissephFree(handle);
}

/// Call `swisseph_calc_ut` and return a typed [CalcResult].
CalcResult calcUt(Pointer<Void> handle, double tjdUt, int ipl, int iflag) {
  final b = _ensureBindings();
  return using((arena) {
    final xx = arena<Double>(6);
    final flagsUsed = arena<Int32>();
    final errBuf = arena<Uint8>(_errBufSize).cast<Utf8>();
    final code = b.swissephCalcUt(
      handle,
      tjdUt,
      ipl,
      iflag,
      nullptr, // geopos — no per-call topocentric override
      nullptr, // sid_mode — tropical
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
  final ptr = _ensureBindings().swissephVersion();
  return ptr.toDartString();
}
