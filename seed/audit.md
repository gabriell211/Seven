# Auditoria do seed

## O que precisa ser auditado

- `genesis.svhex`
- `svs0.md`
- `svbc0.md`
- `seven-0.md`
- `seven-0.grammar.svbnf`
- `compiler0/*.sev`

## Regras

1. O seed nao pode crescer sem justificativa.
2. Cada instrucao nova precisa aparecer em `svs0.md`.
3. Cada emissao nova precisa aparecer em `svbc0.md`.
4. O compilador Seven-0 precisa ser escrito em `.sev`.
5. O resultado deve ser deterministico.

## Hash normalizado

O hash normalizado ignora:

- quebras de linha `CRLF` versus `LF`;
- espacos finais;
- comentarios de auditoria.

Nao ignora:

- bytes de instrucao;
- nomes publicos;
- codigos de diagnostico;
- ordem das secoes.
