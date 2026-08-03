modulo examples.worker_queue.main

usa std.cache.redis
usa std.env.runtime
usa std.queue.broker

campo processa(msg: MensagemFila) -> Nada toca rede, terminal ::
  diga "processando " + msg.topico
fecha

campo inicio() -> Num toca rede, ambiente, terminal ::
  guarda broker := fila_conecta(env_ou("QUEUE_URL", "queue://local"))
  guarda cache := redis_conecta(env_ou("REDIS_URL", "redis://local"))

  veja broker e Falha ::
    diga "broker indisponivel"
    devolve 1
  fecha

  veja cache e Falha ::
    diga "cache indisponivel"
    devolve 1
  fecha

  redis_set(cache.valor, "worker:status", "online", 60)
  fila_consumir(broker.valor, "jobs", processa)

  devolve 0
fecha
