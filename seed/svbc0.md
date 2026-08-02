# SVBC0

`SVBC0` e o bytecode minimo emitido pelo Seven-0.

## Cabecalho

```text
magic       "SVB0"
versao      1
constantes  tabela
campos      tabela
codigo      instrucoes
```

## Instrucoes

```text
00 PARE
01 CONST_U32
02 CONST_TEXTO
03 LOCAL_LE
04 LOCAL_GRAVA
05 SOMA
06 SUB
07 MUL
08 DIV
09 IGUAL
0A MENOR
0B SALTA
0C SALTA_FALSO
0D CHAMA
0E RETORNA
0F CAIXA
10 MARCA_BYTE
11 PEGA_BYTE
12 EFEITO
```

## Verificacao

Todo `SVBC0` deve ser verificavel antes de executar:

- pilha balanceada;
- locais existentes;
- saltos validos;
- chamadas conhecidas;
- efeitos declarados;
- acesso de byte com checagem quando limite nao for constante.
