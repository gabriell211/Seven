# Bootstrap Seven

Este diretorio define e audita a cadeia de nascimento e reconstrução da Seven.

## Estado verificado

Os executaveis de transicao 0.2 produzem um arquivo deterministico de 373 bytes ao executar:

```text
seven build compiler0/seven0.sev build/seven0.transition.svbc
```

Esse arquivo possui magic `SVBC`, mas ainda contem o texto-fonte de `compiler0/seven0.sev`. Portanto ele nao e promovido para `build/seven0.svbc` e nao constitui um compilador executavel.

O workflow `Seven Genesis Bootstrap Audit` garante que Windows e Linux continuem identificando esse limite, em vez de considerar magic bytes e determinismo como prova de self-hosting.

## Fundacao do Stage 0

A implementacao preparada para o Stage 0 e:

```text
seed/genesis.svhex
  -> runtime/seed/svs0.sev
  -> compiler0 scanner/parser/check/emitter
  -> build/seven0.svbc
  -> build/stage0.provenance
```

O loader SVS0 agora decodifica a imagem hexadecimal, valida magic, versao e tamanho, preserva os tipos do pipeline Seven-0 e grava bytes binarios. A proveniencia registra executor, entrada, saida e SHA-256.

O Stage 0 somente sera declarado concluido quando o emissor SVBC0 e a VM produzirem e executarem instrucoes reais, sem carregar o texto-fonte como payload.

## Stage 1 — Seven-0 para Seven

```text
build/seven0.svbc -> compiler/seven.sev -> build/seven.svbc
```

O executor precisa ser o `build/seven0.svbc` produzido pelo Genesis, com proveniencia valida.

## Stage 2 — Seven para Seven-Self

```text
build/seven.svbc -> compiler/seven.sev -> build/seven.self.svbc
```

## Criterio final

A cadeia so e self-hosted quando:

- cada etapa foi executada pelo artefato da etapa anterior;
- cada etapa possui manifesto de proveniencia valido;
- `build/seven.svbc` e `build/seven.self.svbc` sao deterministicamente equivalentes;
- o compilador reconstruido gera runtime, WebAssembly, PE e ELF;
- nenhum host de transicao compilou diretamente os artefatos finais.
