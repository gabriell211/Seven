# Seven Seed

Este diretorio define o nascimento minimo da Seven.

O seed nao e o compilador oficial. Ele e um artefato pequeno e auditavel que entende **Seven-0**, gera `SVBC0` e permite compilar o primeiro compilador `compiler0`.

## Cadeia

```text
seed/SVS0 -> compiler0/*.sev -> build/seven0.svbc
build/seven0.svbc -> compiler/*.sev -> build/seven.svbc
build/seven.svbc -> compiler/*.sev -> build/seven.self.svbc
```

O marco de self-hosting acontece quando `seven.svbc` e `seven.self.svbc` forem equivalentes.

## Arquivos

- `seven-0.md`: subconjunto da linguagem aceito pelo seed.
- `seven-0.grammar.svbnf`: gramatica formal do Seven-0.
- `svs0.md`: maquina minima do seed.
- `svbc0.md`: bytecode minimo emitido pelo Seven-0.
- `genesis.svhex`: imagem inicial auditavel do seed em hexadecimal.
- `audit.md`: regras de auditoria e reproducibilidade.

## Regra

Nenhum compilador hospedado vira autoridade. A autoridade e a especificacao Seven e a fonte `.sev`.
