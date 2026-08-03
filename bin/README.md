# Seven Executable

`seven.exe` is the Windows bootstrap executable for Seven 0.1.0.

## Commands

```text
seven --version
seven check <file.sev>
seven build <file.sev> [out.svbc]
seven run <file.sev>
```

## Status

This executable is a bootstrap artifact for the 0.1.0 foundation release. It validates `.sev` inputs and emits an initial `SVBC` envelope with source metadata and SHA-256.

The full self-hosting chain remains:

```text
seed -> seven0 -> seven -> seven.self
```

## Creator

Gabriel Barcelos.
