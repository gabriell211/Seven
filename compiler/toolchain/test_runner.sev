modulo seven.compiler.toolchain.test_runner

usa seven.compiler.toolchain.command
usa seven.compiler.driver
usa std.base.resultado

molde CasoTeste ::
  nome: Texto
  caminho: Texto
  tipo: Texto
fecha

molde ResultadoTeste ::
  total: U64
  passaram: U64
  falharam: U64
  log: Texto
fecha

campo roda_testes(contexto: ContextoToolchain, filtro: Texto) -> Resultado<ResultadoTeste, Falha> toca disco ::
  guarda casos := descobre_testes(contexto, filtro)
  solta total := 0
  solta passaram := 0
  solta falharam := 0
  solta log := ""

  para cada caso em casos ::
    vira total := total + 1
    guarda pedido := pedido_de_compilacao(lista<Texto>())
    guarda saida := compila(pedido)

    veja saida e Sucesso ::
      vira passaram := passaram + 1
      vira log := log + "ok " + caso.nome + "\n"
    outro ::
      vira falharam := falharam + 1
      vira log := log + "fail " + caso.nome + "\n"
    fecha
  fecha

  devolve Valor(ResultadoTeste {
    total: total,
    passaram: passaram,
    falharam: falharam,
    log: log
  })
fecha

campo roda_benchmarks(contexto: ContextoToolchain, filtro: Texto) -> Resultado<ResultadoTeste, Falha> toca disco ::
  devolve roda_testes(contexto, filtro)
fecha

campo descobre_testes(contexto: ContextoToolchain, filtro: Texto) -> Lista<CasoTeste> toca disco ::
  solta casos := lista<CasoTeste>()

  lista_coloca(casos, CasoTeste {
    nome: "conformance",
    caminho: "conformance",
    tipo: "check"
  })

  devolve casos
fecha

