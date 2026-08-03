modulo seven.runtime.svbc.command_runner

usa std.base.resultado
usa std.fs.file
usa seven.runtime.svbc.runner

molde ComandoSvbc ::
  imagem: Texto
  argumentos: Lista<Texto>
fecha

molde ResultadoComandoSvbc ::
  codigo: Num
  imagem: Texto
  comando: Texto
fecha

campo comando_verify_foundation() -> ComandoSvbc ::
  solta args := lista<Texto>()
  lista_coloca(args, "verify")
  lista_coloca(args, "foundation")

  devolve ComandoSvbc {
    imagem: "build/seven.svbc",
    argumentos: args
  }
fecha

campo comando_verify_bootstrap() -> ComandoSvbc ::
  solta args := lista<Texto>()
  lista_coloca(args, "verify")
  lista_coloca(args, "bootstrap")

  devolve ComandoSvbc {
    imagem: "build/seven.svbc",
    argumentos: args
  }
fecha

campo comando_verify_production() -> ComandoSvbc ::
  solta args := lista<Texto>()
  lista_coloca(args, "verify")
  lista_coloca(args, "production")

  devolve ComandoSvbc {
    imagem: "build/seven.svbc",
    argumentos: args
  }
fecha

campo executa_comando_svbc(comando: ComandoSvbc) -> Resultado<ResultadoComandoSvbc, Falha> toca disco, terminal, rede, tempo, ambiente, frontend ::
  veja arquivo_existe(comando.imagem) == nao ::
    devolve Falha(nova_falha("SV-RUN-IMAGEM", "imagem SVBC ausente: " + comando.imagem))
  fecha

  guarda codigo := roda_svbc_com_args(comando.imagem, comando.argumentos)

  devolve Valor(ResultadoComandoSvbc {
    codigo: codigo,
    imagem: comando.imagem,
    comando: junta_com(" ", comando.argumentos)
  })
fecha

campo executa_verify_foundation_de_seven_svbc() -> Resultado<ResultadoComandoSvbc, Falha> toca disco, terminal, rede, tempo, ambiente, frontend ::
  devolve executa_comando_svbc(comando_verify_foundation())
fecha

campo executa_verify_bootstrap_de_seven_svbc() -> Resultado<ResultadoComandoSvbc, Falha> toca disco, terminal, rede, tempo, ambiente, frontend ::
  devolve executa_comando_svbc(comando_verify_bootstrap())
fecha

campo executa_verify_production_de_seven_svbc() -> Resultado<ResultadoComandoSvbc, Falha> toca disco, terminal, rede, tempo, ambiente, frontend ::
  devolve executa_comando_svbc(comando_verify_production())
fecha
