# Seven tools

A toolchain oficial da Seven nao possui ponte executavel em PowerShell.

Os comandos de desenvolvimento, verificacao, LSP, pacote, release e instalacao
sao implementados em `.sev` e expostos pelo compilador `seven`:

```text
seven check seven.pkg
seven build seven.pkg build/seven.svbc
seven test
seven lsp
seven verify foundation
seven verify bootstrap
seven verify production
seven installer windows-x64
seven installer linux-x64
seven release
```

Esta pasta pode conter documentacao e dados auxiliares, mas nao deve conter
implementacao alternativa da linguagem, do compilador ou do runtime.

Arquivos `.ps1` e `.psm1` sao rejeitados pelo gate de producao e pelo workflow
`.github/workflows/foundation.yml`.
