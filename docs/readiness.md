# Seven Readiness

## Current classification

Seven 0.1.0 is a functional foundation release under production hardening.
It is not declared production-ready merely because source files, native seeds or
installers exist. Readiness must be demonstrated by executable gates.

The supported foundation already includes:

- the `.sev` language surface and specification;
- compiler, runtime, VM and toolchain sources written in Seven;
- deterministic `.svbc` generation;
- native bootstrap executables for Windows x64 and Linux x64;
- native installers with installation and uninstallation tests;
- a TextMate grammar and editor assets;
- valid and invalid conformance suites;
- checksummed bootstrap artifacts.

## Required evidence

A production-readiness claim requires all of the following:

1. valid conformance programs are accepted;
2. invalid conformance programs are rejected with stable diagnostics;
3. `check`, `build` and `run` exercise real compiler and runtime behavior;
4. generated SVBC is structurally validated before execution;
5. memory allocations and indexed accesses are bounded;
6. Windows and Linux installers install, execute and uninstall successfully;
7. the canonical grammar and editor grammar remain identical;
8. no public compiler, runtime or standard-library surface silently delegates to
   a placeholder intrinsic;
9. `seed -> seven0 -> seven -> seven.self` produces equivalent deterministic
   outputs;
10. releases are reproducible, checksummed, signed and accompanied by an SBOM.

## Automated gates

The repository uses two complementary workflows:

```text
.github/workflows/foundation.yml
.github/workflows/readiness.yml
```

`foundation.yml` validates the audited bootstrap archive, native compiler
execution, deterministic bytecode and Windows/Linux installer lifecycle.

`readiness.yml` deliberately goes further. It executes the compiler against the
valid and invalid conformance suites, validates grammar synchronization, checks
memory regression coverage and rejects known production placeholders.

A green foundation workflow does not override a failing readiness workflow.

## Bootstrap status

Native bootstrap binaries are transition artifacts. They make the repository
executable and auditable, but they are not by themselves proof of self-hosting.
The production chain remains:

```text
seed -> seven0 -> seven -> seven.self
```

The final proof is deterministic equivalence between the compiler produced by
Seven-0, the compiler produced by Seven and the compiler rebuilt by itself.

## Usage classification

Until every production gate passes, Seven is suitable for:

- compiler and runtime development;
- language experiments;
- conformance work;
- editor integration;
- isolated prototypes and non-critical pilots.

It must not yet be presented as a final compiler for business-critical workloads.
When all gates pass, this document and the release metadata must be updated in
the same reviewed change that promotes the release.
