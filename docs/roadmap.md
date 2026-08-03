# Roadmap Seven

## Fase 0: fundacao

- Especificacao central.
- Gramatica.
- Modelo de tipos.
- Modelo de memoria.
- Efeitos.
- Bytecode.
- Fonte inicial do compilador em `.sev`.
- Gate automatizado de fundacao para `check`, `build`, `run` e envelope `SVBC`.
- Checker semantico de fundacao para os invalidos iniciais.
- VM de desenvolvimento para smoke tests executaveis.
- Debug trace com breakpoint/locals e contrato de breakpoints.
- Gerenciador inicial `seven.pkg`/`seven.lock` com add/remove/verify/install.
- LSP e extensao VS Code com completions, diagnostics, symbols, hover e comandos.
- Contrato FFI C/C++ por `extern`, header e manifesto.
- Superficie inicial da toolchain oficial em Seven: CLI, instalador,
  formatter, test runner, LSP server e release.
- `seven verify foundation` e `seven verify bootstrap` existem como fonte
  Seven-native.

## Fase 1: Seven-0

- Subconjunto minimo definido.
- Tokens, AST, nomes e tipos basicos.
- Emissao de `SVBC0`.
- Seed auditavel `SVS0`.
- Compilador minimo `compiler0`.

## Fase 2: self-hosting

- `seven` compila `compiler/seven.sev`.
- Builds repetidos sao equivalentes.
- Suite de conformidade em `.sev`.
- `tools/seven-dev.ps1` deixa de ser caminho funcional primario e vira apenas
  ponte historica de verificacao.
- `seed -> seven0 -> seven -> seven.self` produz saida equivalente.
- `seven verify foundation` substitui o verificador PowerShell.

## Fase 3: produto

- `seven build`
- `seven run`
- `seven check`
- `seven fmt`
- `seven test`
- Diagnosticos com sugestoes.
- Modo estrito de conformidade invalida passando com diagnosticos estaveis.
- Standard library full stack.
- Alvo `web` para frontend.
- Servidor HTTP em `std.web`.
- Protocolos oficiais: SMTP, IMAP, DNS, SNMP, TLS, WebSocket, MQTT.
- Dados e infraestrutura: Redis, filas, CSV, XML, YAML, TOML, Protobuf.
- SIA: inteligencia de linguagem com indice, sugestoes, autofix, riscos e LSP.
- CLI oficial cobre `new`, `init`, `bench`, `lint`, `repl`, `debug`, `profile`,
  `doctor`, `target list` e publicacao de pacotes.

## Fase 4: performance

- Otimizador de IR.
- Compilacao incremental.
- Cache local.
- Alvos nativos.
- Backend WASM sem depender de JavaScript para semantica da linguagem.
- Perfis de runtime `managed`, `owned`, `raw` e `no_std`.
- SIMD, escape analysis, especializacao de generics e layout orientado a cache.

## Fase 5: ecossistema

- Gerenciador de pacotes.
- Servidor de linguagem.
- Documentacao gerada.
- Formatador estavel.
- Guia de contribuicao.
- Biblioteca padrao comparavel a linguagens maduras.
- Ponte opcional com modelos de IA por `std.ai`.
- Registry com hashes, assinaturas, cache offline e politica de compatibilidade.

## Fase 6: mercados

- Gates de `docs/market-readiness.md` cobrem CLI, backend, frontend, full stack,
  sistemas, cloud, dados, IA, financeiro, saude, governo, IoT, desktop, mobile
  e jogos.
- Exemplos oficiais de CRUD, API REST, sockets, banco de dados, WASM,
  biblioteca publicada, projeto completo e observabilidade passam no CI.
- Releases sao reproduziveis, assinados, com SBOM e matriz Windows/Linux/macOS.
- Seven so e anunciada como pronta para qualquer mercado depois que a toolchain
  oficial nao depender de outra linguagem para compilar, testar, empacotar,
  documentar e executar codigo Seven.
