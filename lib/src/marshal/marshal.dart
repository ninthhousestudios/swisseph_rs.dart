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
