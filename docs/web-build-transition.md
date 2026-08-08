# Seven Web build transition

O backend WebAssembly oficial e definido pelos fontes Seven em `compiler/`, em especial pelo caminho:

```text
fonte .sev
  -> lexer/parser
  -> semantica
  -> IR
  -> prepara_ir_web
  -> emite_wasm
  -> app.wasm
```

O artefato `seed/native/final/v1` continua sendo um compilador de transicao auditado. Ele nao e a fonte de verdade do backend web e nao pode ser usado como prova isolada de que aplicacoes interativas funcionam.

A regressao rastreada em #30 demonstrou exatamente esse risco: o seed aceitava `seven web build`, produzia WebAssembly estruturalmente valido e executava `seven_start`, mas descartava os corpos que deveriam chamar `frontend_*`.

Por isso o gate WebAssembly passa a reconstruir a cadeia versionada de bootstrap, compilar o frontend/backend atuais e testar dois programas reais:

- `examples/web_app.sev`;
- `website/site.sev`.

O gate exige:

- `WebAssembly.validate` para os dois modulos;
- hashes diferentes para fontes semanticamente diferentes;
- chamadas reais a `frontend_injeta_css`, `frontend_monta` e `frontend_escuta`;
- handlers Seven exportados;
- HTML e CSS concatenados preservados no site oficial.

Os binarios de transicao so podem voltar a ser considerados prova do comando distribuido quando forem reconstruidos a partir de uma origem versionada e o mesmo E2E for executado sobre eles. Ate esse cutover, nenhuma alteracao em Base64 ou hashes deve ser tratada como correcao verificavel do compilador.
