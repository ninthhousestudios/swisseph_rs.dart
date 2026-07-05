# swisseph_rs

Dart bindings to the pure-Rust Swiss Ephemeris port (`swisseph-rs`), built as a
drop-in replacement for `swisseph.dart` (the C-backed bindings). Directory name
`swisseph.rs.dart`; pub package name `swisseph_rs`.

## Language

**Drop-in contract**:
The promise that any code written against swisseph.dart runs unchanged (modulo
import line) with observable behavior matching C 2.10.03 within documented
tolerance classes; API growth is additive-only.
_Avoid_: "compatible", "API parity" (both weaker than the contract)

**Compat baseline**:
C Swiss Ephemeris 2.10.03 — the version swisseph-rs is bit-compatible with and
the version swisseph.dart vendors; `version()` reports it.
_Avoid_: "the C version"

**Engine version**:
The swisseph-rs crate version actually performing calculations, exposed via the
additive `engineVersion` getter.

**Facade**:
The `SwissEph` class emulating swisseph.dart's stateful API (set-then-call) on
top of the stateless Rust engine.

**Handle**:
The opaque `SweEphemeris*` from `swisseph_new` — immutable, `Send + Sync`,
owned by one `SwissEph` instance, rebuilt only on rebuild triggers.

**Rebuild trigger**:
A setter or event whose value lives in `SweConfig` and therefore invalidates
the handle: `setEphePath`, `setJplFile`, `setTidAcc`, `setDeltaTUserdef`,
`setAstroModels`, and auto-registration of a new asteroid.

**Auto-registration**:
The facade's C-parity emulation of lazy asteroid file opening: the first calc
of an undeclared asteroid/planet-moon body grows the declared set and rebuilds
the handle transparently (the stateless engine opens files only at
construction).

**Agreement class**:
The tolerance tier a compared value belongs to in the differential harness:
*bitwise* (pure math), *positional* (1e-9°), *boundary* (documented stateless
artifacts: deflection speed 1e-7°, Moshier osculating node speed 5e-6°/day,
SPEED3 at file boundaries), or *search* (iterative event-finding epsilons). A
green harness is the normative test of the drop-in contract.

**Per-call state**:
Facade-held config passed as FFI parameters on each call rather than baked into
the handle: sidereal mode, topocentric position, lapse rate.

**Owner**:
A `SwissEph` instance that created its handle; `close()` frees only owned
handles.

**View**:
A `SwissEph` created from another instance's handle address
(`SwissEph.view(addr)`) — shares the handle for calculation, keeps its own
per-call state, and detaches via copy-on-write if it hits a rebuild trigger.
Native-only.

**Default ephe path**:
When `setEphePath` was never called, the facade uses `SE_EPHE_PATH` from the
environment (native only), matching C. Explicit `setEphePath` always wins.

## Relationships

- A **SwissEph instance** owns at most one live **Handle**
- A **Rebuild trigger** invalidates the **Handle**; the next FFI-touching call
  lazily reconstructs it from **Facade** state
- **Per-call state** never touches the **Handle**
- A **View** shares an **Owner**'s handle until it hits a **Rebuild trigger**
  (including **auto-registration**), at which point it detaches into an
  **Owner** of its own handle
- Every compared value in the differential harness belongs to exactly one
  **Agreement class**

## Example dialogue

> **Dev:** "Does `setSidMode` rebuild the **handle**?"
> **Domain expert:** "No — sidereal mode is **per-call state**; only the four
> **rebuild triggers** invalidate the handle. That's why `setSidMode` in a hot
> loop costs nothing."

## Flagged ambiguities

- "version" was overloaded — resolved: `version()` returns the **compat
  baseline** ("2.10.03"); `engineVersion` returns the Rust crate version.
- "isolate safety" means something weaker here than in swisseph.dart: there is
  no shared C global state at all, so the copy-the-.so hack and the
  "re-set config after every await" discipline are unnecessary (but harmless).
  Facade state is per-instance Dart data and cannot drift.
- "drop-in" does NOT include performance parity (Rust Swiss-file single-call is
  ~2.6× C) or exact error-message text — only observable calculation behavior
  and API shape.
