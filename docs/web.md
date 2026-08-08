# Seven WebAssembly

O alvo web compila código-fonte Seven (`.sev`) diretamente para WebAssembly binário (`.wasm`). Web é um alvo oficial da linguagem, não uma variante separada, portanto não existe `.sevw`.

## Comando

```text
seven web build app.sev
seven web build app.sev dist
```

O pacote contém:

- `app.wasm`: aplicação executável;
- `app.wasm.sha256`: checksum do módulo;
- `index.html`: documento de inicialização;
- `seven-loader.mjs`: ponte gerada para as APIs obrigatórias do navegador;
- `seven.web.json`: manifesto determinístico.

## Política de zero dependência

1. compilador, analisadores, IR, emissor Wasm, ABI e biblioteca são implementados em `.sev`;
2. a aplicação não é transpilada para JavaScript;
3. C, C++, Rust, Go, Python, TypeScript, C#, Java ou LLVM não são dependências do backend;
4. `app.wasm` é sempre o executável principal;
5. o loader gerado apenas instancia o módulo, conecta a ABI e encaminha eventos do navegador;
6. toda função de negócio e todo handler permanecem em Seven/WebAssembly.

## Modelo de texto

Valores `Texto` atravessam a ABI como um descritor de oito bytes na memória linear:

```text
+0  U32 little-endian: ponteiro UTF-8
+4  U32 little-endian: tamanho em bytes
```

A região a partir de `32768` é reservada como inbox para respostas HTTP, valores de eventos e armazenamento. O código estático fica abaixo dela.

## ABI `seven-web-2`

A ABI fornece:

- console: `terminal_diga`;
- DOM: `frontend_monta`, `frontend_texto`, `frontend_atributo`;
- classes: `frontend_classe_adiciona`, `frontend_classe_remove`;
- eventos: `frontend_escuta`, `frontend_evento_valor`;
- navegação: `frontend_navega`;
- estilos: `frontend_injeta_css`;
- HTTP: `frontend_fetch_texto`, `frontend_resposta_texto`, `frontend_resposta_status`;
- armazenamento: `frontend_armazena`, `frontend_carrega`, `frontend_remove`.

Exports:

```text
memory
seven_start() -> I32
seven_<nome-do-handler>() -> I32
```

## Exemplo interativo

Para comecar um projeto de tela no navegador, use tambem o starter:

```text
seven web build examples/web_dev.sev build/web-dev
```

O guia pratico fica em `docs/web-development.md`.

```sev
modulo app

usa std.frontend.intrinsics

campo inicio() -> Num toca frontend ::
  frontend_monta("#seven-app", "<input id=\"nome\"><p id=\"saida\"></p>")
  frontend_escuta("#nome", "input", "nome_mudou")
  devolve 0
fecha

campo nome_mudou() -> Num toca frontend ::
  guarda valor := frontend_evento_valor()
  frontend_texto("#saida", valor)
  devolve 0
fecha
```

## Recursos do backend Wasm

O emissor atual suporta:

- múltiplos campos e exports;
- até quatro parâmetros `I32` por campo;
- locais e movimentação de valores;
- constantes numéricas, booleanas, nulas e textos UTF-8;
- chamadas internas;
- chamadas à ABI do navegador;
- aritmética e comparações inteiras;
- handlers assíncronos de `fetch` por callback exportado;
- manifesto e checksum determinísticos.

Saltos estruturados, laços, alocação dinâmica e o runtime completo de coleções ainda devem ser rejeitados com diagnóstico `SV-WASM-*`; não existe fallback silencioso.

## Servidor web

Os módulos `std.web.*` descrevem HTTP, roteamento, middleware, segurança, sessões e arquivos estáticos. A promoção desses módulos para execução nativa depende do fechamento do backend nativo self-hosted e dos intrínsecos TCP. Até esse gate passar, Seven Web 0.2 deve ser apresentada como runtime de aplicações de navegador, não como plataforma full-stack concluída.
