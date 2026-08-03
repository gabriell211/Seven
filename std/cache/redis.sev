modulo std.cache.redis

usa std.base.resultado
usa std.base.talvez

molde Redis ::
  id: U64
fecha

campo redis_conecta(url: Texto) -> Resultado<Redis, Falha> toca rede ::
  devolve sys_redis_conecta(url)
fecha

campo redis_get(redis: Redis, chave: Texto) -> Resultado<Talvez<Texto>, Falha> toca rede ::
  devolve sys_redis_get(redis, chave)
fecha

campo redis_set(redis: Redis, chave: Texto, valor: Texto, ttl_segundos: U64) -> Resultado<Nada, Falha> toca rede ::
  devolve sys_redis_set(redis, chave, valor, ttl_segundos)
fecha

campo redis_del(redis: Redis, chave: Texto) -> Resultado<Nada, Falha> toca rede ::
  devolve sys_redis_del(redis, chave)
fecha
