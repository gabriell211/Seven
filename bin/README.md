# Seven Executable

`seven.exe` is the audited Windows bootstrap executable for the current Seven
0.2.0 transition.

## Commands

```text
seven --version
seven check <file.sev>
seven build <file.sev> [out.svbc]
seven web build <file.sev> [out-dir]
seven run <file.sev>
seven verify <foundation|bootstrap|production>
seven doctor
```

## Status

This executable is the same Windows compiler embedded in the checksummed native
seed archive at `seed/native/final/v1`. It validates `.sev` inputs, emits
deterministic `SVBC`, produces direct WebAssembly output and runs the
foundation, bootstrap and production verification gates.

Its SHA-256 is recorded in `seven.exe.sha256` and must remain equal to the
Windows seed hash used by the CI workflows. The published 0.1.0 release remains
an immutable historical release; this repository artifact tracks the current
development transition.

The full self-hosting chain remains:

```text
seed -> seven0 -> seven -> seven.self
```

## Creator

Gabriel Barcelos.
