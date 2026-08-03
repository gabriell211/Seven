# Biblioteca padrao Seven

## Gate

`seven verify foundation` chama a auditoria Seven-native em
`compiler/toolchain/library_audit.sev`. O gate exige os modulos essenciais da
stdlib e os casos de `conformance/libs/valid`.

O verificador legado tambem executa `seven-dev check` em todos os arquivos
`std/**/*.sev` ate que `seven verify foundation` rode diretamente por
`build/seven.svbc`.

## Base

- `std.base.prelude`: importacao padrao.
- `std.base.resultado`: `Resultado<T, E>` e `Falha`.
- `std.base.talvez`: `Talvez<T>`.
- `std.base.texto`: helpers de texto.
- `std.base.lista`: listas genericas.
- `std.base.mapa`: mapas genericos.
- `std.base.convert`: conversoes controladas.

## Memoria

- `std.mem.bytes`: `Bytes`, conversoes texto/bytes e acesso seguro.
- `std.mem.alloc`: alocacao, realocacao, liberacao, zero e copia.
- `std.mem.ptr`: ponteiros tipados dentro de efeito `cru`.
- `std.ffi.c`: tipos e conversoes para ABI C/C++ controlada.

## Entrada e saida

- `std.io.console`: console.
- `std.fs.file`: arquivos.
- `std.env.runtime`: ambiente e argumentos.
- `std.os.process`: processos.
- `std.time.clock`: relogio e espera.

## Rede e protocolos

- `std.net.tcp`: TCP.
- `std.net.udp`: UDP.
- `std.net.tls`: TLS.
- `std.net.dns`: DNS.
- `std.net.snmp`: SNMP para monitoramento de dispositivos.
- `std.net.websocket`: WebSocket.
- `std.net.mqtt`: MQTT.
- `std.mail.smtp`: envio de email SMTP.
- `std.mail.imap`: leitura de email IMAP.
- `std.mail.mime`: mensagens MIME.

## Web

- `std.web.*`: HTTP, server, router, JSON, HTML, forms, cookies, sessao, seguranca e cliente.

## Dados

- `std.db.*`: conexao, query parametrizada e migracoes.
- `std.cache.*`: cache local e Redis.
- `std.queue.*`: filas e mensageria.
- `std.serial.*`: CSV, XML, YAML, TOML e Protobuf.
- `std.data.object`: objeto dinamico tipado para cargas JS-like.

## Seguranca

- `std.crypto.*`: hash e token assinado.
- `std.auth.*`: JWT e OAuth.
- `std.crypto.random`: aleatorio seguro e UUID.

## Concorrencia

- `std.async.task`: tarefas e grupos estruturados.
- `std.sync.atomic`: atomicos para `U64` e `Bit`.
- `std.runtime.event_loop`: microtarefas, temporizadores e loop de eventos.

## Frontend

- `std.frontend.*`: DOM, estado, rotas e fetch.
- `std.frontend.css`: folhas CSS tipadas.
- `std.frontend.theme`: temas e tokens.
- `std.frontend.media`: breakpoints e media queries.
- `std.frontend.animation`: keyframes e transicoes.
- `std.frontend.layout`: helpers de layout.
- `std.frontend.assets`: assets versionados.
- `std.frontend.bundle`: empacotamento web.

## Observabilidade

- `std.log.logger`: logs iniciais.
- `std.observability.metrics`: metricas.
- `std.observability.trace`: traces.

## Inteligencia artificial

- `std.ai.model`: chamadas de modelo.
- `std.ai.embedding`: vetores e similaridade.
- `std.ai.agent`: agentes com ferramentas.

## Utilidades

- `std.text.regex`: expressoes regulares.
- `std.compress.gzip`: compressao gzip.
- `std.archive.zip`: arquivos zip.
- `std.math.core`: matematica comum.
- `std.data.uuid`: UUID.
- `std.system.bits`: operacoes bitwise para cargas C-like.
