# Bootstrap Seven

Este diretorio implementa a cadeia de nascimento e reconstrução da Seven.

## Stage 0 — Genesis para Seven-0

`bootstrap/stage0.sev` executa `seed/genesis.svhex`, compila `compiler0/seven0.sev`, valida o magic `SVB0` e grava `build/stage0.provenance`.

```text
seed/genesis.svhex
  -> runtime/seed/svs0.sev
  -> compiler0/seven0.sev
  -> build/seven0.svbc
  -> build/stage0.provenance
```

A proveniencia registra executor, entrada, saida e SHA-256 dos tres artefatos.

## Stage 1 — Seven-0 para Seven

Usara `build/seven0.svbc` como executor real para gerar o compilador completo:

```text
build/seven0.svbc -> compiler/seven.sev -> build/seven.svbc
```

Esta etapa ainda nao e considerada concluida enquanto o runtime SVBC0 nao executar o compilador Seven-0 produzido pelo Stage 0.

## Stage 2 — Seven para Seven-Self

Usara `build/seven.svbc` para reconstruir integralmente o mesmo compilador:

```text
build/seven.svbc -> compiler/seven.sev -> build/seven.self.svbc
```

## Criterio final

A cadeia so e self-hosted quando:

- cada etapa foi executada pelo artefato da etapa anterior;
- cada etapa possui manifesto de proveniencia valido;
- `build/seven.svbc` e `build/seven.self.svbc` sao deterministicamente equivalentes;
- nenhum host de transicao compilou diretamente os artefatos finais.
