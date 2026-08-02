# Bootstrap da Seven

## Objetivo

Seven precisa nascer sem transformar outra linguagem em identidade oficial do projeto.

O compilador oficial e escrito em Seven. Para o primeiro nascimento, o projeto define um seed minimo em bytes, documentado e auditavel.

## Fases

1. **Seven-0**: subconjunto minimo da linguagem.
2. **SVS0**: fita minima de seed definida em `seed/genesis.svhex`.
3. **compiler0**: compilador Seven-0 escrito em `.sv`.
4. **SVBC0**: bytecode minimo emitido pelo compiler0.
5. **Seven-1**: primeiro compilador completo gerado pela cadeia.
6. **Seven-Self**: `seven` compila o proprio `seven`.
7. **Seven-Pro**: compilacao incremental, otimizacoes e alvos nativos.

## Regra de pureza

O seed nao e produto.
O seed nao e ambiente de execucao.
O seed nao define a linguagem.

Ele existe apenas para atravessar o primeiro vazio tecnico.

## Marco de self-hosting

Seven atinge self-hosting quando estes comandos produzem saidas equivalentes:

```text
seed compila compiler/seven.sv -> seven-a
seven-a compila compiler/seven.sv -> seven-b
seven-b compila compiler/seven.sv -> seven-c
```

`seven-b` e `seven-c` precisam ser binariamente iguais ou equivalentes por hash normalizado.

## Cadeia atual do repositorio

```text
seed/genesis.svhex
build/genesis.svs0.svhex
build/stage0-return0.svbc0.svhex
compiler0/*.sv
compiler/*.sv
std/*.sv
conformance/**/*.sv
```
