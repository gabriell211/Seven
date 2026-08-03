modulo seven.runtime.platform.svbc.target

usa seven.runtime.platform.abi
usa seven.runtime.platform.intrinsic

molde AlvoSvbc ::
  nome: Texto
  intrinsecos: Lista<Intrinseco>
  capacidades: Lista<Capacidade>
fecha

campo alvo_svbc_puro() -> AlvoSvbc ::
  devolve AlvoSvbc {
    nome: "svbc",
    intrinsecos: intrinsecos_padrao(),
    capacidades: lista_de(CapPura)
  }
fecha

campo alvo_svbc_servidor() -> AlvoSvbc ::
  solta caps := lista_de(CapPura)
  lista_coloca(caps, CapTerminal)
  lista_coloca(caps, CapDisco)
  lista_coloca(caps, CapRede)
  lista_coloca(caps, CapTempo)
  lista_coloca(caps, CapAmbiente)

  devolve AlvoSvbc {
    nome: "svbc-server",
    intrinsecos: intrinsecos_padrao(),
    capacidades: caps
  }
fecha
