modulo std.frontend.state

molde Estado<T> ::
  valor: T
fecha

campo estado<T>(valor: T) -> Estado<T> ::
  devolve Estado<T> {
    valor: valor
  }
fecha

campo altera<T>(estado_atual: Estado<T>, valor: T) -> Estado<T> ::
  vira estado_atual.valor := valor
  devolve estado_atual
fecha
