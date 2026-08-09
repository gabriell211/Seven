# Seven Language for VSCode

Official Visual Studio Code language package for Seven `.sev` files.

## Features

- Registers `.sev` files as Seven source.
- Provides TextMate syntax highlighting for modules, imports, fields,
  molds, seals, constants, variables, control flow, effects, built-in types,
  strings, numbers, comments and operators.
- Enables line comments, bracket matching, auto-closing pairs and folding
  markers for `campo`, `molde`, `selo`, `veja`, `gira` and `zona` blocks.

## Local development

Open this folder directly in VSCode:

```text
editors/vscode/seven-language
```

Then press `F5` and open any `.sev` file in the Extension Development Host.

## Package as VSIX

From this folder:

```text
npx @vscode/vsce package --no-dependencies
```

The package is intentionally syntax/configuration-only. LSP support belongs to
the Seven toolchain and can be wired as a separate extension activation step
when the self-hosted `seven lsp` command becomes the default editor path.

## License

MIT. See `LICENSE.md`.
