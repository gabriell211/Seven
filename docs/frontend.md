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
vira folha := css_regra(folha, ".botao", lista_de(
  decl("background", var_css("cor-acao")),
  decl("border-radius", "8px")
))

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
vira folha := css_media(folha, media_regra(media(breakpoint_max(640)), ".grid", lista_de(
  decl("grid-template-columns", "1fr")
)))
```

## Alvo web

O alvo `web` precisa implementar:

- `frontend_monta`
- `frontend_escuta`
- `frontend_navega`
- `frontend_fetch_texto`
- `frontend_injeta_css`
- `sys_frontend_empacota`

## Principio

Seven deve permitir UI rica sem esconder custo:

- estilos sao dados Seven;
- CSS final e gerado de forma deterministica;
- temas sao tokens;
- assets entram no manifesto;
- o bundle e rastreavel pelo compilador.
