modulo seven.runtime.svbc.runner

usa std.fs.file
usa seven.runtime.platform.capability
usa seven.runtime.platform.svbc.target
usa seven.runtime.svbc.decoder
usa seven.runtime.svbc.verifier
usa seven.runtime.svbc.vm

campo roda_svbc(caminho: Texto) -> Num toca disco, terminal, rede, tempo, ambiente, frontend ::
  guarda dados := arquivo_bytes(caminho)

  veja dados e Falha ::
    diga "erro lendo imagem: " + dados.valor.mensagem
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

  guarda saida := vm_executa(imagem.valor)

  veja saida e Falha ::
    diga "erro executando SVBC: " + saida.valor.mensagem
    devolve 1
  fecha

  devolve saida.valor
fecha
