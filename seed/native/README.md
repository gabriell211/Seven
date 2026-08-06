# Seven native transition seeds

Esta pasta guarda o primeiro seed nativo auditavel usado para aposentar a ponte
PowerShell e validar a distribuicao da Seven em Windows e Linux.

## Conteudo

O arquivo ZIP e reconstruido pela concatenacao dos fragmentos:

```text
seed/native/archive/native-seeds.b64.00
seed/native/archive/native-seeds.b64.01
seed/native/archive/native-seeds.b64.02
seed/native/archive/native-seeds.b64.03
seed/native/archive/native-seeds.b64.04
seed/native/archive/native-seeds.b64.05
```

Depois da decodificacao, o arquivo `native-seeds.zip` contem:

```text
seven-windows.exe
seven-installer-windows.exe
seven-linux
seven-installer-linux
```

Os hashes oficiais estao em `seed/native/checksums.sha256`.

## Funcao

Os seeds existem para romper a dependencia operacional da ponte PowerShell:

- `seven-windows.exe` e `seven-linux` oferecem a interface minima de bootstrap;
- os instaladores copiam um payload preparado pela toolchain;
- o instalador Windows e um PE x64 com recurso de icone da marca Seven;
- o payload Windows inclui o `brand/seven.ico` completo para atalho,
  associacao `.sev` e desinstalacao;
- o Linux instala `brand/seven-mark.svg` no tema de icones e preserva o ICO no
  payload oficial.

## Preparacao do instalador Windows

O seed PE preservado no ZIP possui `SizeOfStackCommit` de 4 KiB. O instalador
usa um frame inicial maior, portanto o CI aplica uma correcao deterministica no
cabecalho PE antes do empacotamento:

- valida o SHA-256 original do executavel;
- altera somente os 8 bytes de `SizeOfStackCommit` para 128 KiB;
- valida o SHA-256 do executavel preparado;
- executa instalacao, integracao do sistema e desinstalacao no runner Windows.

Os hashes anterior e posterior estao registrados em `checksums.sha256`. Essa
preparacao nao introduz outra linguagem de implementacao e nao modifica o codigo
do instalador.

## Fronteira de confianca

Estes arquivos sao **artefatos binarios de transicao**, nao a implementacao
fonte da linguagem. Nenhum fonte C, C++, Rust, Go, Python, JavaScript,
TypeScript, C# ou PowerShell e armazenado nesta pasta ou usado como fonte
oficial da Seven.

O compilador, runtime, VM, instalador, CLI e bibliotecas permanecem definidos em
`.sev`. A cadeia considerada self-hosted continua sendo:

```text
seed -> seven0 -> seven -> seven.self
```

A existencia destes seeds, isoladamente, nao prova self-hosting. Eles devem ser
substituidos por binarios reproduzidos pela propria toolchain assim que o backend
nativo Seven conseguir gerar PE e ELF equivalentes.

## Reproducibilidade

O CI:

1. concatena os fragmentos Base64;
2. reconstrói `native-seeds.zip`;
3. valida o SHA-256 do ZIP e de cada membro;
4. prepara e valida o instalador PE para Windows;
5. monta os payloads usando somente arquivos do repositorio e imagens SVBC;
6. executa instalacao e desinstalacao em runners Windows e Linux;
7. publica os bundles resultantes como artifacts.

Qualquer alteracao em um seed ou na preparacao de plataforma exige atualizar
`checksums.sha256` e explicar a mudanca no pull request.
