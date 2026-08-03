# Seven Toolchain

## Contrato

A toolchain oficial da Seven deve viver em Seven. Scripts, binarios de
bootstrap e adaptadores externos existem apenas para nascimento, verificacao ou
integracao com ambientes que ainda nao executam Seven diretamente.

Fonte oficial:

```text
compiler/seven.sev
compiler/toolchain/command.sev
compiler/toolchain/cli.sev
compiler/toolchain/installer.sev
compiler/toolchain/formatter.sev
compiler/toolchain/test_runner.sev
compiler/toolchain/lsp_server.sev
compiler/toolchain/release.sev
compiler/toolchain/adapters.sev
compiler/toolchain/bootstrap_chain.sev
compiler/toolchain/verify.sev
compiler/toolchain/library_audit.sev
compiler/toolchain/production_audit.sev
```

## Entrada

`compiler/seven.sev` deve delegar para `executa_cli(argumentos)`. Isso torna a
CLI o ponto unico para comandos oficiais:

```text
seven check
seven build
seven run
seven test
seven bench
seven fmt
seven lint
seven doc
seven repl
seven debug
seven profile
seven doctor
seven install
seven uninstall
seven lsp
seven pkg add
seven pkg remove
seven pkg verify
seven pkg install
seven target list
seven web build
seven serve
seven release
seven verify foundation
seven verify bootstrap
seven verify production
```

## Instalador

`compiler/toolchain/installer.sev` define:

- `PlanoInstalacao`;
- `InstalacaoSeven`;
- `plano_instalacao_padrao`;
- `instala_seven`;
- `remove_instalacao`;
- manifesto de instalacao;
- configuracao de ambiente `SEVEN_HOME`.

O instalador oficial nao deve chamar shell, npm, Python, Rust, Go, C/C++ ou
outra linguagem para realizar a instalacao. Operacoes de arquivo e ambiente
devem passar por intrinsecos Seven.

## Compilador

O comando `check/build/run` chama a camada existente em `compiler/driver.sev`:

```text
pedido_de_compilacao -> compila -> lexer -> parser -> semantica -> IR -> SVBC
```

O proximo marco tecnico e fazer esses comandos usarem argumentos completos,
alvos multiplos e execucao pela VM self-hosted, sem ponte PowerShell.

## Pacotes

`pkg add/remove/verify/install` usa `compiler/package_manager.sev`. O modelo de
producao deve exigir hashes, assinatura, cache offline e politica de registry.

## Formatter e testes

`formatter.sev` e `test_runner.sev` tornam `seven fmt`, `seven test` e
`seven bench` comandos da linguagem. Eles ainda precisam crescer para cobrir:

- parsing real compartilhado com o compilador;
- snapshots de diagnostico;
- testes de runtime;
- testes de pacote;
- benchmarks com medicao estavel.

## LSP

`lsp_server.sev` e a entrada oficial do LSP self-hosted. Adaptadores de editor
podem falar LSP, mas nao fazem parte da linguagem e nao devem introduzir
JavaScript, TypeScript ou npm no nucleo.

## Release

`release.sev` define a preparacao de artefatos, hashes e SBOM. Antes de 1.0, o
release precisa adicionar assinatura, reproducibilidade e comparacao da cadeia:

```text
seed -> seven0 -> seven -> seven.self
```

## Verificacao

`verify.sev` define `seven verify foundation`, o substituto oficial de
`tools/verify-foundation.ps1`. O comando verifica:

- fonte Seven-native;
- ausencia de JavaScript/TypeScript/npm;
- superficie de toolchain em Seven;
- artefatos versionados;
- cadeia de bootstrap declarada;
- compilador;
- pacotes;
- LSP;
- instalador;
- formatter;
- test runner;
- release.
- biblioteca padrao e `conformance/libs`.
- auditoria dos 10 pontos de producao.

`bootstrap_chain.sev` define `seven verify bootstrap`, com as etapas:

```text
seed/genesis.svhex -> build/seven0.svbc
compiler0/seven0.sev -> build/seven.svbc
compiler/seven.sev -> build/seven.self.svbc
```

## Execucao por SVBC

O runtime deve conseguir executar o comando oficial a partir de `build/seven.svbc`:

```text
build/seven.svbc verify foundation
build/seven.svbc verify bootstrap
build/seven.svbc verify production
```

O launcher gerado tambem deve delegar para essa imagem:

```text
build/seven.launcher.svbc verify bootstrap
```

O host gerado fica uma camada acima do launcher:

```text
build/seven.host.svbc verify bootstrap
```

Fonte oficial:

```text
runtime/svbc/runner.sev
runtime/svbc/command_runner.sev
runtime/svbc/vm.sev
runtime/platform/svbc/toolchain.sev
runtime/host/seven.sev
runtime/launcher/seven.sev
```

`runner.sev` expoe `roda_svbc_com_args`, e `command_runner.sev` expoe
`executa_verify_foundation_de_seven_svbc` e
`executa_verify_bootstrap_de_seven_svbc` e
`executa_verify_production_de_seven_svbc`. O CI ja chama esses contratos por
`build/seven.svbc`; a proxima troca e substituir o host PowerShell por um
launcher/runtime executavel Seven.
O runner rejeita envelopes `seven-dev-vm-v1`; somente SVBC produtivo pode ser
tratado como caminho oficial.

O bridge de transicao emite `SVBC-v1` binario e ja consegue encaminhar
`inicio(argumentos)` para `executa_cli(argumentos)` usando `CHAMA`. O campo
`executa_cli` agora usa `SALTA_SE_NAO` para despachar `--help`, `--version`,
`verify foundation`, `verify bootstrap` e `verify production`, chamando intrinsecos pequenos registrados em
`runtime/platform/svbc/toolchain.sev`. O antigo syscall agregado `seven_cli` fica
apenas para compatibilidade com imagens antigas e nao aparece no
`build/seven.svbc` novo.

`runtime/launcher/seven.sev` e a fonte do launcher final: ele recebe
`argumentos` e chama `roda_svbc_com_args("build/seven.svbc", argumentos)`.
`runtime/host/seven.sev` e a fonte do host executavel: ele recebe `argumentos` e
chama `roda_svbc_com_args("build/seven.launcher.svbc", argumentos)`.
`compiler/toolchain/launcher.sev` define o contrato de empacotamento desse
launcher: entrada, imagem `SVBC-v1`, bytecode `build/seven.launcher.svbc`,
arquivos obrigatorios do runtime e manifesto `seven.launcher`. O instalador e o
release incluem o manifesto e o bytecode do launcher como artefatos oficiais.
`compiler/toolchain/native_host.sev` define o contrato do host: entrada,
bytecode `build/seven.host.svbc`, manifesto `seven.host`, alvo nativo padrao e
fontes runtime obrigatorias.

Enquanto esse host SVBC ainda nao vira executavel nativo self-hosted,
`seven-dev.ps1` permanece como host de transicao da VM.

## Producao

`production_audit.sev` define `seven verify production`. Esse comando cobre os
10 pontos necessarios para fechar self-hosting, trocar o CI e aposentar as
pontes antigas. O detalhamento fica em `docs/production-gate.md`.

## Gate

`tools/verify-foundation.ps1` ainda e uma ponte de fundacao, mas agora verifica
que a superficie da toolchain existe em Seven, que o runtime executa
`verify foundation`, `verify bootstrap` e `verify production` por `seven.svbc` e que a biblioteca
padrao passa no checker de fundacao. Quando `seven.self` estiver pronto, esse
gate deve ser substituido por `seven verify foundation` e
`seven verify bootstrap` e `seven verify production`.
