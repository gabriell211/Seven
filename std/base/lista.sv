modulo std.base.lista

molde Lista<T> ::
  tamanho: U64
fecha

campo lista<T>() -> Lista<T> ::
  devolve Lista<T> {
    tamanho: 0
  }
fecha

campo lista_de<T>(primeiro: T) -> Lista<T> ::
  solta itens := lista<T>()
  lista_coloca(itens, primeiro)
  devolve itens
fecha

campo lista_coloca<T>(itens: Lista<T>, valor: T) -> Lista<T> ::
  devolve sys_lista_coloca(itens, valor)
fecha

campo lista_pega<T>(itens: Lista<T>, indice: U64) -> T ::
  devolve sys_lista_pega(itens, indice)
fecha

campo lista_define<T>(itens: Lista<T>, indice: U64, valor: T) -> Lista<T> ::
  devolve sys_lista_define(itens, indice, valor)
fecha

campo lista_tamanho<T>(itens: Lista<T>) -> U64 ::
  devolve itens.tamanho
fecha

campo reverso<T>(itens: Lista<T>) -> Lista<T> ::
  devolve sys_lista_reverso(itens)
fecha
