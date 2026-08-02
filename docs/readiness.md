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

## Production Gate

Seven should be called production-ready only after:

```text
seed -> seven0 -> seven -> seven.self
```

passes with equivalent output.

Until then, Seven 0.1.0 is a complete foundation release, not a final 1.0 production compiler.
