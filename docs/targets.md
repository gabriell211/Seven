# Alvos Seven

## `svbc`

Alvo primario de bootstrap. Executa bytecode Seven com VM propria.

Modos:

- `svbc-puro`: apenas intrinsecos puros.
- `svbc-server`: terminal, disco, rede, tempo e ambiente.

## `web`

Alvo oficial de frontend. Compila `.sev` para WebAssembly e usa contratos
`frontend_*` para DOM, eventos, navegacao, requisicoes, armazenamento e CSS.

Tambem precisa suportar conversao de valores usada por apps interativos:

- `frontend_injeta_css`
- `sys_numero`
- `sys_texto_num`
- `sys_texto_u64`
- `sys_texto_concat`
- `sys_obj_novo`
- `sys_obj_pega`
- `sys_obj_define`
- `sys_lista_coloca`
- `sys_iterador_novo`
- `sys_iterador_tem`
- `sys_iterador_atual`
- `sys_iterador_avanca`
- `sys_css_renderiza`
- `sys_html_renderiza`
- `sys_css_media_declaracoes`
- `sys_css_animacao_declaracoes`

Saida:

```text
app.wasm
app.wasm.sha256
index.html
seven-loader.mjs
seven.web.json
```

## `native`

Alvo nativo baixa uma imagem `SVBC` verificada para formato de sistema.

Alvos iniciais:

- `WinX64`
- `LinuxX64`
- `Arm64`

## Capacidades

Todo alvo declara capacidades:

- `CapPura`
- `CapTerminal`
- `CapDisco`
- `CapRede`
- `CapTempo`
- `CapAmbiente`
- `CapFrontend`
- `CapCrypto`

Codigo que usa efeito sem capacidade falha antes de executar.
