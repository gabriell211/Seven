# Build auditavel Seven

Este diretorio guarda imagens canonicas pequenas usadas para validar o nascimento da VM.

## Imagens

- `genesis.svs0.svhex`: fita seed `SVS0` materializada sem comentarios.
- `stage0-return0.svbc0.svhex`: imagem `SVBC0` minima que empilha `0`, retorna e para.

## Regra

Arquivos daqui sao auditaveis por texto hexadecimal. Eles nao sao gerados por toolchain hospedeira.

## Proximo marco

Quando a cadeia fisica existir, `stage0-return0.svbc0.svhex` sera substituido por:

```text
compiler0/*.sv -> build/seven0.svbc
```

E depois:

```text
compiler/*.sv -> build/seven.svbc
```
