# Seven Full Stack Kit

Seven deve permitir projetos frontend, backend e fullstack com a biblioteca padrao oficial.

## Backend

Modulos principais:

- `std.web.http`: requisicao, resposta, headers e status.
- `std.web.router`: rotas, parametros e contexto.
- `std.web.server`: servidor HTTP.
- `std.web.middleware`: pipeline de middlewares.
- `std.web.security`: headers seguros e CORS.
- `std.web.cookie`: cookies seguros.
- `std.web.session`: sessoes assinadas.
- `std.web.forms`: formularios.
- `std.web.json`: JSON.
- `std.db.client`: conexao e execucao de queries.
- `std.db.query`: queries parametrizadas.
- `std.db.migrate`: migracoes.
- `std.crypto.hash`: hashes.
- `std.crypto.token`: tokens assinados.
- `std.mail.smtp`: envio de emails.
- `std.mail.imap`: leitura de emails.
- `std.net.snmp`: monitoramento SNMP.
- `std.net.websocket`: conexoes em tempo real.
- `std.cache.redis`: cache externo.
- `std.queue.broker`: filas.
- `std.observability.metrics`: metricas.
- `std.observability.trace`: tracing.
- `std.auth.jwt`: JWT.
- `std.auth.oauth`: OAuth.
- `std.config.app`: configuracao por ambiente.
- `std.log.logger`: logs estruturados iniciais.

## Frontend

Modulos principais:

- `std.frontend.dom`: montagem, eventos e componentes.
- `std.frontend.state`: estado de componente.
- `std.frontend.router`: rotas de tela.
- `std.frontend.http`: chamadas HTTP do navegador.
- `std.frontend.css`: CSS tipado.
- `std.frontend.theme`: tokens de design.
- `std.frontend.media`: responsividade.
- `std.frontend.animation`: animacoes.
- `std.frontend.bundle`: empacotamento frontend.
- `std.web.html`: construcao e renderizacao HTML.

## Exemplos oficiais

- `examples/api-server`: API HTTP.
- `examples/frontend-counter`: componente frontend.
- `examples/fullstack-blog`: servidor com HTML, formularios e banco.
- `examples/auth-system`: login, sessao, cookie e token.
- `examples/mail-smtp`: envio SMTP.
- `examples/snmp-monitor`: monitoramento SNMP.
- `examples/worker-queue`: worker com fila e cache.
- `examples/ai-assistant`: assistente de IA em Seven.

## Filosofia

Seven full stack nao deve esconder custo nem seguranca:

- banco usa parametros, nao concatenacao perigosa;
- sessoes usam tokens assinados;
- headers seguros ficam na std;
- efeitos declaram `rede`, `disco`, `tempo`, `ambiente` e `frontend`;
- frontend e backend compartilham tipos Seven.

## Estado

As APIs oficiais foram definidas em `.sv`. O proximo passo e ligar essas APIs ao backend de execucao do `SVBC` e aos alvos `svbc`, `wasm` e binario nativo.
