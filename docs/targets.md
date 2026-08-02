# Alvos Seven

## `svbc`

Alvo primario de bootstrap. Executa bytecode Seven com VM propria.

Modos:

- `svbc-puro`: apenas intrinsecos puros.
- `svbc-server`: terminal, disco, rede, tempo e ambiente.

## `web`

Alvo de frontend. Usa contratos `frontend_*` para DOM, eventos, navegacao e requisicoes.

Tambem precisa suportar CSS:

- `frontend_injeta_css`
- `sys_frontend_empacota`

Saida planejada:

```text
pacote-web
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
