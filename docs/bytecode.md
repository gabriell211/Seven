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
versao:  2 bytes
alvo:    2 bytes
flags:   4 bytes
```

## Secoes

- `nomes`: tabela de nomes.
- `tipos`: descritores de tipos.
- `const`: constantes.
- `campos`: assinaturas e offsets.
- `codigo`: instrucoes.
- `mapa`: origem para diagnostico.

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

## Verificador

Antes de executar ou baixar para binario, `SVBC` deve passar por verificador:

- pilha balanceada;
- tipos consistentes;
- saltos validos;
- acesso local valido;
- efeitos declarados;
- memoria dentro das regras.
