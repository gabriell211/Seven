modulo seven.runtime.svbc.verifier

usa std.base.lista
usa seven.runtime.svbc.image
usa seven.runtime.svbc.opcode

molde ErroVerificacao ::
  codigo: Texto
  mensagem: Texto
  ip: U64
fecha

molde ResultadoVerificacao ::
  ok: Bit
  erros: Lista<ErroVerificacao>
fecha

campo verifica_svbc(img: ImagemSvbc) -> ResultadoVerificacao ::
  solta erros := lista<ErroVerificacao>()

  verifica_entrada(img, erros)
  verifica_saltos(img, erros)
  verifica_constantes(img, erros)
  verifica_locais(img, erros)
  verifica_pilha(img, erros)
  verifica_efeitos(img, erros)

  devolve ResultadoVerificacao {
    ok: lista_tamanho(erros) == 0,
    erros: erros
  }
fecha

campo erro_verificacao(erros: Lista<ErroVerificacao>, codigo: Texto, mensagem: Texto, ip: U64) -> Nada ::
  lista_coloca(erros, ErroVerificacao {
    codigo: codigo,
    mensagem: mensagem,
    ip: ip
  })
fecha

campo verifica_entrada(img: ImagemSvbc, erros: Lista<ErroVerificacao>) -> Nada ::
  veja campo_entrada_existe(img, "inicio") == nao ::
    erro_verificacao(erros, "SVBC-ENTRADA", "campo inicio ausente", 0)
  fecha
fecha

campo verifica_saltos(img: ImagemSvbc, erros: Lista<ErroVerificacao>) -> Nada ::
  sys_svbc_verifica_saltos(img, erros)
fecha

campo verifica_constantes(img: ImagemSvbc, erros: Lista<ErroVerificacao>) -> Nada ::
  sys_svbc_verifica_constantes(img, erros)
fecha

campo verifica_locais(img: ImagemSvbc, erros: Lista<ErroVerificacao>) -> Nada ::
  sys_svbc_verifica_locais(img, erros)
fecha

campo verifica_pilha(img: ImagemSvbc, erros: Lista<ErroVerificacao>) -> Nada ::
  sys_svbc_verifica_pilha(img, erros)
fecha

campo verifica_efeitos(img: ImagemSvbc, erros: Lista<ErroVerificacao>) -> Nada ::
  sys_svbc_verifica_efeitos(img, erros)
fecha

campo campo_entrada_existe(img: ImagemSvbc, nome: Texto) -> Bit ::
  para cada campo em img.campos ::
    veja campo.nome == nome ::
      devolve sim
    fecha
  fecha

  devolve nao
fecha
