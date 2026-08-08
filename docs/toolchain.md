# Seven Toolchain

## Contrato

A toolchain oficial vive em Seven. Compilador, runtime, verificadores,
instalador, formatter, testes, LSP, pacotes e release sao implementados em
`.sev`.

Arquivos PowerShell nao fazem parte do caminho oficial e sao rejeitados pelo CI
e por `seven verify production`.

## Fontes principais

```text
compiler/seven.sev
compiler/driver.sev
compiler/toolchain/command.sev
compiler/toolchain/cli.sev
compiler/toolchain/installer.sev
compiler/toolchain/installer_builder.sev
compiler/toolchain/native_build.sev
compiler/toolchain/formatter.sev
compiler/toolchain/test_runner.sev
compiler/toolchain/lsp_server.sev
compiler/toolchain/release.sev
compiler/toolchain/bootstrap_chain.sev
compiler/toolchain/verify.sev
compiler/toolchain/production_audit.sev
runtime/installer/seven.sev
runtime/platform/native/target.sev
runtime/platform/native/linker.sev
runtime/platform/svbc/install.sev
std/os/install.sev
```

## CLI

```text
seven --version
seven check <arquivo.sev|seven.pkg>
seven build <arquivo.sev|seven.pkg> <saida.svbc>
seven run <arquivo.sev|seven.pkg>
seven test
seven bench
seven fmt
seven lint
seven doc
seven repl
seven debug
seven profile
seven doctor
seven install [prefixo]
seven uninstall [prefixo]
seven installer windows-x64 [diretorio]
seven installer linux-x64 [diretorio]
seven lsp
seven pkg add
seven pkg remove
seven pkg verify
seven pkg install
seven target list
seven web build <entrada.sev> [diretorio]
seven web serve <diretorio> [porta]
seven serve <diretorio> [porta]
seven release
seven verify foundation
seven verify bootstrap
seven verify production
```

## Compilacao

```text
pedido_de_compilacao
  -> fonte
  -> lexer
  -> parser
  -> semantica
  -> IR
  -> SVBC
  -> VM ou backend nativo
```

`seven build` respeita a entrada e o caminho de saida informados. A escrita de
SVBC e de executaveis nativos e binaria, sem conversao dos bytes para texto.

## Bootstrap

```text
seed/genesis.svhex -> seven0 -> seven -> seven.self
```

Artefatos esperados:

```text
build/seven0.svbc
build/seven.svbc
build/seven.self.svbc
build/seven.host.svbc
build/seven.launcher.svbc
build/seven.installer.svbc
```

## Backend nativo

Os alvos oficiais iniciais sao:

```text
windows-x64 / PE
linux-x64   / ELF
```

`AlvoNativo` define arquitetura, entrada, formato, subsistema, imports de
plataforma e recursos. O backend valida os recursos e grava o artefato como
bytes. Executaveis ELF recebem permissao de execucao.

O compilador Windows incorpora `brand/seven.ico`. O instalador Windows usa a
entrada `instalador_inicio` e incorpora o mesmo ICO. O Linux instala
`brand/seven-mark.svg` no tema de icones e inclui o ICO no payload.

## Instalador

### Geracao

```text
seven build runtime/installer/seven.sev build/seven.installer.svbc
seven installer windows-x64
seven installer linux-x64
```

### Windows

- prefixo: `%LOCALAPPDATA%\Programs\Seven`;
- PATH do usuario;
- atalho no Menu Iniciar;
- associacao `.sev`;
- registro de desinstalacao;
- compilador, SVBC, stdlib, licenca, aviso e icones no payload.

### Linux

- prefixo: `~/.local/share/seven`;
- link `~/.local/bin/seven`;
- arquivo `seven.desktop`;
- MIME `text/x-seven`;
- icone SVG em `hicolor/scalable/apps`;
- compilador, SVBC, stdlib, licenca, aviso e ICO no payload.

Todas as operacoes passam por intrinsecos Seven tipados. O instalador nao chama
shell, npm, Python, Rust, Go, C/C++ ou PowerShell.

## Release

`seven release` gera:

- compilador nativo Windows e Linux;
- checksums SHA-256;
- instalador Windows e Linux;
- manifestos de pacote;
- SBOM;
- icones oficiais;
- imagens SVBC do compilador, host e launcher.

A assinatura de release permanece um gate separado. Um release nao deve ser
marcado como self-hosted enquanto a equivalencia deterministica entre `seven` e
`seven.self` nao estiver comprovada.

## Verificacao

```text
seven verify foundation
seven verify bootstrap
seven verify production
```

O gate de producao verifica, entre outros pontos:

- ausencia de scripts PowerShell;
- CI chamando `seven` diretamente;
- SVBC produtivo;
- equivalencia do bootstrap;
- compilador, runtime, LSP, pacotes e stdlib;
- backend nativo;
- instaladores Windows/Linux;
- ICO e SVG oficiais;
- checksums e release.

## CI

`.github/workflows/foundation.yml`:

1. rejeita os antigos arquivos da ponte;
2. chama `bin/seven.exe` diretamente;
3. verifica fontes `.sev`;
4. materializa imagens SVBC;
5. executa os tres gates;
6. gera compiladores e instaladores;
7. valida os bundles em Windows e Linux;
8. publica os bundles como artifact do workflow.
