# Seven Release Notes

## Seven 0.2.1 Release Notes

Seven 0.2.1 substitui o instalador Windows de transicao do 0.2.0 por um MSI
WiX profissional e validado. O compilador auditado permanece na linha 0.2.0;
este patch corrige a distribuicao e o layout dos artefatos.

### Instalador Windows

- `seven-0.2.1-windows-x64.msi` instala por maquina em
  `%ProgramFiles%\Seven`;
- registra `bin\seven.exe` no PATH da maquina;
- associa arquivos `.sev`;
- cria atalho no Menu Iniciar;
- aparece em Apps & Features e possui desinstalacao limpa;
- embute o payload em cabinet MSI;
- passa pela validacao do Windows Installer no workflow de release.

### Payload de release

- o Windows deixa de publicar o zip com `seven-installer.exe` e passa a
  publicar MSI;
- o payload Windows inclui `seven.svbc`, `seven.host.svbc`,
  `seven.launcher.svbc`, `seven.webbuild.svbc`, `seven.webserve.svbc`,
  biblioteca padrao, licenca, aviso e assets oficiais;
- o pacote Linux preserva o instalador nativo e corrige o layout esperado pelo
  instalador;
- a extensao VSCode passa a ser publicada como `seven-language-0.2.1.vsix`.

### Correção do 0.2.0

O pacote Windows 0.2.0 era um bundle de transicao e nao era o instalador final
da linguagem. Ele colocava o compilador em `payload/bin/seven.exe`, enquanto o
instalador antigo esperava `payload/seven.exe`, alem de nao incluir os
bytecodes Web exigidos pela toolchain. O 0.2.1 substitui esse caminho por MSI.

## Seven 0.2.0 Release Notes

Seven 0.2.0 promove o caminho Seven Web e a extensao VSCode oficial sem
declarar self-hosting completo antes da prova deterministica final.

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
- o backend Wasm emite controle estruturado para os padroes de `veja`,
  `gira` e `para cada`, usando `if`, `block` e `loop` WebAssembly;
- o host Web gerado inclui iteradores e renderizacao de media queries e
  keyframes para `std.frontend.theme`, `std.frontend.media` e
  `std.frontend.animation`;
- o lowering Web remove campos nao alcancaveis antes da emissao Wasm, evitando
  que helpers mortos da std bloqueiem apps de navegador;
- o gate `Seven Stage 1 Self-Hosting` compila `seven.webbuild.svbc`,
  `seven.webserve.svbc`, gera apps Web e testa o servidor por HTTP.

### Editor

- a extensao oficial VSCode em `editors/vscode/seven-language` agora possui
  manifesto `package.json`, README, changelog, licenca e `.vscodeignore`;
- a extensao registra `.sev`, contribui a gramatica TextMate Seven e fornece
  configuracao de comentarios, pares automaticos e folding para blocos da
  linguagem;
- `docs/vscode-extension.md` documenta desenvolvimento local com Extension
  Development Host e empacotamento VSIX via `@vscode/vsce`.

### Limite honesto

React, Tailwind e APIs MDN reais continuam sendo ecossistemas JavaScript/Node.
O objetivo da Seven e oferecer equivalentes nativos da linguagem: componentes,
estado, CSS utilitario/tipado e bindings Web escritos/consumidos em `.sev`. O
runtime Web ja possui objetos/listas por handle, controle estruturado e
iteradores suficientes para CSS/HTML tipados, temas, media queries e keyframes.
Mapas ricos, mais intrinsecos MDN, reatividade/estado de componentes e ergonomia
de design utilities ainda devem ser promovidos antes de declarar uma camada
frontend equivalente a React/Tailwind.

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
