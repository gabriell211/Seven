# Seven Readiness

## Release State

Seven 0.1.0 is ready as a public foundation repository.

It includes:

- official identity and creator metadata;
- official logo, mark and Windows icon;
- language specification;
- compiler source in `.sv`;
- Seven-0 bootstrap source;
- bytecode and seed specifications;
- runtime and VM source in `.sv`;
- platform ABI and target contracts;
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
seven check <file.sv>
seven build <file.sv> [out.svbc]
seven run <file.sv>
```

## Foundation Verification

The foundation release has an explicit verifier:

```powershell
.\tools\verify-foundation.ps1
```

This verifier checks the Windows bootstrap executable, valid conformance files,
SVBC envelope generation, development VM execution, package lock generation,
LSP symbol publication, FFI header generation and invalid conformance
diagnostics.

The development CLI exposes the current operational gates:

```powershell
.\tools\seven-dev.ps1 check .\examples\hello.sv
.\tools\seven-dev.ps1 run .\examples\hello.sv
.\tools\seven-dev.ps1 debug .\examples\control.sv --break 8 --locals
.\tools\seven-dev.ps1 pkg add std.http 1.0.0 registry
.\tools\seven-dev.ps1 pkg verify
.\tools\seven-dev.ps1 pkg install
.\tools\seven-dev.ps1 ffi header .\examples\interop-c\main.sv .\build\interop-c.h
.\tools\seven-dev.ps1 ffi manifest .\examples\interop-c\main.sv .\build\interop-c.json
```

The Windows bootstrap executable remains a foundation artifact. The production
compiler should absorb these development gates into the self-hosted `seven`.

## Production Gate

Seven should be called production-ready only after:

```text
seed -> seven0 -> seven -> seven.self
```

passes with equivalent output.

Until then, Seven 0.1.0 is a complete foundation release, not a final 1.0 production compiler.
