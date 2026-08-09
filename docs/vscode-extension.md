# VSCode extension

The official Seven VSCode extension lives in:

```text
editors/vscode/seven-language
```

It is a syntax/configuration package for `.sev` files and includes:

- `package.json`: VSCode extension manifest;
- `syntaxes/seven.tmLanguage.json`: TextMate grammar;
- `language-configuration.json`: comments, brackets, auto-closing pairs and
  folding markers;
- `README.md`, `CHANGELOG.md`, `LICENSE.md` and `.vscodeignore`.

## Develop locally

Open the extension folder in VSCode, press `F5`, and test `.sev` files in the
Extension Development Host.

## Package

From `editors/vscode/seven-language`:

```text
npx @vscode/vsce package --no-dependencies
```

The extension is intentionally independent of Node runtime code. Future LSP
activation should call the official `seven lsp` command once that self-hosted
path is the default editor integration.
