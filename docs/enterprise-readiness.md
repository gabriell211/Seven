# Seven Enterprise Readiness

## Current Classification

Seven 0.1.x is an enterprise-evaluable foundation release.

It is suitable for:

- technical due diligence;
- language and runtime review;
- internal prototypes;
- non-critical pilots;
- editor and tooling validation;
- contribution planning.

It is not yet suitable for business-critical production workloads as a final
compiler. The production threshold remains:

```text
seed -> seven0 -> seven -> seven.self
```

with equivalent deterministic output.

## Controls Available Now

- Foundation verifier for bootstrap CLI, conformance, SVBC build envelope,
  smoke execution, debugger behavior, package lock operations, LSP and FFI.
- SHA-256 verification for versioned binary artifacts.
- CI on Windows with PowerShell syntax checks.
- No official JavaScript/TypeScript editor runtime in the language core.
- Dependabot tracking for GitHub Actions.
- CODEOWNERS-based review ownership.
- Public security and support policies.
- Stable diagnostic codes documented in `docs/diagnostics.md`.
- Conformance split into valid and invalid suites.

## Baseline Acceptance Command

Every company evaluation should start with:

```powershell
.\tools\verify-foundation.ps1
```

The expected result is:

```text
falhas: 0
```

For editor intelligence tooling:

```powershell
.\tools\seven-lsp.ps1 -SelfTest -File .\examples\hello.sv
```

## Risk Register

| Area | Current Risk | Required Before Production |
| --- | --- | --- |
| Compiler | Source exists in `.sv`, but self-hosting is not complete | Deterministic `seven.self` rebuild |
| Bootstrap | Windows artifact is checksum-verified | Reproducible binary generation from seed |
| Runtime | Development VM and SVBC envelope are verified | Full VM conformance and sandbox tests |
| Standard library | Contracts and examples exist | Implemented, tested modules with compatibility policy |
| Packages | Lockfile model exists | Registry trust model, hashes and offline cache rules |
| Security | Policy and verifier checks exist | Release signing, SBOM and vulnerability handling drill |
| Tooling | LSP contract and static editor assets exist | Seven-native LSP server and compatibility matrix |
| Market autonomy | Core source roots are guarded against host-language source | Seven-native compiler, runtime, stdlib and primary tooling |

## Enterprise Production Gate

Seven can be considered enterprise production-ready only when all items below
are true:

- self-hosting chain passes deterministically;
- official compiler runs `check`, `build`, `run`, `fmt`, `test` and `doc`;
- conformance suite covers frontend, runtime, package, FFI, effects, memory and
  invalid diagnostics;
- release artifacts are reproducible, checksum-verified and signed;
- package install verifies hashes and supports offline cache;
- security policy has an exercised advisory flow;
- migration and compatibility policy exists for language changes;
- CI blocks releases on verifier, editor tooling and artifact integrity.
- market-readiness gates in `docs/market-readiness.md` pass for the claimed
  target markets.

## Pilot Guidance

For company pilots, keep Seven isolated from production secrets and production
systems. Use it for code review, specification study, local examples and
non-critical internal experiments until the production gate is complete.
