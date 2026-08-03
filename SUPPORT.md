# Support

Seven 0.1.x is supported as a public foundation release for evaluation,
research, tooling work and non-critical pilots.

## Before Opening an Issue

Run:

```powershell
.\tools\verify-foundation.ps1
.\bin\seven.exe --version
```

Editor adapters that require JavaScript, TypeScript, npm or another host
language are outside the official Seven core. For editor intelligence issues,
run the Seven LSP smoke test instead:

```powershell
.\tools\seven-lsp.ps1 -SelfTest -File .\examples\hello.sv
```

## Issue Template

Include:

- Seven commit SHA;
- Windows version;
- PowerShell version from `$PSVersionTable.PSVersion`;
- command executed;
- full verifier output when relevant;
- minimal `.sv` input when relevant;
- whether the report blocks evaluation, a pilot, documentation or tooling.

## Support Boundaries

The project currently supports:

- foundation verifier failures;
- examples and conformance behavior;
- language specification questions;
- bootstrap executable metadata;
- package lock, Seven-native LSP contracts and FFI development tooling.

The project does not yet provide:

- paid production support;
- compatibility guarantees for a 1.0 compiler;
- production runtime SLA;
- a public package registry SLA.

Security reports must follow [SECURITY.md](SECURITY.md).
