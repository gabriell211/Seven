# Desenvolvimento Web com Seven

Este fluxo deixa o desenvolvimento Web centrado em arquivos `.sev`.

## Starter recomendado

```text
examples/web_dev.sev
examples/frontend-counter/app.sev
examples/frontend-rich/app.sev
```

`examples/web_dev.sev` cobre o basico para uma tela de navegador:

- montagem de HTML pelo Seven;
- CSS injetado pelo Seven;
- eventos de input e click;
- armazenamento local;
- leitura de `seven.web.json`;
- geracao de `app.wasm`.

`examples/frontend-counter/app.sev` e o starter de componente interativo: monta
uma UI de contador, injeta CSS Seven, registra handler de click, usa
`localStorage` e converte `Texto`/`Num` sem Node ou JavaScript manual.

`examples/frontend-rich/app.sev` valida CSS e HTML tipados: usa
`std.frontend.css`, `std.web.html`, listas, objetos por handle e concatenacao
de texto no Wasm.

## Ciclo local

```text
seven check examples/web_dev.sev
seven web build examples/web_dev.sev build/web-dev
seven web serve build/web-dev 7070

seven check examples/frontend-counter/app.sev
seven web build examples/frontend-counter/app.sev build/frontend-counter
seven web serve build/frontend-counter 7071

seven check examples/frontend-rich/app.sev
seven web build examples/frontend-rich/app.sev build/frontend-rich
seven web serve build/frontend-rich 7072
```

Depois abra `http://127.0.0.1:7070/`. O diretorio gerado contem:

```text
app.wasm
app.wasm.sha256
index.html
seven-loader.mjs
seven.web.json
```

O fonte da aplicacao continua sendo somente `.sev`; `seven-loader.mjs` e um
artefato gerado para conectar WebAssembly ao navegador.

## Contrato atual

Seven Web 0.2 deve ser usado como runtime de aplicacoes de navegador. O backend
WebAssembly interativo e validado pelo gate `Seven WebAssembly` no GitHub. O
servidor estatico de desenvolvimento e validado no gate `Seven Stage 1
Self-Hosting` usando `seven web serve` em cima do host nativo, TCP,
`std.web.http` e leitura segura de arquivos.

## Regras praticas

- Use `.sev` para codigo de aplicacao.
- Use `std.frontend.intrinsics` enquanto o runtime Web esta sendo endurecido.
- Evite depender de JavaScript escrito manualmente.
- Use `seven web serve` para testar localmente o diretorio gerado sem Node.
- Use `examples/frontend-counter` quando precisar validar DOM, evento,
  armazenamento e conversao numerica no mesmo app.
- Use `examples/frontend-rich` quando precisar validar CSS/HTML tipados pela
  std e objetos/listas na ABI Web.
- Se dois fontes Web diferentes gerarem o mesmo hash pelo binario local de
  transicao, valide pelo gate E2E ou pelo caminho self-hosted antes de tratar
  isso como prova de producao.
