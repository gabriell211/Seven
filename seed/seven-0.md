# Seven-0

Seven-0 e o subconjunto minimo da Seven necessario para gerar o primeiro compilador completo.

## Objetivo

Ser pequeno o suficiente para implementacao auditavel e forte o suficiente para escrever um compilador real.

## Permitido

- `modulo`
- `usa`
- `const`
- `molde`
- `selo`
- `campo`
- `guarda`
- `solta`
- `vira`
- `veja`
- `outro`
- `gira`
- `para cada`
- `devolve`
- `falha`
- `diga`
- tipos escalares
- listas concretas
- mapas concretos
- caixas de bytes
- chamadas de campo
- operadores aritmeticos e logicos

## Proibido no Seven-0

- inferencia profunda;
- macros;
- concorrencia;
- ABI externa;
- alocadores customizados;
- genericos abertos fora das formas aprovadas;
- otimizacoes dependentes de alvo;
- memoria crua publica.

## Tipos obrigatorios

- `Nada`
- `Bit`
- `Byte`
- `Num`
- `U32`
- `U64`
- `Texto`
- `Bytes`
- `ListaTexto`
- `ListaToken`
- `ListaNo`
- `ListaDiagnostico`

## Saida

Seven-0 emite `SVBC0`, um bytecode pequeno que depois e traduzido para `SVBC`.

## Diagnosticos minimos

- `S0-LEX-CARACTERE`
- `S0-LEX-TEXTO`
- `S0-PARSE-ESPERADO`
- `S0-NOME-DUPLICADO`
- `S0-NOME-INEXISTENTE`
- `S0-TIPO-INCOMPATIVEL`
- `S0-TIPO-IMUTAVEL`
- `S0-TIPO-RETORNO`
- `S0-MEM-LIMITE`
- `S0-EMIT-NAO-SUPORTADO`
