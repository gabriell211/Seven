# Desenvolvimento Web com Seven

Este fluxo deixa o desenvolvimento Web centrado em arquivos `.sev`.

## Starter recomendado

```text
examples/web_dev.sev
```

Ele cobre o basico para uma tela de navegador:

- montagem de HTML pelo Seven;
- CSS injetado pelo Seven;
- eventos de input e click;
- armazenamento local;
- leitura de `seven.web.json`;
- geracao de `app.wasm`.

## Ciclo local

```text
seven check examples/web_dev.sev
seven web build examples/web_dev.sev build/web-dev
```

Depois sirva `build/web-dev` com qualquer servidor estatico local. O diretorio
gerado contem:

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
servidor full-stack em `std.web.*` ainda depende do fechamento do backend
nativo self-hosted e dos intrinsecos TCP.

## Regras praticas

- Use `.sev` para codigo de aplicacao.
- Use `std.frontend.intrinsics` enquanto o runtime Web esta sendo endurecido.
- Evite depender de JavaScript escrito manualmente.
- Se dois fontes Web diferentes gerarem o mesmo hash pelo binario local de
  transicao, valide pelo gate E2E ou pelo caminho self-hosted antes de tratar
  isso como prova de producao.
