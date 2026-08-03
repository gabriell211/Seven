modulo seven.runtime.seed.runner

usa seven.runtime.seed.svs0

campo roda_seed(caminho: Texto) -> Num toca disco, terminal ::
  guarda fita := svs0_carrega(caminho)

  veja fita e Falha ::
    diga "erro lendo seed: " + fita.valor.mensagem
    devolve 1
  fecha

  guarda saida := svs0_executa(fita.valor)

  veja saida e Falha ::
    diga "erro executando seed: " + saida.valor.mensagem
    devolve 1
  fecha

  devolve saida.valor
fecha
