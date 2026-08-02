# Runtime e VM Seven

## Objetivo

O runtime Seven executa imagens `SVBC` e valida imagens `SVBC0` do bootstrap.

## Componentes

- `runtime/svbc`: VM completa.
- `runtime/svbc0`: VM minima do Seven-0.
- `runtime/seed`: executor `SVS0`.
- `runtime/platform`: tabela de intrinsecos `sys_*`.
- `runtime/platform/svbc`: registro do alvo `svbc`.
- `runtime/platform/web`: contratos do alvo `web`.
- `runtime/platform/native`: contratos do alvo nativo.

## Fluxo planejado

```text
seed/genesis.svhex
  -> runtime/seed
  -> compiler0/*.sv
  -> build/seven0.svbc
  -> runtime/svbc0
  -> compiler/*.sv
  -> build/seven.svbc
  -> runtime/svbc
```

## Verificacao

Toda imagem passa por:

1. leitura de magic/versionamento;
2. decodificacao de secoes;
3. verificacao de pilha;
4. verificacao de saltos;
5. verificacao de locais;
6. verificacao de efeitos;
7. execucao.

## Intrinsecos

Os intrinsecos `sys_*` sao pontos oficiais de plataforma, nao dependencias de outra linguagem. Cada alvo Seven precisa implementa-los.
