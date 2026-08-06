# Seven native transition seeds

Esta pasta guarda os seeds nativos auditaveis usados para iniciar e validar a
distribuicao da Seven em Windows x64 e Linux x64.

## Arquivo versionado

O arquivo `native-seeds.zip` e reconstruido pela concatenacao dos fragmentos:

```text
seed/native/final/v1/part01.b64
seed/native/final/v1/part02.b64
seed/native/final/v1/part03.b64
seed/native/final/v1/part04.b64
seed/native/final/v1/part05.b64
```

O ZIP contem:

```text
seven-windows.exe
seven-installer-windows.exe
seven-linux
seven-installer-linux
```

Os hashes do arquivo e de cada membro ficam em:

```text
seed/native/final/v1/SHA256SUMS
```

## Comportamento verificado

Os compiladores de transicao para Windows e Linux fornecem a superficie minima
necessaria para validar a linguagem enquanto o self-hosting completo e fechado:

```text
seven --version
seven check <arquivo.sev>
seven build <arquivo.sev> <saida.svbc>
seven run <arquivo.sev>
seven doctor
```

O checker nativo executa analise estrutural e semantica suficiente para os gates
atuais, incluindo:

- comentarios de bloco aninhados;
- delimitadores e blocos balanceados;
- nomes duplicados e nomes inexistentes;
- incompatibilidades basicas de tipos;
- mutabilidade;
- retornos obrigatorios;
- propagacao de efeitos;
- limites constantes de memoria;
- validacao de magic SVBC constante.

O workflow de prontidao exige que todos os programas em diretorios `valid`
sejam aceitos e todos os programas em diretorios `invalid` sejam rejeitados.
Um seed nao pode ser promovido apenas por responder a comandos ou produzir um
arquivo com cabecalho SVBC.

## Instaladores

Os instaladores permanecem membros do mesmo arquivo auditado. O CI monta os
payloads, instala, executa e remove a distribuicao nas duas plataformas.

No Windows, o instalador registra PATH, associacao `.sev`, atalho e entrada de
desinstalacao. No Linux, instala o compilador, link em `~/.local/bin`, desktop,
MIME e icone.

## Fronteira de confianca

Os executaveis desta pasta sao **artefatos binarios de transicao**, nao a prova
final de self-hosting. A implementacao oficial continua definida em `.sev`:

```text
compiler/
compiler0/
runtime/
std/
```

A cadeia de producao permanece:

```text
seed -> seven0 -> seven -> seven.self
```

A existencia dos seeds nao prova que `seven` recompila a si mesmo. Essa prova so
existe quando a toolchain Seven gera novamente os executaveis e bytecodes com
resultado deterministico equivalente.

## Regra de alteracao

Qualquer mudanca exige, no mesmo pull request:

1. recompilar os alvos Windows e Linux;
2. executar os casos validos e invalidos;
3. reconstruir o ZIP de forma deterministica;
4. atualizar os fragmentos Base64 e `SHA256SUMS`;
5. atualizar os hashes em `foundation.yml` e `readiness.yml`;
6. executar instalacao e desinstalacao nos dois sistemas.
