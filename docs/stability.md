# Seven stability contract

This document defines which public surfaces are candidates for compatibility
guarantees in Seven 1.x and which remain preview or host-only while the 1.0
hardening gate is open.

## Stable native 1.0 surface

The following families are the native compatibility target for Windows x64 and
Linux x64:

- tagged primitive values, numeric arithmetic and comparisons;
- `Texto` size, equality, character access, contains, prefix and slicing;
- `Bytes` allocation, access, mutation and native binary file I/O;
- objects, lists and iterators required by the compiler/runtime;
- terminal output;
- text and binary filesystem I/O already covered by native CI;
- the AOT ELF64 and PE32+ formats;
- the SVBC contracts exercised by the self-hosting chain;
- TCP primitives listed in `runtime/platform/native/target.sev` once #40
  completes.

A stable syscall is never allowed to silently emulate success. If its native
implementation is unavailable, AOT compilation must fail explicitly with
`SV-NATIVE-SYSCALL` until the implementation lands.

## Preview / host-only surface

These surfaces may exist in the stdlib or hosted SVBC runtime but are not yet a
native 1.0 compatibility promise:

- hosted/virtual SVBC helper syscalls;
- dynamic-call helpers;
- browser/frontend helpers and rich Web serialization helpers;
- regex helpers not used by the native compiler path;
- databases, Redis, queues and message brokers;
- SMTP/IMAP;
- MQTT, SNMP, WebSocket and TLS helpers beyond the TCP gate;
- AI integrations;
- experimental crypto/telemetry helpers;
- ARM64.

Preview code must never be routed through a null-success native stub. When no
native lowering exists, the AOT compiler rejects it explicitly.

## Promotion rule

A preview family becomes stable only after:

1. a native implementation exists for every stable target it claims;
2. Linux/Windows execution proofs exist where applicable;
3. malformed/error paths are covered;
4. the public contract is documented;
5. the Seven 1.0 readiness gate is green for that surface.

## Compatibility rule

After 1.0, incompatible changes to stable syntax, ABI, SVBC or stable runtime
contracts require an explicit migration policy or a future major release.

Refs #36
Refs #39
