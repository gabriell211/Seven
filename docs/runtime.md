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
  -> compiler0/*.sev
  -> build/seven0.svbc
  -> runtime/svbc0
  -> compiler/*.sev
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

## Runner de fundacao

O runner oficial em Seven fica em `runtime/svbc/runner.sev`.
Enquanto o bootstrap Windows ainda emite apenas o envelope inicial, o runner de
desenvolvimento executa imagens `SVBC` de fundacao:

```powershell
.\tools\seven-dev.ps1 build .\examples\hello.sev .\build\hello.svbc
.\tools\seven-dev.ps1 run .\build\hello.svbc
```

## Intrinsecos

Os intrinsecos `sys_*` sao pontos oficiais de plataforma, nao dependencias de outra linguagem. Cada alvo Seven precisa implementa-los.
