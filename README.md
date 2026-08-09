![Seven](brand/seven-logo.svg)

# Seven `.sev`

Seven e uma linguagem de programacao de sistemas e aplicacoes criada por
**Gabriel Barcelos** (`gabriell211`). O compilador, o runtime, a biblioteca
padrao e a toolchain oficial sao escritos em Seven.

- Extensao oficial: `.sev`
- Compilador: `seven`
- Bytecode: `SVBC`
- Alvos: Windows x64, Linux x64, SVBC e web

## Download

- [Seven 0.1.0 para Windows x64](https://github.com/gabriell211/Seven/releases/download/v0.1.0/seven-0.1.0-windows-x64.zip)
- [SHA-256 do pacote Windows](https://github.com/gabriell211/Seven/releases/download/v0.1.0/seven-0.1.0-windows-x64.zip.sha256)
- [Seven 0.1.0 para Linux x64](https://github.com/gabriell211/Seven/releases/download/v0.1.0/seven-0.1.0-linux-x64.tar.gz)
- [SHA-256 do pacote Linux](https://github.com/gabriell211/Seven/releases/download/v0.1.0/seven-0.1.0-linux-x64.tar.gz.sha256)
- [Notas da release Seven 0.1.0](https://github.com/gabriell211/Seven/releases/tag/v0.1.0)

Os pacotes sao gerados pelos runners oficiais, testados em Windows e Linux e
publicados somente depois da verificacao dos checksums, compilacao, execucao,
instalacao e desinstalacao.

## Principios

- **Controle:** memoria, bytes, layout, ABI e binarios previsiveis.
- **Seguranca:** tipos fortes, falhas explicitas, efeitos e limites verificados.
- **Escala:** modulos, pacotes, compilacao, testes e ferramentas de projeto.
- **Produtividade:** sintaxe legivel, diagnosticos estaveis e biblioteca coerente.
- **Autonomia:** nenhuma ponte PowerShell implementa ou valida o nucleo oficial.

## Exemplo

```sev
modulo app

campo inicio() -> Num toca terminal ::
  guarda nome: Texto := "Seven"
  diga "linguagem: " + nome
  devolve 0
fecha
```

## Toolchain

```text
seven --version
seven check seven.pkg
seven build seven.pkg build/seven.svbc
seven run seven.pkg
seven doctor

# Superficie de preview no codigo-fonte
seven test
seven fmt
seven lsp
seven pkg verify
seven verify foundation
seven verify bootstrap
seven verify production
seven release
```

Para desenvolvimento Web no navegador:

```text
seven check examples/web_dev.sev
seven web build examples/web_dev.sev build/web-dev
seven web serve build/web-dev 7070

seven check examples/frontend-counter/app.sev
seven web build examples/frontend-counter/app.sev build/frontend-counter
seven web serve build/frontend-counter 7071
```

`examples/web_dev.sev` cobre a pagina Web basica. O starter
`examples/frontend-counter/app.sev` cobre UI interativa com DOM, CSS, evento,
`localStorage` e conversao `Texto`/`Num`, sem Node ou JavaScript manual. O guia
pratico fica em `docs/web-development.md`.

A cadeia oficial de bootstrap e:

```text
seed -> seven0 -> seven -> seven.self
```

## Instalacao

A toolchain gera instaladores nativos sem scripts PowerShell:

```text
seven build seven.pkg build/seven.installer.svbc
seven installer windows-x64
seven installer linux-x64
```

### Windows x64

Artefato:

```text
build/installers/seven-0.1.0-windows-x64/seven-installer.exe
```

O instalador usa `brand/seven.ico`, instala por padrao em
`%LOCALAPPDATA%\Programs\Seven`, registra o compilador no PATH do usuario,
cria atalho no Menu Iniciar, associa arquivos `.sev` e registra a
Desinstalacao do Windows.

### Linux x64

Artefato:

```text
build/installers/seven-0.1.0-linux-x64/seven-installer
```

O instalador coloca a distribuicao em `~/.local/share/seven`, cria o link
`~/.local/bin/seven`, instala `brand/seven-mark.svg` no tema de icones,
registra `seven.desktop` e o MIME `text/x-seven`. O pacote tambem inclui
`brand/seven.ico` no payload oficial.

## Estrutura

- `compiler/`: compilador Seven.
- `compiler0/`: compilador minimo do bootstrap.
- `compiler/toolchain/`: CLI, formatter, testes, LSP, release e instaladores.
- `runtime/`: VM, host, launcher, decoder, verificador e plataforma nativa.
- `runtime/installer/`: entrada do instalador escrita em Seven.
- `std/`: biblioteca padrao.
- `conformance/`: testes de conformidade validos e invalidos.
- `tests/`: testes da toolchain e do runtime.
- `seed/`: seed minimo auditavel.
- `brand/`: logo, marca SVG e icone ICO oficial.
- `docs/`: especificacao e arquitetura.

## Compilador

O pipeline implementado e:

```text
fonte .sev
  -> lexer
  -> tokens e diagnosticos
  -> parser
  -> AST
  -> simbolos, tipos, efeitos e memoria
  -> IR
  -> SVBC
  -> VM ou backend nativo
```

O front-end suporta declaracoes, genericos, moldes, selos, campos, contratos,
escopos, mutabilidade, retornos, chamadas, controle de fluxo, iteracao,
operacoes de memoria e recuperacao de erros.

## Biblioteca padrao

A biblioteca inclui superficies para:

- colecoes, texto, bytes, resultados e opcoes;
- arquivos, ambiente, processos e tempo;
- TCP, UDP, DNS, TLS, HTTP e WebSocket;
- JSON, XML, YAML, TOML, CSV e formatos binarios;
- banco de dados, Redis, filas e migracoes;
- criptografia, tokens e autenticacao;
- frontend, DOM, CSS, estado e cliente HTTP;
- testes, logs, metricas e tracing.

## Verificacao

O workflow `.github/workflows/foundation.yml` executa o compilador diretamente,
materializa as imagens SVBC, verifica a cadeia de bootstrap, gera os
compiladores nativos e produz os dois instaladores.

O gate rejeita a existencia de:

```text
tools/seven-dev.ps1
tools/seven-lsp.ps1
tools/verify-foundation.ps1
tools/Seven.Foundation.psm1
```

Para auditoria local:

```text
seven verify foundation
seven verify bootstrap
seven verify production
```

## Documentacao principal

- `docs/language.md`: especificacao da linguagem.
- `docs/grammar.svbnf`: gramatica.
- `docs/compiler-architecture.md`: arquitetura do compilador.
- `docs/type-system.md`: sistema de tipos.
- `docs/memory-model.md`: modelo de memoria.
- `docs/effects.md`: efeitos.
- `docs/runtime.md`: runtime e VM.
- `docs/bytecode.md`: formato SVBC.
- `docs/toolchain.md`: comandos e ferramentas.
- `docs/targets.md`: alvos de compilacao.
- `docs/bridge-retirement.md`: aposentadoria da ponte PowerShell.
- `docs/production-gate.md`: criterios de producao.
- `docs/enterprise-readiness.md`: prontidao corporativa.

## Estado do projeto

A Seven possui uma fundacao executavel do compilador, runtime SVBC, toolchain,
biblioteca padrao e empacotamento nativo. O projeto somente deve ser anunciado
como totalmente self-hosted depois que a equivalencia deterministica abaixo for
comprovada pelos artefatos de release:

```text
hash(seven gerado por seven0)
==
hash(seven gerado por seven)
==
hash(seven gerado por seven.self)
```

## Licenca e autoria

Consulte `LICENSE`, `NOTICE` e `CITATION.cff`.
