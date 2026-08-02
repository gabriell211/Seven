# Bootstrap Seven

Este diretorio descreve a execucao planejada do nascimento.

## Stage 0

Materializa `seed/genesis.svhex` como seed de alvo e compila `compiler0/seven0.sv`.

```text
seed -> compiler0/seven0.sv -> build/seven0.svbc
```

## Stage 1

Usa `seven0.svbc` para compilar o compilador completo.

```text
seven0 -> compiler/seven.sv -> build/seven.svbc
```

## Stage 2

Usa `seven.svbc` para compilar a si mesmo.

```text
seven -> compiler/seven.sv -> build/seven.self.svbc
```

## Criterio

`build/seven.svbc` e `build/seven.self.svbc` devem ser equivalentes.
