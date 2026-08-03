modulo seven.compiler.toolchain.adapters

usa seven.compiler.toolchain.command
usa seven.compiler.toolchain.installer
usa seven.compiler.toolchain.formatter
usa seven.compiler.toolchain.test_runner
usa seven.compiler.toolchain.lsp_server
usa seven.compiler.toolchain.release
usa seven.compiler.package_manager
usa std.base.resultado

campo adapta_instalacao(resultado: Resultado<InstalacaoSeven, Falha>) -> SaidaToolchain ::
  veja resultado e Falha ::
    devolve ToolchainErro(1, resultado.valor.mensagem)
  outro ::
    devolve ToolchainOk(0)
  fecha
fecha

campo adapta_fmt(resultado: Resultado<ResultadoFmt, Falha>) -> SaidaToolchain ::
  veja resultado e Falha ::
    devolve ToolchainErro(1, resultado.valor.mensagem)
  outro ::
    devolve ToolchainOk(0)
  fecha
fecha

campo adapta_testes(resultado: Resultado<ResultadoTeste, Falha>) -> SaidaToolchain ::
  veja resultado e Falha ::
    devolve ToolchainErro(1, resultado.valor.mensagem)
  outro ::
    veja resultado.valor.falharam > 0 ::
      devolve ToolchainErro(1, resultado.valor.log)
    fecha

    devolve ToolchainOk(0)
  fecha
fecha

campo adapta_lsp(resultado: Resultado<RespostaLsp, Falha>) -> SaidaToolchain ::
  veja resultado e Falha ::
    devolve ToolchainErro(1, resultado.valor.mensagem)
  outro ::
    devolve ToolchainOk(resultado.valor.codigo)
  fecha
fecha

campo adapta_release(resultado: Resultado<PlanoRelease, Falha>) -> SaidaToolchain ::
  veja resultado e Falha ::
    devolve ToolchainErro(1, resultado.valor.mensagem)
  outro ::
    devolve ToolchainOk(0)
  fecha
fecha

campo adapta_pacote(resultado: ResultadoPacote) -> SaidaToolchain ::
  veja resultado e PacoteFalhou ::
    devolve ToolchainErro(1, "pacote falhou")
  outro ::
    devolve ToolchainOk(0)
  fecha
fecha
