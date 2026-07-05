# Enforcement ledger

Total routing of every architectural claim in the PRD
([`docs/prd-swisseph-rs-v1.md`](./prd-swisseph-rs-v1.md), yojana
`swisseph-rs-dart/1`). One claim, one mechanism. A claim with no row is a
routing bug.

Buckets: (a) live sutra constraint · (b) deferred sutra constraint with
binding trigger · (c) CLAUDE.md invariant / review checklist · (d)
test-asserted, pointed at its implementing task.

| # | Claim (quote) | PRD section | Bucket | Mechanism | Status |
|---|---|---|---|---|---|
| 1 | "same ~93-method SwissEph API… API growth is additive-only (drop-in contract)" | Solution | (d) | Differential harness + ported suite | test (tasks /16, /13) |
| 2 | "config_state… module interface contains no FFI types (pure Dart, isolation-testable)" | Impl. Decisions | (b) | `forbidden_dep` config_state → bindings/ffi seam | deferred (at scaffold, /2) |
| 3 | "bindings — typed FFI lookups… purely mechanical marshalling declarations, no logic" | Impl. Decisions | (c) | CLAUDE.md invariant; R1/R2 review checklist | routed → CLAUDE.md |
| 4 | "the SwissEph facade — ~93 thin method bodies… proven by the test legs" | Impl. Decisions | (c) | CLAUDE.md invariant | routed → CLAUDE.md |
| 5 | Handle construction is config_state's single point of contact (`swisseph_new` never called elsewhere) | ADR-0001 | (c) | CLAUDE.md invariant — not glob-expressible (facade and config_state both legitimately import bindings) | routed → CLAUDE.md |
| 6 | "loader seams (native/web conditional imports)" — web/native halves never cross-import | Impl. Decisions | (b) | `forbidden_dep` web↛native, native↛web; expressibility check at scaffold, fallback (c) | deferred (at scaffold, /2) |
| 7 | "the build hook runs cargo against a shim crate pinning swisseph-ffi to a git rev" — upgrades are deliberate pin bumps | Impl. Decisions | (c) | CLAUDE.md process invariant | routed → CLAUDE.md |
| 8 | "engine switching never rebuilds the handle" | Impl. Decisions | (d) | config_state unit tests | test (task /4) |
| 9 | "SE_EPHE_PATH from the environment is the default ephe path… explicit setEphePath always wins" | Impl. Decisions | (d) | config_state unit tests — NB the differential harness structurally cannot catch this (it always sets paths explicitly) | test (task /4) |
| 10 | "version() returns the compat baseline; engineVersion returns the Rust crate version" | Impl. Decisions | (d) | Tracer test | test (task /3) |
| 11 | "error mapping preserves swisseph.dart observable behavior" (SweException sites, sentinels, riseTrans −2, eclipse bitmasks) | Impl. Decisions | (d) | Ported eclipse/crossing/suite tests | test (task /10) |
| 12 | "a view… detaches via copy-on-write when it hits a rebuild trigger, and never frees handles it does not own" | Impl. Decisions | (d) | config_state units + isolate test | test (tasks /4, /15) |
| 13 | "every compared value is explicitly assigned an agreement class; unclassified comparisons fail the harness by design" | Testing Decisions | (d) | Harness self-check | test (task /16) |
| 14 | "JPL ephemeris on web" out of scope; sharing API native-only (UnsupportedError on web) | Out of Scope / Impl. | (d) | Web tests | test (task /17) |
| 15 | No import cycles in package source | skill default | (b) | `no_cycles` on lib/src | deferred (at scaffold, /2) |
| 16 | Fan-in guardrail on lib/src | skill default | (b) | `max_fan_in`, threshold from observed data | deferred (at R1 tend, /6; revisit at R2 tend, /14) |

## Seed-time verification (2026-07-05)

Live constraints: **0** (all sutra-expressible claims deferred — no code
exists, so any glob would be inert). rules.toml parses; the deferred blocks
are commented under their `# TRIGGER:` lines. The scaffold task's acceptance
criterion is that the at-scaffold blocks uncomment cleanly and every glob
binds (no `dead_constraint` warnings).

## Maintenance

- **New track PRDs**: re-run vidhi-sutra-seed additively — append rows and
  constraints with their own provenance. Never regenerate from scratch.
- **Rebinding events**: at scaffold (/2) and each tend checkpoint (/6, /14),
  check off the corresponding rows' Status column here.
- **Guard from first commit**: blocking rules are live the moment their globs
  bind. Per-task `sutra_review` runs in vidhi-review; bucket-(c) rows are
  review-checklist material.
- **Tend schedule**: vidhi-sutra-tend runs at R1 (swisseph-rs-dart/6 —
  interiors + convention triage + initial fan-in) and R2 (swisseph-rs-dart/14
  — fan-in with full-surface data, re-triage). R3 (swisseph-rs-dart/19)
  verifies no orphaned triggers remain.
