# Enforcement ledger

Total routing of every architectural claim in PRD v2
([`docs/prd-swisseph-rs-v2.md`](./prd-swisseph-rs-v2.md), yojana
`swisseph-rs-dart/20`). One claim, one mechanism. A claim with no row is a
routing bug.

**Supersession note (2026-07-05)**: this ledger replaces the v1 ledger
(drop-in facade design) per
[ADR-0002](./adr/0002-idiomatic-transliteration-over-drop-in-facade.md).
Retired v1 rows are recorded at the bottom — retirement is explicit, never
silent.

Buckets: (a) live sutra constraint · (b) deferred sutra constraint with
binding trigger · (c) CLAUDE.md invariant / review checklist · (d)
test-asserted, pointed at its implementing task.

| # | Claim (quote) | PRD section | Bucket | Mechanism | Status |
|---|---|---|---|---|---|
| 1 | "every public Dart symbol declares its Rust counterpart… machine-checked totality test" | Impl. Decisions | (d) | Counterpart totality test (public-API walk) | test (/26) |
| 2 | "deviation is legal only via the named systematic divergences" | Impl. Decisions | (c) | CLAUDE.md invariant; R1/R2 review checklist | routed → CLAUDE.md |
| 3 | "types — every pure-Dart declaration… zero FFI imports, isolation-testable" (path seam) | Impl. Decisions | (b) | `forbidden_dep` types↛bindings, types↛marshal | deferred (at scaffold, /21) |
| 4 | types purity re `dart:ffi` (SDK import — not path-expressible in sutra) | Impl. Decisions | (d) | Analyzer assertion in types unit tests | test (/23) |
| 5 | "bindings — FFI declarations only… no logic" | Impl. Decisions | (c) | CLAUDE.md invariant | routed → CLAUDE.md |
| 6 | "marshal — the only meeting point of Dart and FFI types" | Impl. Decisions | (b)+(c) | `forbidden_dep` ephemeris↛bindings (partial teeth); full single-point rule in CLAUDE.md | deferred (at scaffold, /21) + CLAUDE.md |
| 7 | "native/web halves behind conditional-import barrels" — never cross-import | Impl. Decisions | (b) | `forbidden_dep` web↛native ×2; expressibility check at scaffold, fallback (c) | deferred (at scaffold, /21) |
| 8 | "build hook runs cargo against a shim crate pinning swisseph-ffi to an exact git rev" — bumps deliberate | Impl. Decisions | (c) | CLAUDE.md process invariant | routed → CLAUDE.md |
| 9 | "no env vars (`ephePath` explicit)" — SE_EPHE_PATH ignored by design | Impl. Decisions | (d) | Config test: env var set, construction ignores it | test (/23) |
| 10 | "no `version()` method; top-level `engineVersion` reads `swisseph_version`" | Impl. Decisions | (d) | Tracer test | test (/22) |
| 11 | Asteroids declared in config up front; undeclared asteroid throws (auto-registration has no successor) | Impl. Decisions | (d) | Positions family test asserting absence | test (/27) |
| 12 | "`close()` idempotent; use-after-close throws `StateError`; `NativeFinalizer` backstop" | Impl. Decisions | (d) | Tracer + sharing tests | test (/22, /36) |
| 13 | "swisseph_share (internal Arc clone)… every instance owns its handle equally"; any close order safe | Impl. Decisions | (d) | Upstream FFI tests + two-isolate close-order test | test (swisseph-rs/143, /36) |
| 14 | "oracle-map registry… total; undeclared public method fails the self-check" (direct / composite / engine-trusted) | Testing Decisions | (d) | Harness self-check | test (/26) |
| 15 | "every compared value in exactly one agreement class; unclassified comparisons… fail by design" | Testing Decisions | (d) | Harness self-check | test (/26) |
| 16 | No silent tolerance loosening — every boundary-class use names its documented artifact | Testing Decisions | (c) | CLAUDE.md invariant; R2 review focus | routed → CLAUDE.md |
| 17 | No import cycles in package source | skill default | (b) | `no_cycles` on lib/src | deferred (at scaffold, /21) |
| 18 | Fan-in guardrail on lib/src | skill default | (b) | `max_fan_in`, threshold from observed data | deferred (at R1 tend, /25; revisit at R2 tend, /35) |
| 19 | "same public API compiles and runs on web; only the loader seam differs" | Impl./Testing | (d) | Web test leg | test (/37) |
| 20 | "peak RSS bounded consistent with ONE loaded engine" | Testing Decisions | (d) | Stress test | test (/38) |
| 21 | libaditya 545-value dataset green | Testing Decisions | (d) | Dataset runner in standard test invocation | test (/39) |
| 22 | arrow/swe facade contract preserved through the migration | Out of Scope / story 33 | (d) | arrow's existing test suite | test (arjuna/arrow/10) |

## Retired v1 rows (ADR-0002)

| v1 row | Claim | Disposition |
|---|---|---|
| 1 | Drop-in contract (same ~93-method API, additive-only) | Dead — the contract itself was dropped; transliteration rule (rows 1–2) replaces it |
| 2 | config_state module interface contains no FFI types | Succeeded by row 3 (types↛bindings/marshal) — config_state has no successor module |
| 5 | `swisseph_new` called from config_state only | Dead with config_state; handle acquisition is Ephemeris constructor + share(), covered by rows 6, 13 |
| 8 | Engine switching never rebuilds the handle | Dissolved — nothing rebuilds handles in v2 at all (immutable config); per-call engine bits covered by /27 tests |
| 9 | SE_EPHE_PATH honored as default ephe path | Inverted — v2 reads no env vars (row 9) |
| 10 | version() returns compat baseline "2.10.03" | Inverted — no version() method (row 10) |
| 12 | Views detach via copy-on-write, never free unowned handles | Dead problem class — Arc refcounting (row 13) makes all instances co-equal |

## Seed-time verification (2026-07-05, re-seed)

Live constraints: **0** (all sutra-expressible claims deferred — no code
exists, so any glob would be inert). rules.toml parses; the deferred blocks
are commented under their `# TRIGGER:` lines. The scaffold task (/21)
acceptance criterion is that the at-scaffold blocks uncomment cleanly and
every glob binds (no `dead_constraint` warnings).

## Maintenance

- **New track PRDs**: re-run vidhi-sutra-seed additively — append rows and
  constraints with their own provenance. Never regenerate from scratch.
  (Supersession per ADR is the one exception, as this re-seed demonstrates:
  retire rows explicitly with the ADR citation.)
- **Rebinding events**: at scaffold (/21) and each tend checkpoint (/25,
  /35), check off the corresponding rows' Status column here.
- **Guard from first commit**: blocking rules are live the moment their globs
  bind. Per-task `sutra_review` runs in vidhi-review; bucket-(c) rows are
  review-checklist material.
- **Tend schedule**: vidhi-sutra-tend runs at R1 (swisseph-rs-dart/25 —
  interiors + convention triage + initial fan-in) and R2 (swisseph-rs-dart/35
  — fan-in with full-surface data, re-triage). R3 (swisseph-rs-dart/40)
  verifies no orphaned triggers remain.
