modulo seven.runtime.svbc.runner

usa std.fs.file
usa std.mem.bytes
usa seven.runtime.platform.capability
usa seven.runtime.platform.svbc.target
usa seven.runtime.svbc.decoder
usa seven.runtime.svbc.verifier
usa seven.runtime.svbc.vm

campo roda_svbc(caminho: Texto) -> Num toca disco, terminal, rede, tempo, ambiente, frontend ::
  devolve roda_svbc_com_args(caminho, lista<Texto>())
fecha

campo roda_svbc_com_args(caminho: Texto, argumentos: Lista<Texto>) -> Num toca disco, terminal, rede, tempo, ambiente, frontend ::
  guarda dados := arquivo_bytes(caminho)

  veja dados e Falha ::
    diga "erro lendo imagem: " + dados.valor.mensagem
    devolve 1
  fecha

  veja formato_svbc_produtivo(dados.valor) == nao ::
    diga "erro decodificando SVBC: artefato ainda nao e bytecode produtivo"
    devolve 1
  fecha

  guarda imagem := svbc_decodifica(dados.valor)

  veja imagem e Falha ::
    diga "erro decodificando SVBC: " + imagem.valor.mensagem
    devolve 1
  fecha

  guarda verificacao := verifica_svbc(imagem.valor)

  veja verificacao.ok == nao ::
    diga "SVBC invalido"
    devolve 1
  fecha

  guarda alvo := alvo_svbc_servidor()
  guarda caps := confere_capacidades(imagem.valor, alvo.capacidades)

  veja caps.ok == nao ::
    diga "capacidade ausente para efeito: " + junta_com(", ", caps.faltantes)
    devolve 1
  fecha

  guarda saida := vm_executa_com_args(imagem.valor, argumentos)

  veja saida e Falha ::
    diga "erro executando SVBC: " + saida.valor.mensagem
    devolve 1
  fecha

  devolve saida.valor
fecha

campo roda_seven_svbc_verify_foundation() -> Num toca disco, terminal, rede, tempo, ambiente, frontend ::
  solta argumentos := lista<Texto>()
  lista_coloca(argumentos, "verify")
  lista_coloca(argumentos, "foundation")

  devolve roda_svbc_com_args("build/seven.svbc", argumentos)
fecha

campo roda_seven_svbc_verify_bootstrap() -> Num toca disco, terminal, rede, tempo, ambiente, frontend ::
  solta argumentos := lista<Texto>()
  lista_coloca(argumentos, "verify")
  lista_coloca(argumentos, "bootstrap")

  devolve roda_svbc_com_args("build/seven.svbc", argumentos)
fecha

campo roda_seven_svbc_verify_production() -> Num toca disco, terminal, rede, tempo, ambiente, frontend ::
  solta argumentos := lista<Texto>()
  lista_coloca(argumentos, "verify")
  lista_coloca(argumentos, "production")

  devolve roda_svbc_com_args("build/seven.svbc", argumentos)
fecha

campo formato_svbc_produtivo(dados: Bytes) -> Bit ::
  veja dados.tamanho < 8 ::
    devolve nao
  fecha

  veja bytes_pega(dados, 0) != 83 ::
    devolve nao
  fecha

  veja bytes_pega(dados, 1) != 86 ::
    devolve nao
  fecha

  veja bytes_pega(dados, 2) != 66 ::
    devolve nao
  fecha

  veja bytes_pega(dados, 3) != 67 ::
    devolve nao
  fecha

  veja bytes_pega(dados, 4) != 0 ::
    devolve nao
  fecha

  veja bytes_pega(dados, 5) != 0 ::
    devolve nao
  fecha

  veja bytes_pega(dados, 6) != 0 ::
    devolve nao
  fecha

  veja bytes_pega(dados, 7) != 1 ::
    devolve nao
  fecha

  devolve sim
fecha
