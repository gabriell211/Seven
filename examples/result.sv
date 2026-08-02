modulo examples.result

usa std.base.resultado

campo divide(a: U32, b: U32) -> Resultado<U32, Falha> ::
  veja b == 0 ::
    devolve Falha(nova_falha("SV-EXEMPLO-DIVISAO", "divisao por zero"))
  fecha

  devolve Valor(a / b)
fecha

campo inicio() -> Num toca terminal ::
  guarda resultado := divide(84, 2)

  veja resultado e Valor ::
    diga "resultado calculado"
  outro ::
    diga "falha calculando resultado"
  fecha

  devolve 0
fecha
