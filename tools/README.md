# Seven tools

Ferramentas desta pasta sao pontes legadas de fundacao. Elas validam o
repositorio e os artefatos de bootstrap enquanto o comando self-hosted ainda nao
executa sozinho. Elas nao fazem parte da identidade da linguagem e nao
substituem a cadeia oficial:

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

Tambem verifica que a arvore oficial nao contem JavaScript/TypeScript/npm e que
a toolchain oficial existe em Seven em `compiler/toolchain`, incluindo
`seven verify foundation`, `seven verify bootstrap` e
`seven verify production`.

Durante a transicao ele tambem materializa:

```text
build/seven0.svbc
build/seven.svbc
build/seven.self.svbc
```

Esses arquivos continuam ignorados pelo Git ate virarem SVBC produtivo real.

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

O destino dessa ponte e desaparecer do caminho de produto e ser substituida por:

```text
seven verify foundation
seven verify production
seven pkg verify
seven lsp
seven install
```

## LSP

```powershell
.\tools\seven-lsp.ps1 -SelfTest -File .\examples\hello.sv
```

O LSP oficial deve viver em Seven. A ponte PowerShell acima e historica de
fundacao e nao substitui o servidor self-hosted.

`editors/vscode/seven-language` contem apenas recursos estaticos de editor,
como configuracao textual e realce. O nucleo oficial nao contem extensao
executavel em JavaScript/TypeScript nem dependencia npm.
