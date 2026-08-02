modulo std.base.talvez

selo Talvez<T> ::
  Algo(T)
  Vazio
fecha

campo tem_valor<T>(valor: Talvez<T>) -> Bit ::
  veja valor e Algo ::
    devolve sim
  outro ::
    devolve nao
  fecha
fecha
