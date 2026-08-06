# SVS0: maquina minima do seed

`SVS0` e uma fita de instrucoes portavel usada apenas no bootstrap.

Ela nao substitui `SVBC`. Ela existe para tornar o seed pequeno, verificavel e independente de uma linguagem hospedeira.

## Representacao auditavel

A imagem canonica fica em `seed/genesis.svhex` como hexadecimal textual. O loader:

1. ignora espacos, quebras de linha e comentarios iniciados por `#`;
2. rejeita caracteres nao hexadecimais;
3. materializa os bytes reais;
4. valida magic, versao e tamanho declarado antes da execucao.

## Cabecalho

```text
magic       4 bytes   53 56 53 30  // "SVS0"
versao      2 bytes   00 01
tamanho     4 bytes   numero de bytes de codigo, big-endian
codigo      N bytes
```

## Tipos de celula

- `u8`
- `u32`
- `ptr`
- `span`
- `texto`
- `bytes`

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

## Pilha inicial canonica

Para a compilacao de bootstrap, o runner coloca na pilha:

```text
[ caminho_da_saida, caminho_da_entrada ]
```

O topo e `caminho_da_entrada`. Assim a fita minima nao precisa incorporar caminhos dependentes do repositorio.

## Fluxo Genesis

```text
LE_ARQUIVO
TOKENIZA
MONTA
CONFERE
EMITE_SVBC0
GRAVA_ARQUIVO
RETORNA 0
```

A gravacao usa bytes binarios. Converter o artefato SVBC0 em texto invalida a etapa.

## Falha

Qualquer erro de formato, leitura, compilacao ou gravacao produz diagnostico `SVS0-*` e retorno diferente de zero.
