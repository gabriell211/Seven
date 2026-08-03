# Seven Readiness

## Release State

Seven 0.1.0 is ready as a public foundation repository.

It includes:

- official identity and creator metadata;
- official logo, mark and Windows icon;
- language specification;
- compiler source in `.sev`;
- Seven-0 bootstrap source;
- bytecode and seed specifications;
- runtime and VM source in `.sev`;
- platform ABI and target contracts;
- Seven-native toolchain source for CLI, installer, formatter, test runner,
  LSP server, release preparation, foundation verification and bootstrap
  verification;
- full standard library surface;
- frontend CSS system;
- examples;
- conformance suites;
- Windows bootstrap executable;
- checksums for binary artifacts.

## Executable

`bin/seven.exe` supports:

```text
seven --version
seven check <file.sev>
seven build <file.sev> [out.svbc]
seven run <file.sev>
```

## Foundation Verification

The foundation release has an explicit verifier:

```powershell
.\tools\verify-foundation.ps1
```

This verifier checks the Windows bootstrap executable, valid conformance files,
standard library files, SVBC envelope generation, development VM execution,
package lock generation, LSP symbol publication, FFI header generation, runtime
command execution surface for `build/seven.svbc verify foundation` and
`build/seven.svbc verify bootstrap`, `build/seven.launcher.svbc verify bootstrap`
and `build/seven.svbc verify production`, absence of JavaScript/TypeScript
runtime in the official source tree and invalid conformance diagnostics.

The development CLI exposes the current operational gates:

```powershell
.\tools\seven-dev.ps1 check .\examples\hello.sev
.\tools\seven-dev.ps1 run .\examples\hello.sev
.\tools\seven-dev.ps1 debug .\examples\control.sev --break 8 --locals
.\tools\seven-dev.ps1 pkg add std.http 1.0.0 registry
.\tools\seven-dev.ps1 pkg verify
.\tools\seven-dev.ps1 pkg install
.\tools\seven-dev.ps1 ffi header .\examples\interop-c\main.sev .\build\interop-c.h
.\tools\seven-dev.ps1 ffi manifest .\examples\interop-c\main.sev .\build\interop-c.json
```

The Windows bootstrap executable and PowerShell verifier remain foundation
bridges. The production compiler should absorb these development gates into the
self-hosted `seven`.

The launcher contract now lives in `compiler/toolchain/launcher.sev`; release and
install plans carry a `seven.launcher` manifest and `seven.launcher.svbc`
bytecode. This is the verified handoff point before replacing the transitional
host with a real self-hosted executable.

The official replacement path is documented in [Bridge retirement](bridge-retirement.md):

```text
tools/verify-foundation.ps1 -> seven verify foundation
seven verify bootstrap       -> equivalencia seven == seven.self
seven verify production      -> checklist dos 10 pontos
bin/seven.exe               -> seed -> seven0 -> seven -> seven.self
```

## Enterprise Readiness

Seven 0.1.0 is enterprise-evaluable as a foundation release. It has explicit
verification for bootstrap behavior, checksums, conformance, packages, LSP and
FFI, but it is not yet a final enterprise production compiler.

Company evaluations should use:

- [Market readiness](market-readiness.md);
- [C and JavaScript parity](c-js-parity.md);
- [Enterprise readiness](enterprise-readiness.md);
- [Security policy](../SECURITY.md);
- [Support scope](../SUPPORT.md);
- `.\tools\verify-foundation.ps1`.

## Market Readiness

Seven's market-readiness target is self-reliance: compiler, runtime, standard
library and primary tooling must be Seven-native before 1.0 production claims.
Host tools and bootstrap artifacts are allowed only as auditable bridges.

The foundation verifier now guards the official core source roots against
permanent host-language source files, rejects JavaScript/TypeScript/npm in the
official tree, requires the Seven-native toolchain surface and checks the
standard library. This is a baseline check, not a substitute for the full
self-hosting chain.

## Production Gate

Seven should be called production-ready only after:

```text
seed -> seven0 -> seven -> seven.self
```

passes with equivalent output.

The detailed production checklist is in [Production gate](production-gate.md).

Until then, Seven 0.1.0 is a complete foundation release, not a final 1.0 production compiler.
