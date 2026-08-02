# Sistema de tipos Seven

## Objetivos

- Erros cedo.
- Codigo de maquina previsivel.
- Genericos sem custo escondido.
- Memoria segura por padrao.
- Interoperabilidade futura sem perder controle.

## Tipos escalares

- `Bit`
- `Byte`
- `Num`
- `I8`, `I16`, `I32`, `I64`
- `U8`, `U16`, `U32`, `U64`
- `Real32`, `Real64`
- `Texto`
- `Nada`

## Compostos

```sv
molde Ponto ::
  x: I32
  y: I32
fecha
```

## Campos como valores

Callbacks usam tipo `Campo<Entrada, Saida>`.

```sv
campo aplica(valor: U32, f: Campo<U32, U32>) -> U32 ::
  devolve f(valor)
fecha
```

Para multiplos parametros, o compilador usa tuplas internas de chamada.

## Alternativas

```sv
selo Talvez<T> ::
  Algo(T)
  Nada
fecha
```

## Genericos

Genericos sao monomorfizados quando isso melhora desempenho e podem ser compartilhados quando o alvo permitir.

```sv
campo primeiro<T>(itens: Fatia<T>) -> Talvez<T> ::
  veja tamanho(itens) == 0 ::
    devolve Nada
  fecha

  devolve Algo(itens @ 0)
fecha
```

## Conversoes

Conversoes implicitas so sao permitidas quando nao perdem informacao.

Exemplos permitidos:

- `U8` para `U16`
- `I32` para `I64`

Exemplos proibidos sem conversao explicita:

- `I64` para `I32`
- `Real64` para `I32`
- `Texto` para `Num`

## Nulos

`nulo` nao pertence automaticamente a todos os tipos. Ausencia deve ser modelada com `Talvez<T>` ou `Resultado<T, E>`.

## Contratos

Campos publicos podem declarar requisitos.

```sv
campo reserva(tamanho: U64) -> Resultado<Bloco, Falha>
  requer tamanho > 0
::
  devolve aloca(tamanho)
fecha
```

Contratos sao usados por diagnosticos, otimizacao e testes gerados.
