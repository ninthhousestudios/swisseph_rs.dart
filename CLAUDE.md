# swisseph_rs

Drop-in Dart replacement for swisseph.dart, backed by the stateless pure-Rust
swisseph-rs engine via swisseph-ffi. Design docs: `CONTEXT.md` (domain
language — use its vocabulary), `docs/adr/0001` (the facade decision),
`docs/prd-swisseph-rs-v1.md` (PRD), `docs/enforcement-ledger.md` (claim →
enforcement routing). Tracker: yojana project `swisseph-rs-dart`.

## Invariants (enforcement-ledger bucket c — reviewed, not machine-checked)

### API discipline

- **Drop-in contract**: never change or remove a public member that exists in
  swisseph.dart; API growth is additive-only. Behavior parity is normatively
  tested by the differential harness — do not "fix" observable behavior to be
  more sensible than C 2.10.03.
- **bindings.dart is declarations only**: typed FFI lookups and struct
  definitions, zero logic. Any branching, defaulting, or conversion belongs in
  the facade or config_state (ledger row 3).
- **Facade bodies stay thin**: marshalling, per-call state threading, error
  mapping — never calculation logic (ledger row 4).
- **`swisseph_new` is called from config_state only**: all handle
  construction and lifetime management is config_state's single point of
  contact; the facade acquires handles exclusively through it (ledger row 5).

### Process

- **Engine pin bumps are deliberate**: the rust/ shim crate pins swisseph-ffi
  to a git rev of ninthhousestudios/swisseph-rs. Never float the rev; a bump
  is a reviewed one-line change (ledger row 7).
- **No silent tolerance loosening**: any test tolerance looser than
  swisseph.dart's original must carry a comment naming the documented
  swisseph-rs boundary (deflection speed / Moshier node speed / SPEED3 file
  boundaries). Error-message *text* is not part of the drop-in contract;
  exception *sites* are.
- **Platform seams**: web/native file pairs join only through their
  conditional-import barrel; never cross-import halves (ledger row 6, until
  the sutra constraint binds at scaffold).
