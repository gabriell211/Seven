# Legacy Foundation Bridges

Esta pasta contem pontes temporarias de fundacao. Elas existem para validar o
repositorio enquanto a cadeia self-hosted ainda nao executa o comando oficial:

```text
seven verify foundation
seven verify production
```

Novas capacidades de produto devem ser implementadas primeiro em Seven, dentro
de `compiler/toolchain`, `compiler`, `runtime` ou `std`. Scripts PowerShell
podem apenas chamar, comparar ou auditar esse comportamento durante a transicao.

Destino:

```text
tools/verify-foundation.ps1 -> seven verify foundation
tools/seven-dev.ps1         -> seven check/build/run/pkg/ffi/debug
tools/seven-lsp.ps1         -> seven lsp
Seven.Foundation.psm1       -> runtime/compiler Seven-native
```

Quando `seed -> seven0 -> seven -> seven.self` passar com equivalencia
deterministica e SVBC produtivo, estes scripts devem sair do caminho oficial de
release.
