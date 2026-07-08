# swisseph_rs

Idiomatic Dart transliteration of the [swisseph-rs](https://github.com/ninthhousestudios/swisseph-rs)
Rust API — typed, stateless, isolate-safe Swiss Ephemeris bindings via FFI.

Every public Dart symbol mirrors exactly one `swisseph::*` counterpart
(camelCased), documented with a `/// Counterpart:` dartdoc line. Deviations
from the Rust API follow named
[systematic divergences](https://github.com/ninthhousestudios/swisseph_rs.dart/blob/main/CONTEXT.md)
(thrown exceptions instead of `Result<T, E>`, extension-type flags instead of
bitflags, etc.).

## Quick start

```dart
import 'package:swisseph_rs/swisseph_rs.dart';

void main() {
  final eph = Ephemeris(const EphemerisConfig());

  // Sun position at J2000.0
  final sun = eph.calcUt(
    const JdUt1(2451545.0),
    Body.sun,
    CalcFlags.speed,
  );
  print('Sun longitude: ${sun.longitude}');
  print('Sun speed: ${sun.longitudeSpeed} deg/day');

  // Houses for Delhi
  final houses = eph.houses(
    const JdUt1(2451545.0),
    28.6139,  // latitude
    77.2090,  // longitude
    HouseSystem.placidus,
  );
  print('Ascendant: ${houses.ascmc.ascendant}');

  eph.close();
}
```

## Features

- **Typed API** — `JdUt1`/`JdTt` extension types prevent time-scale mixups;
  `Body`, `CalcFlags`, `HouseSystem`, and 47 `SiderealMode` variants are
  all typed enums or extension types.
- **Immutable configuration** — `EphemerisConfig` is `const`-constructible.
  Sidereal, topographic, and ephemeris-source settings are per-call via
  `*WithConfig` variants, not mutable state.
- **Isolate-safe sharing** — `ephemeris.share()` returns a token sendable
  to another isolate. The underlying engine is refcounted (`Arc`); any close
  order is safe.
- **Native + Web** — Cargo build hook compiles the Rust engine for native
  platforms. Web uses a prebuilt wasm artifact with `initializeWasm()` +
  `loadEpheFile()` for MEMFS-backed ephemeris data.
- **Pure Moshier fallback** — works without any ephemeris files. Point
  `ephePath` at Swiss Ephemeris data files for higher precision.

## API overview

### Ephemeris (instance methods)

| Family | Methods |
|---|---|
| Positions | `calcUt`, `calc`, `calcUtWithConfig`, `calcWithConfig`, `calcPctr` |
| Houses | `houses`, `housesEx2`, `gauquelinSector`, `gauquelinSectorGeometric` |
| Ayanamsa | `getAyanamsa`, `getAyanamsaUt`, `getAyanamsaEx`, `getAyanamsaExWithConfig` |
| Eclipses | `solEclipseWhenGlob`, `solEclipseWhenLoc`, `solEclipseWhere`, `solEclipseHow`, `lunEclipseWhen`, `lunEclipseWhenLoc`, `lunEclipseHow` |
| Occultations | `lunOccultWhenGlob`, `lunOccultWhenLoc`, `lunOccultWhere` |
| Rise/set | `riseTrans`, `riseTransTrueHor` |
| Crossings | `solcross`, `solcrossUt`, `mooncross`, `mooncrossUt`, `mooncrossNode`, `mooncrossNodeUt`, `helioCross`, `helioCrossUt` |
| Fixed stars | `fixstar2`, `fixstar2Ut`, `fixstar2Mag` |
| Heliacal | `heliacalUt`, `heliacalPhenoUt`, `visLimitMag`, `heliacalAngle`, `topoArcusVisionis` |
| Phenomena | `phenoUt`, `pheno`, `phenoUtWithConfig`, `phenoWithConfig` |
| Nodes/orbits | `nodApsUt`, `nodAps`, `getOrbitalElements`, `orbitMaxMinTrueDistance` |
| Horizon | `azalt`, `azaltRev` |
| Date/time | `deltaT`, `timeEqu`, `lmtToLat`, `latToLmt`, `utcToJd`, `jdetToUtc`, `jdut1ToUtc` |
| Utility | `getPlanetName`, `close`, `share` |

### Free functions

`julday`, `revjul`, `dateConversion`, `dayOfWeek`, `utcTimeZone`,
`splitDegrees`, `normalizeDegrees`, `housesArmc`, `housePos`, `houseName`,
`getAyanamsaName`, `refrac`, `refracExtended`, `engineVersion`

## Platform support

| Platform | Mechanism |
|---|---|
| Linux, macOS, Windows | Cargo build hook compiles `swisseph-ffi` from source |
| Web | `initializeWasm()` + prebuilt `.wasm` artifact |
| iOS, Android | Cargo build hook (same as desktop) |

## Testing

```bash
dart test                         # unit, integration, totality (84 tests)
SWE_EPHE_PATH=ephe dart test      # includes Swiss Ephemeris file tests
dart test -t stress               # 100-isolate stress test (~30 min)
```

### Differential (oracle) tests

The `test_oracle/` directory contains differential tests that compare
swisseph_rs against [swisseph.dart](https://github.com/ninthhousestudios/swisseph.dart)
(the C-based Swiss Ephemeris bindings). To run them, add swisseph as a dev
dependency:

```yaml
# pubspec.yaml dev_dependencies:
swisseph:
  git:
    url: https://github.com/ninthhousestudios/swisseph.dart

# Also add dependency_overrides if there's a hooks version conflict:
dependency_overrides:
  hooks: ^2.0.2
```

Then: `SWE_EPHE_PATH=ephe dart test test_oracle/`

## License

AGPL-3.0-or-later. See [LICENSE](LICENSE).
