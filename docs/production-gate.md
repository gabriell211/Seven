# Production Gate

## Objetivo

Este gate registra os dez pontos que precisam estar fechados para a Seven sair
do estado de fundacao e virar compilador de producao self-hosted.

O comando oficial e:

```text
seven verify production
```

O gate de transicao materializa os artefatos ignorados de `build/` e executa
`build/seven.svbc verify foundation`, `build/seven.svbc verify bootstrap` e
`build/seven.svbc verify production`, ainda hospedado pelo runtime de transicao
ate existir o executavel Seven final.

## Dez pontos

1. `build/seven0.svbc` existe.
2. `seven0` gera `build/seven.svbc`.
3. O runtime executa `build/seven.svbc verify foundation`.
4. O runtime executa `build/seven.svbc verify bootstrap` e confirma
   `build/seven.svbc == build/seven.self.svbc`.
5. O CI chama o caminho Seven em vez de assumir PowerShell como produto.
6. `tools/*.ps1` ficam somente como legado de auditoria.
7. `bin/seven.exe` deixa de ser autoritativo; `launcher.sv` e
   `build/seven.launcher.svbc` definem o contrato do launcher Seven-native.
8. O compilador tem gates de semantica, tipos, efeitos, memoria e FFI.
9. O runtime rejeita envelopes de desenvolvimento e valida SVBC produtivo.
10. Release, instalador, biblioteca padrao e libs sao definidos e verificados
    em Seven, com hashes, SBOM e layout.

## Estado atual

O repositorio ja tem a superficie Seven-native para esses pontos. A ponte de
transicao ja materializa `SVBC-v1` binario e executa
`build/seven.svbc verify foundation`, `build/seven.svbc verify bootstrap` e
`build/seven.svbc verify production` com `inicio -> CHAMA executa_cli` e
despacho por `SALTA_SE_NAO`. O artefato novo nao emite mais `seven_cli`, e o CI
ja chama esses comandos antes da auditoria PowerShell. O contrato do launcher agora vive em
`compiler/toolchain/launcher.sv`, gera `build/seven.launcher.svbc` e entra no
instalador/release por manifesto e bytecode. A lacuna real restante e remover o
executor PowerShell de transicao e empacotar `runtime/launcher/seven.sv` como
executavel final.

Por isso, a regra de producao e simples:

```text
SVBC + versao binaria valida + runtime executa verify foundation + runtime executa verify bootstrap + launcher SVBC delega bootstrap + runtime executa verify production + seven == seven.self
```

Sem esses quatro sinais juntos, a Seven continua como fundacao verificavel, nao
como release 1.0 de producao.
