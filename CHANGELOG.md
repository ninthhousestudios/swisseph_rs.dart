## 0.2.4

- **Breaking:** `getAyanamsaEx`, `getAyanamsaExWithConfig`, and
  `getAyanamsaUt` now return `({double ayanamsa, CalcFlags flagsUsed})`
  instead of bare `double`, exposing ephemeris-fallback information.

## 0.2.3

- Added `siderealTime` and `siderealTime0` methods on `Ephemeris` for
  Greenwich Apparent Sidereal Time (GAST).
- Added `cotrans` and `cotransWithSpeed` free functions for ecliptic ↔
  equatorial coordinate transformation.
- Bumped swisseph-ffi to `64bc1533` (adds `swisseph_cotrans` /
  `swisseph_cotrans_sp` FFI exports).

## 0.2.2

- Build hook: Android and iOS cross-compilation support. Maps
  `targetOS`/`targetArchitecture` to Rust target triples, wires the NDK
  clang linker for Android, and fails early with an actionable message
  when a `rustup` target is missing. Desktop path unchanged.

## 0.2.1

- Fixed web: `loadEpheFile` threw "Emscripten module not available" because
  the raw Emscripten module instance was never stored for `getEmscriptenFS()`.
  `initializeWasm` now pre-loads the glue script and wraps the factory to
  capture the module in `__swissephRsModule` before `DynamicLibrary.open`
  consumes it.
- Added `web` dependency (used by `loader_web.dart` for script injection).

## 0.2.0

- Added `fixstar2WithConfig` and `fixstar2UtWithConfig` for per-call sidereal
  and topocentric overrides on fixed-star computations.

## 0.1.1

- Added proper copyright notes to LICENSE and source files.

## 0.0.1-dev

- Initial development release.
- Full transliteration of the swisseph-rs Rust API: positions, houses,
  ayanamsa, eclipses, occultations, rise/set, crossings, fixed stars,
  heliacal, phenomena, nodes/orbits, horizon, refraction, date/time.
- Native platforms via Cargo build hook.
- Web platform via prebuilt wasm artifact.
- Cross-isolate engine sharing via `Ephemeris.share()`.
