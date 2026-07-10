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
