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
