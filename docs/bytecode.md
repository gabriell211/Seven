# Seven Bytecode `SVBC`

## Papel

`SVBC` e o formato intermediario executavel da Seven. Ele permite:

- bootstrap mais simples;
- testes deterministas;
- otimizacao independente de plataforma;
- validacao antes de gerar binarios nativos.

## Cabecalho

```text
magic:   4 bytes  "SVBC"
versao:  4 bytes  u32 big-endian
```

## Secoes v1

As secoes v1 aparecem em ordem fixa, cada uma com contador `u32`
big-endian:

- `nomes`: `count`, seguido de textos UTF-8 como `len u32 + bytes`.
- `const`: `count`, seguido de `tag byte + payload`.
- `campos`: `count`, seguido de nome, entrada, locais, parametros e efeitos.
- `codigo`: `count`, seguido de opcode e operandos.

O bridge de transicao ja emite esse layout para smoke tests simples. A cadeia
self-hosted so fecha quando o compilador Seven emitir esse mesmo layout com
semantica completa.

## Instrucoes iniciais

```text
PARE
CONST indice
CARREGA local
GUARDA local
SOMA
SUB
MUL
DIV
SALTA destino
SALTA_SE_NAO destino
CHAMA campo
VOLTA
CAIXA tamanho
MARCA_BYTE
PEGA_BYTE
EFEITO id
SYSCALL id
```

O bridge de transicao usa:

```text
CARREGA 0
CHAMA executa_cli 1
VOLTA
```

para representar `inicio(argumentos) -> executa_cli(argumentos)`.
`executa_cli` usa branches `SALTA_SE_NAO` para escolher `--help`, `--version`,
`verify foundation`, `verify bootstrap` e `verify production`, chamando intrinsecos pequenos como
`seven_args_verify_foundation`, `seven_verify_foundation`,
`seven_args_verify_bootstrap`, `seven_verify_bootstrap`,
`seven_args_verify_production` e `seven_verify_production`. O antigo syscall
agregado `seven_cli` nao e mais emitido por `build/seven.svbc`.

O subset produtivo validado pelo gate cobre:

- `CONST`, `CARREGA`, `GUARDA`;
- aritmetica `SOMA`, `SUB`, `MUL`, `DIV`;
- comparacoes `IGUAL`, `DIFERENTE`, `MENOR`, `MENOR_IGUAL`, `MAIOR`,
  `MAIOR_IGUAL`;
- `CHAMA`, `VOLTA`, `SALTA`, `SALTA_SE_NAO` e `SYSCALL`.

Com isso, programas simples com variaveis locais, `veja/outro`, `gira`,
aritmetica, comparacao, chamada de campo e saida de terminal ja rodam como
`SVBC-v1` binario.

## Verificador

Antes de executar ou baixar para binario, `SVBC` deve passar por verificador:

- pilha balanceada;
- tipos consistentes;
- saltos validos;
- acesso local valido;
- efeitos declarados;
- memoria dentro das regras.
