modulo std.observability.metrics

usa std.base.mapa

molde Metrica ::
  nome: Texto
  valor: Real64
  tags: Mapa<Texto, Texto>
fecha

campo contador(nome: Texto, valor: Real64) -> Metrica ::
  devolve Metrica {
    nome: nome,
    valor: valor,
    tags: mapa<Texto, Texto>()
  }
fecha

campo metrica_emite(metrica: Metrica) -> Nada toca ambiente ::
  sys_metrica_emite(metrica)
fecha
