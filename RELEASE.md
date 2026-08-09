# Seven Release Notes

## Em desenvolvimento apos 0.1.0

Esta linha prepara o caminho Seven Web 0.2 sem declarar self-hosting completo
antes da prova deterministica final.

### Web e frontend

- `seven web build` gera pacote WebAssembly com `app.wasm`,
  `app.wasm.sha256`, `index.html`, `seven-loader.mjs` e `seven.web.json`;
- `seven web serve <diretorio> [porta]` executa o servidor estatico de
  desenvolvimento pelo host nativo, TCP e leitura segura de arquivos;
- `examples/frontend-counter/app.sev` valida UI interativa em Seven com DOM,
  CSS, evento de click, `localStorage` e conversao `Texto`/`Num`;
- `examples/frontend-rich/app.sev` valida `std.frontend.css` e `std.web.html`
  com CSS/HTML tipados renderizados pelo host WebAssembly gerado;
- a ABI Web inclui `sys_numero`, `sys_texto_num`, `sys_texto_u64`,
  `sys_texto_concat`, objetos/listas por handle, `sys_css_renderiza` e
  `sys_html_renderiza`;
- o lowering Web remove campos nao alcancaveis antes da emissao Wasm, evitando
  que helpers mortos da std bloqueiem apps de navegador;
- o gate `Seven Stage 1 Self-Hosting` compila `seven.webbuild.svbc`,
  `seven.webserve.svbc`, gera apps Web e testa o servidor por HTTP.

### Limite honesto

React, Tailwind e APIs MDN reais continuam sendo ecossistemas JavaScript/Node.
O objetivo da Seven e oferecer equivalentes nativos da linguagem: componentes,
estado, CSS utilitario/tipado e bindings Web escritos/consumidos em `.sev`. O
runtime Web ja possui objetos/listas por handle para CSS/HTML tipados, mas
controle estruturado, iteradores, mapas ricos, media/theme/animation completos
e ergonomia de componentes ainda devem ser promovidos antes de declarar uma
camada frontend equivalente a React/Tailwind.

# Seven 0.1.0 Release Notes

Seven 0.1.0 estabelece a fundacao publica da linguagem, do compilador, do
runtime SVBC e da toolchain escrita em Seven.

## Destaques

- compilador e runtime oficiais em `.sev`;
- lexer, parser, AST, semantica, IR, bytecode e VM;
- sistema de tipos, efeitos e verificacao de memoria;
- CLI, formatter, test runner, LSP, pacotes e release;
- backend nativo declarado para Windows x64 e Linux x64;
- instaladores nativos produzidos pela toolchain Seven;
- ponte PowerShell removida do repositorio e do CI.

## Artefatos

### Nucleo

```text
build/seven0.svbc
build/seven.svbc
build/seven.self.svbc
build/seven.host.svbc
build/seven.launcher.svbc
build/seven.installer.svbc
```

### Compiladores nativos

```text
build/native/windows/seven.exe
build/native/windows/seven.exe.sha256
build/native/linux/seven
build/native/linux/seven.sha256
```

### Instalador Windows x64

```text
build/installers/seven-0.1.0-windows-x64/seven-installer.exe
build/installers/seven-0.1.0-windows-x64/seven-installer.exe.sha256
build/installers/seven-0.1.0-windows-x64/seven-installer.manifest
```

O executavel incorpora `brand/seven.ico`. O payload inclui o compilador,
bytecode, biblioteca padrao, licenca, aviso e os assets oficiais.

### Instalador Linux x64

```text
build/installers/seven-0.1.0-linux-x64/seven-installer
build/installers/seven-0.1.0-linux-x64/seven-installer.sha256
build/installers/seven-0.1.0-linux-x64/seven-installer.manifest
```

O pacote instala `brand/seven-mark.svg` no tema de icones e inclui
`brand/seven.ico` no payload.

## Geracao

```text
seven build seven.pkg build/seven.svbc
seven build seven.pkg build/seven.host.svbc
seven build seven.pkg build/seven.launcher.svbc
seven build seven.pkg build/seven.installer.svbc
seven installer windows-x64
seven installer linux-x64
seven release
```

## Verificacao

```text
seven verify foundation
seven verify bootstrap
seven verify production
```

O workflow oficial nao executa PowerShell. Os arquivos historicos
`seven-dev.ps1`, `seven-lsp.ps1`, `verify-foundation.ps1` e
`Seven.Foundation.psm1` foram removidos.

## Integridade

Cada compilador e instalador possui SHA-256. O release tambem gera SBOM com os
artefatos do host, launcher, compiladores, instaladores e icones.

## Limite do release

A declaracao de self-hosting completo depende da prova deterministica:

```text
seed -> seven0 -> seven -> seven.self
```

Os hashes de `seven` e `seven.self` devem ser equivalentes no gate final.

## Criador

Gabriel Barcelos (`gabriell211`).
