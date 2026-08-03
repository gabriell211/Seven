# C and JavaScript Parity

## Objetivo

Seven deve cobrir dois campos ao mesmo tempo:

- nivel C: memoria, ponteiros, ABI, layout, bits, atomicos, runtime previsivel e
  binarios auditaveis;
- nivel JavaScript: objetos dinamicos, JSON, event loop, rede, frontend, modulo
  web, callbacks e ergonomia para aplicacoes.

Isso nao significa copiar C ou JavaScript. Significa oferecer capacidades
equivalentes em Seven, com tipos, efeitos e verificacao.

## Superficie adicionada

### Nivel C

- `std.mem.alloc`: alocacao, realocacao, liberacao, zero e copia.
- `std.mem.ptr`: ponteiros tipados e operacoes cruas controladas.
- `std.system.bits`: bitwise, deslocamento e contagem de bits.
- `std.sync.atomic`: atomicos `U64` e `Bit`.
- `std.ffi.c`: ABI C/C++ explicita.

### Nivel JavaScript

- `std.data.object`: objeto dinamico tipado por `ValorDinamico`.
- `std.web.json`: JSON como selo fechado.
- `std.runtime.event_loop`: microtarefas, timeout e loop.
- `std.frontend.*`: DOM, estado, rotas, fetch, CSS e bundle.
- `std.web.*`: HTTP, router, cliente e servidor.

## Conformance

Casos obrigatorios:

```text
conformance/libs/valid/system_level.sev
conformance/libs/valid/dynamic_runtime.sev
```

Esses casos entram no `seven verify foundation` por meio de
`compiler/toolchain/library_audit.sev`.

## Ainda faltam para paridade total

- parser e type checker completos para todos os recursos ja documentados;
- emissor SVBC produtivo real, sem envelope `seven-dev-vm-v1`;
- executavel final self-hosted para rodar `build/seven.svbc` sem `seven-dev.ps1`;
- backend nativo com ABI, linkagem, debug info e objetos;
- garbage collector ou ownership completo para cargas JS-like;
- especificacao formal de modelo de memoria concorrente;
- suite de compatibilidade ampla para rede, web, arquivos, unicode e FFI.
