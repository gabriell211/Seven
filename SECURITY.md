# Security Policy

## Supported Versions

Seven 0.1.x is a foundation release. Security fixes are accepted for:

- bootstrap artifacts and checksum metadata;
- PowerShell development tools;
- Seven-native language intelligence and LSP contracts;
- package and lockfile tooling;
- SVBC envelope checks and development VM;
- documented language, runtime and standard library contracts.

Seven must not be presented as a final production compiler until the
self-hosting chain passes:

```text
seed -> seven0 -> seven -> seven.self
```

## Reporting a Vulnerability

Do not publish exploit details in a public issue.

Use GitHub Security Advisories for this repository when available. If private
advisories are unavailable, open a minimal public issue asking for a private
security contact and omit technical details until a private channel is agreed.

Include:

- affected version or commit;
- operating system and PowerShell version;
- exact command used;
- minimal `.sv` input or artifact needed to reproduce;
- expected result and actual result;
- whether the issue affects code execution, filesystem access, package
  integrity, bytecode verification or diagnostics.

## Response Targets

These are public project targets, not a paid SLA:

- acknowledgement: 7 days;
- initial triage: 14 days;
- fix or mitigation plan: 30 days for high impact reports;
- coordinated disclosure after a fix is available, unless active exploitation
  requires faster public notice.

## Security Scope

High impact issues include:

- execution of unintended host commands;
- path traversal in tools, package cache or artifact generation;
- checksum mismatch accepted as valid;
- SVBC image accepted with an invalid envelope;
- diagnostics or verifier failures hidden by tooling;
- lockfile tampering accepted by `pkg verify`;
- memory-bound or effect-system checks silently bypassed in conformance cases.

Out of scope for 0.1.x:

- production SLA requests;
- vulnerability claims against planned APIs that are only documented contracts;
- issues requiring undisclosed private forks or modified binaries.
