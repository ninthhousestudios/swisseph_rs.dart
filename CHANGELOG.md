## 0.2.8

- Fixed web builds throwing `TypeError: The provided ArrayBufferView value
  must not be resizable` on every `Ephemeris` construction in current Chrome.
  Under `ALLOW_MEMORY_GROWTH`, WASM memory is exposed as a resizable
  ArrayBuffer, and Web Crypto rejects views backed by one — so the engine's
  first entropy request (16 bytes, inside `swisseph_new`) threw. The WASM
  module loaded fine, so the failure landed on first use rather than at
  startup. Fixed at the source via an `--js-library` override of Emscripten's
  `$initRandomFill` (`wasm/lib-random-fill.js`), so generated glue fills a
  plain buffer and copies. The `.wasm` binary is unchanged.
- Fixed `initializeWasm()` hanging forever instead of throwing when the glue
  script fails to load. The pre-load used `modulePath` verbatim while
  `wasm_ffi` resolves an extensionless path to `<path>.js`, so the documented
  default (`'swisseph_ffi'`) fetched a 404; awaiting only `onLoad` then hung
  indefinitely. The pre-load now mirrors the extension resolution and rejects
  on load error.
- Fixed `initializeWasm()` appending a second `.js` to glue URLs that carry a
  query string, e.g. a cache-busted `swisseph_ffi.js?v=1`. The extension is
  now resolved from the parsed URI's last path segment, matching how
  `wasm_ffi` decides.

Web consumers who added a `crypto.getRandomValues` workaround to their
`index.html` for the resizable-buffer error can remove it after upgrading;
the fix now ships inside the package's WASM glue.

Note for anyone else shipping an Emscripten module: this is not specific to
this package. emcc 6.0.2 still emits an unguarded
`crypto.getRandomValues(HEAPU8.subarray(...))` for non-`SHARED_MEMORY`
builds, so any module built with `ALLOW_MEMORY_GROWTH` hits it on current
Chrome. Bumping the Emscripten SDK does not fix it.

## 0.2.7

- Fixed `nodAps`/`nodApsUt` for numbered asteroids (e.g. Eros 433) with the
  Swiss ephemeris backend. The internal position provider was constructed with
  empty asteroid and planet-moon file lists, causing `EphemerisNotAvailable`
  errors. Also includes `calcPctr` alias normalization for asteroid bodies.
  Bumped swisseph-ffi to `a4cf744`.

## 0.2.6

- Fixed `calcPctr` for main asteroid bodies (Chiron, Pholus, Ceres, Pallas,
  Juno, Vesta). The internal position provider was missing the main asteroid
  file set, causing `BeyondEphemerisLimits` errors for these bodies even when
  `.se1` files were present. Bumped swisseph-ffi to `c3c27cb`.

## 0.2.5

- Fixed asteroid file parsing for MPC numbers > 22767 (e.g. Quaoar 50000).
  2-byte `ipl[]` entries were sign-extended from i16, wrapping body IDs above
  32767 to negative values and causing "ephemeris not available" errors despite
  valid files on disk. Bumped swisseph-ffi to `b6a9f82`.

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
