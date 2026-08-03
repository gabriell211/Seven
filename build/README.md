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
compiler0/*.sev -> build/seven0.svbc
```

E depois:

```text
compiler/*.sev -> build/seven.svbc
```

Os arquivos `build/seven0.svbc`, `build/seven.svbc`,
`build/seven.self.svbc`, `build/seven.host.svbc` e
`build/seven.launcher.svbc` sao saidas locais ignoradas pelo Git. O gate de
fundacao pode materializa-los para auditoria. Eles ja usam o cabecalho binario
`SVBC-v1` durante a transicao, mas so viram artefatos de release quando forem
emitidos pela cadeia self-hosted e executarem a CLI real.
