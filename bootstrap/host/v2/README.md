# Genesis host v2

This directory contains the minimal audited transition host used to execute the
frozen Seven-0 image during bootstrap.

The host is deliberately isolated from the compiler, runtime and standard
library. Its only responsibility is to load the bootstrap bytecode formats,
provide the primitive services required by Seven-0 and execute the generated
compiler until Seven reaches its self-hosted fixed point.

Every source fragment is covered by `SHA256SUMS`. CI builds the host directly
from these files on Windows and Linux before executing the bootstrap chain.

## Bootstrap invariant

```text
Seven-0 -> Stage 1 -> Stage 2 -> Stage 2 self
                              |
                              +-- byte-for-byte equality
```

The gate also compiles a fresh package with Stage 1 and Stage 2, executes it and
requires exit code `42`. A successful run records SHA-256 provenance for the
host sources, Seven-0, Stage 1, Stage 2 and the proof program.

The Genesis host is a removable transition boundary. Application code,
compiler development, runtime development and standard-library development
remain Seven-only.
