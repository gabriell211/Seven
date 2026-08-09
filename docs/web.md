# Seven WebAssembly

O alvo web compila codigo-fonte Seven (`.sev`) diretamente para WebAssembly
binario (`.wasm`). Web e um alvo oficial da linguagem, nao uma variante
separada, portanto nao existe `.sevw`.

## Comando

```text
seven web build app.sev
seven web build app.sev dist
seven web serve dist 7070
```

O pacote gerado por `seven web build` contem:

- `app.wasm`: aplicacao executavel;
- `app.wasm.sha256`: checksum do modulo;
- `index.html`: documento de inicializacao;
- `seven-loader.mjs`: ponte gerada para as APIs obrigatorias do navegador;
- `seven.web.json`: manifesto deterministico.

## Politica de zero dependencia

1. compilador, analisadores, IR, emissor Wasm, ABI e biblioteca sao
   implementados em `.sev`;
2. a aplicacao nao e transpilada para JavaScript;
3. C, C++, Rust, Go, Python, TypeScript, C#, Java ou LLVM nao sao
   dependencias do backend;
4. `app.wasm` e sempre o executavel principal;
5. o loader gerado apenas instancia o modulo, conecta a ABI e encaminha
   eventos do navegador;
6. toda funcao de negocio e todo handler permanecem em Seven/WebAssembly.

## Modelo de texto

Valores `Texto` atravessam a ABI como um descritor de oito bytes na memoria
linear:

```text
+0  U32 little-endian: ponteiro UTF-8
+4  U32 little-endian: tamanho em bytes
```

A regiao a partir de `32768` e reservada como inbox para respostas HTTP,
valores de eventos e armazenamento. O codigo estatico fica abaixo dela.

## ABI `seven-web-2`

A ABI fornece:

- console: `terminal_diga`;
- DOM: `frontend_monta`, `frontend_texto`, `frontend_atributo`;
- classes: `frontend_classe_adiciona`, `frontend_classe_remove`;
- eventos: `frontend_escuta`, `frontend_evento_valor`;
- navegacao: `frontend_navega`;
- estilos: `frontend_injeta_css`;
- HTTP: `frontend_fetch_texto`, `frontend_resposta_texto`,
  `frontend_resposta_status`;
- armazenamento: `frontend_armazena`, `frontend_carrega`, `frontend_remove`;
- conversao: `sys_numero`, `sys_texto_num`, `sys_texto_u64`,
  `sys_texto_concat`;
- objetos/listas: `sys_obj_novo`, `sys_obj_pega`, `sys_obj_define`,
  `sys_lista_coloca`, `sys_lista_pega`, `sys_lista_define`,
  `sys_lista_insere`, `sys_lista_remove`, `sys_lista_pop`;
- renderizacao tipada: `sys_css_renderiza`, `sys_html_renderiza`.

Exports:

```text
memory
seven_start() -> I32
seven_<nome-do-handler>() -> I32
```

## Exemplo interativo

Para comecar um projeto de tela no navegador, use o starter:

```text
seven web build examples/web_dev.sev build/web-dev
seven web serve build/web-dev 7070

seven web build examples/frontend-counter/app.sev build/frontend-counter
seven web serve build/frontend-counter 7071

seven web build examples/frontend-rich/app.sev build/frontend-rich
seven web serve build/frontend-rich 7072
```

Depois abra `http://127.0.0.1:7070/`. O guia pratico fica em
`docs/web-development.md`.

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

- multiplos campos e exports;
- ate quatro parametros `I32` por campo;
- locais e movimentacao de valores;
- constantes numericas, booleanas, nulas e textos UTF-8;
- chamadas internas;
- chamadas a ABI do navegador;
- aritmetica e comparacoes inteiras;
- conversao `Texto`/`Num` pela ABI Web;
- concatenacao de `Texto` via ABI Web;
- objetos/listas por handle no host gerado;
- renderizacao de `std.frontend.css` e `std.web.html`;
- remocao de campos nao alcancaveis antes da emissao Wasm;
- handlers assincronos de `fetch` por callback exportado;
- manifesto e checksum deterministicos.

Saltos estruturados, lacos e alocacao dinamica linear ainda devem ser
rejeitados com diagnostico `SV-WASM-*` quando aparecem em campos alcancaveis.
Objetos e listas ja funcionam no Web por handles do host gerado para suportar
CSS/HTML tipados, mas iteradores, mapas ricos e controle estruturado ainda sao
a proxima etapa antes de declarar paridade frontend completa.

## Servidor web

Os modulos `std.web.*` descrevem HTTP, roteamento, middleware, seguranca,
sessoes e arquivos estaticos. O servidor estatico de desenvolvimento e
executado por `seven web serve <diretorio> [porta]` em cima do host nativo,
TCP, `std.web.http` e leitura segura de arquivos. O gate `Seven Stage 1
Self-Hosting` valida a cadeia self-hosted gerando `seven.webserve.svbc`,
subindo o servidor e lendo o app gerado por HTTP.
