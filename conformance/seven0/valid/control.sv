modulo conformance.seven0.valid.control

campo inicio() -> Num ::
  solta n: U32 := 3

  gira n > 0 ::
    vira n := n - 1
  fecha

  veja n == 0 ::
    devolve 0
  outro ::
    devolve 1
  fecha
fecha
