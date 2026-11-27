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

## Pull request workflow

Use a single focused pull request for each independently reviewable change.
Independent changes target `main`; dependent changes may use GitHub's native
stacked pull requests. A stack must contain distinct logical changes, not
follow-up PRs created merely to repair an existing PR.

### Stacked pull requests

Install GitHub CLI 2.90.0 or later and Git 2.20 or later, authenticate with
`gh auth login`, and install the official extension:

```sh
gh extension install github/gh-stack
```

From a clean, up-to-date local checkout, initialize a stack and commit the
first logical change on its first branch. Add the next layer only when it
depends on the preceding change:

```sh
gh stack init
# Implement and commit the first change.
gh stack add feat/dependent-change
# Implement and commit the dependent change.
gh stack submit
gh stack view
```

`gh stack submit` pushes and registers the PRs as a native GitHub stack.
The first PR targets `main`; subsequent PRs target the preceding layer.
Keep compiler/bootstrap prerequisites below dependent runtime, tooling or
packaging changes, where that dependency actually exists. Each layer must
include its relevant tests and remain reviewable.

### Review, CI and merge gates

- Check existing PRs and their branch ancestry before creating a stack or
  adding a layer. Do not stack divergent branches with overlapping changes
  without first reconciling the overlap and validating the resulting diff.
- Fix CI failures, review findings and regressions in the existing owning
  branch/PR. Do not open a separate repair PR for the same change.
- Use the stack's supported cascading rebase to propagate lower-layer
  changes; resolve conflicts and rerun affected checks. Never force-push
  `main` or overwrite another contributor's work.
- Verify that the PRs are linked as a native stack, not merely retargeted
  to another branch. Confirm required checks actually run on every layer
  and pass for the current revisions; do not treat skipped or missing
  required checks as success.
- Merge from the bottom upward using GitHub's stack-aware merge flow. Merge
  a larger portion only if every included PR is approved and all required
  checks pass. Never bypass branch protection or known blockers.
- Release only from the validated integrated revision, not a partially
  merged stack. Keep the existing self-hosting and conformance gates.

Official reference: [About stacked pull requests](https://docs.github.com/en/pull-requests/get-started/about-stacked-prs) and [Stacked PR quickstart](https://docs.github.com/en/pull-requests/get-started/stacked-prs-quickstart).
