modulo examples.control

campo inicio() -> Num toca terminal ::
  solta energia: U32 := 3

  gira energia > 0 ::
    diga energia
    vira energia := energia - 1
  fecha

  veja energia == 0 ::
    diga "ciclo completo"
  outro ::
    diga "estado inesperado"
  fecha

  devolve 0
fecha
