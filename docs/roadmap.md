# Roadmap Seven

## Fase 0: fundacao

- Especificacao central.
- Gramatica.
- Modelo de tipos.
- Modelo de memoria.
- Efeitos.
- Bytecode.
- Fonte inicial do compilador em `.sv`.

## Fase 1: Seven-0

- Subconjunto minimo definido.
- Tokens, AST, nomes e tipos basicos.
- Emissao de `SVBC0`.
- Seed auditavel `SVS0`.
- Compilador minimo `compiler0`.

## Fase 2: self-hosting

- `seven` compila `compiler/seven.sv`.
- Builds repetidos sao equivalentes.
- Suite de conformidade em `.sv`.

## Fase 3: produto

- `seven build`
- `seven run`
- `seven check`
- `seven fmt`
- `seven test`
- Diagnosticos com sugestoes.
- Standard library full stack.
- Alvo `web` para frontend.
- Servidor HTTP em `std.web`.
- Protocolos oficiais: SMTP, IMAP, DNS, SNMP, TLS, WebSocket, MQTT.
- Dados e infraestrutura: Redis, filas, CSV, XML, YAML, TOML, Protobuf.
- SIA: inteligencia de linguagem com indice, sugestoes, autofix, riscos e LSP.

## Fase 4: performance

- Otimizador de IR.
- Compilacao incremental.
- Cache local.
- Alvos nativos.

## Fase 5: ecossistema

- Gerenciador de pacotes.
- Servidor de linguagem.
- Documentacao gerada.
- Formatador estavel.
- Guia de contribuicao.
- Biblioteca padrao comparavel a linguagens maduras.
- Ponte opcional com modelos de IA por `std.ai`.
