# Frontend Seven

Seven trata frontend como parte oficial da linguagem, nao como uma camada improvisada.

## Modulos

- `std.frontend.dom`: componentes, montagem e eventos.
- `std.frontend.state`: estado local.
- `std.frontend.router`: rotas de tela.
- `std.frontend.http`: chamadas do navegador.
- `std.frontend.css`: CSS tipado e folhas de estilo.
- `std.frontend.theme`: tokens e temas.
- `std.frontend.media`: breakpoints e media queries.
- `std.frontend.animation`: keyframes e transicoes.
- `std.frontend.layout`: helpers de layout.
- `std.frontend.assets`: assets e URLs versionadas.
- `std.frontend.bundle`: pacote final de frontend.

## CSS

```sv
solta folha := css("app")
vira folha := css_var(folha, "cor-acao", "#22c55e")

solta declaracoes := lista<DeclaracaoCss>()
lista_coloca(declaracoes, decl("background", var_css("cor-acao")))
lista_coloca(declaracoes, decl("border-radius", "8px"))

vira folha := css_regra(folha, ".botao", declaracoes)

css_injeta(folha)
```

## Temas

```sv
solta t := tema("produto")
vira t := token(t, "cor-fundo", "#0f172a")
vira t := token(t, "cor-texto", "#f8fafc")
```

## Responsividade

```sv
solta mobile := lista<DeclaracaoCss>()
lista_coloca(mobile, decl("grid-template-columns", "1fr"))

vira folha := css_media(folha, media_regra(media(breakpoint_max(640)), ".grid", mobile))
```

## Alvo web

O alvo `web` precisa implementar:

- `frontend_monta`
- `frontend_escuta`
- `frontend_navega`
- `frontend_fetch_texto`
- `frontend_injeta_css`
- `sys_numero`
- `sys_texto_num`
- `sys_texto_u64`
- `sys_texto_concat`
- `sys_obj_novo`
- `sys_obj_pega`
- `sys_obj_define`
- `sys_lista_coloca`
- `sys_lista_pega`
- `sys_css_renderiza`
- `sys_html_renderiza`

## Starter validado

O exemplo `examples/frontend-counter/app.sev` e o starter mais direto para
testar UI interativa hoje. Ele usa somente fonte Seven para:

- montar HTML no DOM;
- injetar CSS;
- registrar evento de click por handler exportado;
- persistir estado em `localStorage`;
- converter `Texto`/`Num` pelo contrato Web.

```text
seven web build examples/frontend-counter/app.sev build/frontend-counter
seven web serve build/frontend-counter 7070
```

O caminho acima e validado no gate `Seven Stage 1 Self-Hosting`.

## CSS e HTML tipados

O exemplo `examples/frontend-rich/app.sev` cobre a camada mais rica: estruturas
Seven de `std.frontend.css` e `std.web.html` sao passadas como handles para o
host Web gerado, que renderiza CSS e HTML sem exigir Node ou JavaScript manual
da aplicacao.

```text
seven web build examples/frontend-rich/app.sev build/frontend-rich
seven web serve build/frontend-rich 7072
```

Este caminho valida:

- `FolhaCss`, `RegraCss` e `DeclaracaoCss`;
- `Elemento`, `Atributo` e `NoHtml`;
- listas e objetos por handle na ABI Web;
- concatenacao de `Texto` no backend Wasm;
- poda de campos nao alcancaveis antes da emissao WebAssembly.

## Principio

Seven deve permitir UI rica sem esconder custo:

- estilos sao dados Seven;
- CSS final e gerado de forma deterministica;
- temas sao tokens;
- assets entram no manifesto;
- o bundle e rastreavel pelo compilador.
