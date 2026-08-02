# SVS0: maquina minima do seed

`SVS0` e uma fita de instrucoes portavel usada apenas no bootstrap.

Ela nao substitui `SVBC`. Ela existe para tornar o seed pequeno, verificavel e independente de uma linguagem hospedeira.

## Cabecalho

```text
magic       4 bytes   53 56 53 30  // "SVS0"
versao      2 bytes   00 01
tamanho     4 bytes   numero de bytes de codigo
codigo      N bytes
```

## Tipos de celula

- `u8`
- `u32`
- `ptr`
- `span`

## Instrucoes

```text
00 PARE
01 FALHA codigo mensagem
02 EMPILHA_U8 valor
03 EMPILHA_U32 valor
04 EMPILHA_TEXTO indice_const
05 LE_ARQUIVO
06 GRAVA_ARQUIVO
07 TOKENIZA
08 MONTA
09 CONFERE
0A EMITE_SVBC0
0B JUNTA_CAMINHO
0C MOSTRA
0D RETORNA codigo
```

## Contrato minimo

O seed precisa executar este fluxo:

```text
entrada .sv
LE_ARQUIVO
TOKENIZA
MONTA
CONFERE
EMITE_SVBC0
GRAVA_ARQUIVO
RETORNA 0
```

## Falha

Qualquer erro produz diagnostico com codigo `S0-*` e retorno diferente de zero.
