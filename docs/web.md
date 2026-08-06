# Seven WebAssembly

O alvo web compila código-fonte Seven (`.sev`) diretamente para WebAssembly binário (`.wasm`). Web não é uma variante da linguagem e não usa a extensão `.sevw`.

## Comando

```text
seven web build app.sev
seven web build app.sev dist
```

O diretório de saída contém:

- `app.wasm`: aplicação compilada;
- `app.wasm.sha256`: checksum do módulo;
- `index.html`: documento de inicialização;
- `seven-loader.mjs`: ponte mínima para a WebAssembly JavaScript API do navegador;
- `seven.web.json`: manifesto determinístico do pacote.

## Política de zero dependência de outras linguagens

A implementação da Seven Web deve obedecer às seguintes regras:

1. compilador, analisadores, IR, emissor WebAssembly, ABI, runtime e biblioteca padrão são escritos em `.sev`;
2. nenhuma aplicação Seven é transpilada para JavaScript;
3. C, C++, Rust, Go, Python, JavaScript, TypeScript, C#, Java ou LLVM não podem ser dependências do backend;
4. o módulo executável principal é sempre `app.wasm`;
5. o carregador do navegador é um artefato mínimo gerado pelo compilador, não uma implementação do runtime ou da lógica da aplicação;
6. integrações com o navegador passam pela ABI explícita `seven-web-1` e pelo sistema de capacidades da Seven.

Navegadores não instanciam atualmente um módulo WebAssembly autônomo por uma tag HTML sem usar a WebAssembly JavaScript API. Por isso, o pacote inclui uma ponte de inicialização gerada. Ela apenas carrega `app.wasm`, conecta imports da ABI e chama `seven_start`; toda lógica de aplicação permanece no módulo Wasm produzido a partir de Seven.

## ABI inicial

Imports:

```text
seven.terminal_diga(ponteiro: U32, tamanho: U32) -> Nada
```

Exports:

```text
memory
seven_start() -> I32
```

## Subconjunto inicial

A primeira etapa suporta:

- `campo inicio()`;
- retorno constante;
- `diga` com texto constante;
- memória estática de uma página;
- manifesto e checksum determinísticos.

Instruções ainda não baixadas para Wasm são rejeitadas com diagnóstico `SV-WASM-*`. O compilador não deve aceitar silenciosamente um recurso que ainda não implementa.

## Critério para distribuição

O PR do alvo web permanece em draft até que a cadeia self-hosted da Seven consiga reconstruir os compiladores nativos com `seven web build` sem introduzir implementação em outra linguagem. A existência do backend em `.sev` não é suficiente para afirmar que o binário v0.1.0 já oferece o comando.
