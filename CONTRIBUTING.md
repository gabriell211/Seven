# Contributing to Seven

Seven is created by Gabriel Barcelos.

## Principles

- Keep Seven self-hosting as the north star.
- Prefer `.sev` sources for language, compiler, runtime and standard library work.
- Keep platform bindings explicit through `sys_*`, `frontend_*` and target contracts.
- Do not add hidden host-language dependencies to the repository.
- Keep diagnostics stable and documented.
- Add conformance cases for language changes.
- Run `.\tools\verify-foundation.ps1` before proposing changes that affect
  language behavior, tooling, bootstrap artifacts, packages, LSP or FFI.
- Report security issues through `SECURITY.md`, not public issues with exploit
  details.

## Project Areas

- `compiler/`: full Seven compiler.
- `compiler0/`: Seven-0 bootstrap compiler.
- `runtime/`: VM, platform ABI and targets.
- `std/`: standard library.
- `docs/`: public specification.
- `conformance/`: language and library contracts.
- `examples/`: real usage examples.

## Commit Style

Use clear messages:

```text
feat(std): add smtp contracts
docs(runtime): explain svbc sandbox
brand: add official Seven mark
```
