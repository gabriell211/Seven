# Changelog

## Unreleased

## 0.2.1

- Replaces the transitional Windows zip installer with a professional WiX MSI.
- Installs Seven per machine into `%ProgramFiles%\Seven` with Apps & Features
  registration, clean uninstall, Start Menu shortcut, `.sev` association and
  machine `PATH` integration.
- Fixes the release payload layout that made the 0.2.0 Windows installer miss
  the expected compiler and Web command bytecode files.
- Adds `seven.webbuild.svbc` and `seven.webserve.svbc` to release payloads.
- Bumps the VSCode extension package to `0.2.1` for release consistency.

## 0.2.0

- Promotes the audited Windows 0.2.0 transition compiler to `bin/seven.exe`.
- Records the compiler checksum and the current supported CLI surface in
  `bin/README.md`.
- Adds the official VSCode language extension package under
  `editors/vscode/seven-language`.
- Documents the VSCode Extension Development Host and VSIX packaging flow in
  `docs/vscode-extension.md`.

## 0.1.0

- Defines Seven language identity and official creator: Gabriel Barcelos.
- Adds Seven-0 seed, `SVS0`, `SVBC0` and `SVBC` specifications.
- Adds compiler sources in `.sev`.
- Adds runtime VM sources in `.sev`.
- Adds standard library for backend, frontend, CSS, protocols, data, crypto, AI and observability.
- Adds official logo, mark and icon assets.
- Adds bootstrap executable artifact metadata.
