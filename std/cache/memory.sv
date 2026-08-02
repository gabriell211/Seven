modulo std.cache.memory

usa std.base.resultado
usa std.base.mapa
usa std.base.talvez

molde CacheMemoria<V> ::
  itens: Mapa<Texto, V>
fecha

campo cache_memoria<V>() -> CacheMemoria<V> ::
  devolve CacheMemoria<V> {
    itens: mapa<Texto, V>()
  }
fecha

campo cache_pega<V>(cache: CacheMemoria<V>, chave: Texto) -> Talvez<V> ::
  devolve mapa_pega(cache.itens, chave)
fecha

campo cache_coloca<V>(cache: CacheMemoria<V>, chave: Texto, valor: V) -> CacheMemoria<V> ::
  mapa_coloca(cache.itens, chave, valor)
  devolve cache
fecha
