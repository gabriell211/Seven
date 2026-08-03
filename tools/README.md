# Seven tools

Ferramentas desta pasta validam o repositorio e os artefatos de bootstrap.
Elas nao fazem parte da identidade da linguagem e nao substituem a cadeia oficial:

```text
seed -> seven0 -> seven -> seven.self
```

## Verificador de fundacao

```powershell
.\tools\verify-foundation.ps1
```

O verificador executa o `bin/seven.exe`, confere comandos basicos, valida casos
`conformance/**/valid/*.sv`, gera envelopes `SVBC` de smoke test e exige os
diagnosticos declarados em `conformance/**/invalid/*.sv`.

## CLI de desenvolvimento

```powershell
.\tools\seven-dev.ps1 check .\examples\hello.sv
.\tools\seven-dev.ps1 build .\examples\hello.sv .\build\hello.svbc
.\tools\seven-dev.ps1 run .\examples\hello.sv
.\tools\seven-dev.ps1 debug .\examples\control.sv --break 8 --locals
.\tools\seven-dev.ps1 pkg add std.http 1.0.0 registry
.\tools\seven-dev.ps1 pkg verify
.\tools\seven-dev.ps1 pkg install
.\tools\seven-dev.ps1 pkg remove std.http
.\tools\seven-dev.ps1 ffi header .\examples\interop-c\main.sv .\build\interop-c.h
.\tools\seven-dev.ps1 ffi manifest .\examples\interop-c\main.sv .\build\interop-c.json
```

`seven-dev` e uma ponte de fundacao: torna os contratos testaveis agora, enquanto
a cadeia `seven.self` ainda nao materializa o executavel oficial completo.

## LSP

```powershell
.\tools\seven-lsp.ps1 -SelfTest -File .\examples\hello.sv
```

A extensao inicial para VS Code fica em `editors/vscode/seven-language` e inclui
realce, completions, diagnostics, document symbols, hover e comandos para
check/run/debug do arquivo aberto.
