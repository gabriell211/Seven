modulo std.base.mapa

molde Mapa<K, V> ::
  tamanho: U64
fecha

campo mapa<K, V>() -> Mapa<K, V> ::
  devolve Mapa<K, V> {
    tamanho: 0
  }
fecha

campo mapa_coloca<K, V>(m: Mapa<K, V>, chave: K, valor: V) -> Mapa<K, V> ::
  devolve sys_mapa_coloca(m, chave, valor)
fecha

campo mapa_pega<K, V>(m: Mapa<K, V>, chave: K) -> Talvez<V> ::
  devolve sys_mapa_pega(m, chave)
fecha

campo mapa_tem<K, V>(m: Mapa<K, V>, chave: K) -> Bit ::
  devolve sys_mapa_tem(m, chave)
fecha
