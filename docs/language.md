# Especificacao da linguagem Seven

## Identidade

Nome: **Seven**

Extensao: `.sv`

Compilador: `seven`

Criador: **Gabriel Barcelos**

Seven e uma linguagem de sistemas e aplicacoes. Ela combina abstracoes de alto nivel com acesso controlado a recursos de baixo nivel.

## Arquivo

Um arquivo Seven pode declarar um modulo e importar outros modulos.

```sv
modulo app.servidor

usa std.io.console
usa std.base.resultado
```

## Entrada

O ponto de entrada padrao e:

```sv
campo inicio() -> Num toca terminal ::
  devolve 0
fecha
```

## Blocos

Blocos abrem com `::` e fecham com `fecha`.

```sv
campo inicio() -> Num ::
  devolve 0
fecha
```

## Comentarios

```sv
// comentario de linha
```

## Valores base

- `Num`: inteiro com largura definida pelo alvo.
- `I8`, `I16`, `I32`, `I64`: inteiros assinados.
- `U8`, `U16`, `U32`, `U64`: inteiros sem sinal.
- `Real32`, `Real64`: ponto flutuante.
- `Bit`: `sim` ou `nao`.
- `Texto`: UTF-8.
- `Byte`: octeto.
- `Nada`: ausencia de valor.

## Vinculos

```sv
guarda limite: U32 := 100
solta contador: U32 := 0
vira contador := contador + 1
```

Regras:

- `guarda` cria vinculo imutavel.
- `solta` cria vinculo mutavel.
- `vira` altera somente vinculos mutaveis.
- Sombreamento no mesmo bloco e erro.

## Campos

Campos sao unidades de comportamento.

```sv
campo dobra(valor: U32) -> U32 ::
  devolve valor * 2
fecha
```

Campos podem declarar efeitos.

```sv
campo carregar(caminho: Texto) -> Resultado<Texto, Falha> toca disco ::
  devolve arquivo_ler(caminho)
fecha
```

## Moldes

`molde` define estrutura de dados.

```sv
molde Usuario ::
  id: U64
  nome: Texto
  ativo: Bit
fecha
```

## Selos

`selo` define alternativas fechadas.

```sv
selo Resultado<T, E> ::
  Valor(T)
  Falha(E)
fecha
```

## Decisao

```sv
veja usuario.ativo ::
  diga usuario.nome
outro ::
  diga "inativo"
fecha
```

## Repeticao

```sv
solta i: U32 := 0
gira i < 10 ::
  diga i
  vira i := i + 1
fecha
```

Iteracao sobre colecoes:

```sv
para cada usuario em usuarios ::
  diga usuario.nome
fecha
```

## Memoria segura

```sv
caixa pacote: Byte[4]
marca pacote @ 0 := 83
pega pacote @ 0 -> primeiro
```

`caixa` cria memoria com limite conhecido. `marca` escreve. `pega` le.

## Memoria crua

Memoria crua existe, mas precisa estar dentro de uma zona declarada.

```sv
zona crua ::
  guarda ponteiro: Ptr<Byte> := endereco(0x1000)
fecha
```

Regra: codigo cru nunca pode atravessar uma fronteira publica sem tipo, efeito e justificativa.

## Erros

Seven usa retorno explicito para falhas recuperaveis.

```sv
campo divide(a: U32, b: U32) -> Resultado<U32, Falha> ::
  veja b == 0 ::
    devolve Falha("divisao por zero")
  fecha

  devolve Valor(a / b)
fecha
```

Variantes podem ser testadas diretamente:

```sv
veja resultado e Valor ::
  diga "ok"
outro ::
  diga "falhou"
fecha
```

Falhas irrecuperaveis do compilador sao diagnosticos, nao travamentos silenciosos.

## Efeitos

Efeitos declaram interacao com o mundo:

- `terminal`
- `disco`
- `rede`
- `tempo`
- `ambiente`
- `cru`
- `frontend`
- `teste`

Um campo sem `toca` e puro por padrao.

Campos tambem podem ser valores quando usados como callback:

```sv
guarda acao := campo(ctx: Contexto) -> Resposta ::
  devolve resposta(200, "ok")
fecha
```

## Concorrencia planejada

Seven usara concorrencia estruturada.

```sv
grupo ::
  tarefa usuarios := buscar_usuarios()
  tarefa pedidos := buscar_pedidos()
fecha
```

O grupo nao fecha enquanto as tarefas internas nao tiverem terminado ou sido canceladas.

## Compilacao

Pipeline oficial:

1. `fonte`: carrega bytes e mapas de linha.
2. `varre`: tokens.
3. `monta`: arvore.
4. `liga`: nomes, modulos e pacotes.
5. `mede`: tipos, efeitos, memoria e retornos.
6. `baixa`: IR Seven.
7. `otimiza`: passes independentes.
8. `emite`: bytecode, objeto ou binario.
