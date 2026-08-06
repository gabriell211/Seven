# Auditoria do seed

## O que precisa ser auditado

- `genesis.svhex`
- `svs0.md`
- `svbc0.md`
- `seven-0.md`
- `seven-0.grammar.svbnf`
- `compiler0/*.sev`
- `runtime/seed/*.sev`
- `build/stage0.provenance`

## Regras

1. O seed nao pode crescer sem justificativa.
2. Cada instrucao nova precisa aparecer em `svs0.md`.
3. Cada emissao nova precisa aparecer em `svbc0.md`.
4. O compilador Seven-0 precisa ser escrito em `.sev`.
5. O resultado deve ser deterministico.
6. O loader precisa rejeitar magic, versao, tamanho ou hexadecimal invalidos.
7. O artefato deve ser gravado como bytes, nunca convertido em texto.
8. A etapa precisa registrar executor, entrada, saida e SHA-256.
9. Windows e Linux precisam produzir o mesmo hash para `build/seven0.svbc`.

## Proveniencia

O manifesto `seven-bootstrap-provenance-v1` contem:

```text
etapa
executor
executor_sha256
entrada
entrada_sha256
saida
saida_sha256
```

Uma etapa sem manifesto, com arquivo ausente ou hash divergente nao pode alimentar a etapa seguinte.

## Hash normalizado

Para fontes e especificacoes, o hash normalizado pode ignorar:

- quebras de linha `CRLF` versus `LF`;
- espacos finais;
- comentarios de auditoria.

Nao ignora:

- bytes de instrucao;
- nomes publicos;
- codigos de diagnostico;
- ordem das secoes.

Artefatos binarios usam SHA-256 dos bytes exatos, sem normalizacao.
