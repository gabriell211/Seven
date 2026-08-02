modulo examples.memory

campo inicio() -> Num toca terminal ::
  caixa pacote: Byte[4]

  marca pacote @ 0 := 83
  marca pacote @ 1 := 86

  pega pacote @ 0 -> primeiro
  pega pacote @ 1 -> segundo

  diga primeiro
  diga segundo
  devolve 0
fecha
