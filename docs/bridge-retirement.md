# Aposentadoria da ponte PowerShell

## Estado

A ponte PowerShell foi aposentada do caminho oficial da Seven.

Foram removidos:

```text
tools/seven-dev.ps1
tools/seven-lsp.ps1
tools/verify-foundation.ps1
tools/Seven.Foundation.psm1
```

O workflow `.github/workflows/foundation.yml` chama o compilador `seven`
diretamente e rejeita a reintroducao desses arquivos.

## Caminho oficial

```text
seed -> seven0 -> seven -> seven.self
```

A superficie oficial e implementada em Seven:

```text
compiler/
compiler0/
compiler/toolchain/
runtime/
std/
```

Os comandos de verificacao sao:

```text
seven verify foundation
seven verify bootstrap
seven verify production
```

Os comandos de compilacao e ferramentas sao:

```text
seven check seven.pkg
seven build seven.pkg build/seven.svbc
seven test
seven fmt
seven lsp
seven pkg verify
seven release
```

## Instaladores nativos

A propria toolchain Seven gera dois pacotes:

```text
seven installer windows-x64
seven installer linux-x64
```

### Windows

O pacote contem:

- `seven-installer.exe`;
- compilador `seven.exe`;
- bytecode do compilador, host e launcher;
- biblioteca padrao;
- `brand/seven.ico` embutido no executavel e incluido no payload;
- registro no PATH do usuario;
- atalho no Menu Iniciar;
- associacao da extensao `.sev`;
- entrada de desinstalacao do usuario.

O prefixo padrao e:

```text
%LOCALAPPDATA%\Programs\Seven
```

### Linux

O pacote contem:

- executavel ELF `seven-installer`;
- compilador ELF `seven`;
- bytecode do compilador, host e launcher;
- biblioteca padrao;
- `brand/seven.ico` no payload;
- `brand/seven-mark.svg` instalado no tema de icones;
- link em `~/.local/bin/seven`;
- arquivo `seven.desktop`;
- tipo MIME `text/x-seven` para arquivos `.sev`.

O prefixo padrao e:

```text
~/.local/share/seven
```

## Regra permanente

A implementacao do compilador, runtime, instalador, LSP, verificadores e
ferramentas de pacote deve permanecer em `.sev`.

Scripts hospedeiros podem existir somente fora do caminho oficial quando forem
necessarios para integracao externa, nunca para implementar ou validar o nucleo
da linguagem. O gate de producao atual proibe PowerShell na toolchain oficial.
