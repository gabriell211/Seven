modulo seven.runtime.platform.capability

usa seven.runtime.platform.abi
usa seven.runtime.svbc.image

molde ResultadoCapacidade ::
  ok: Bit
  faltantes: Lista<Texto>
fecha

campo confere_capacidades(imagem: ImagemSvbc, capacidades: Lista<Capacidade>) -> ResultadoCapacidade ::
  solta faltantes := lista<Texto>()

  para cada campo em imagem.campos ::
    para cada efeito em campo.efeitos ::
      veja capacidade_tem(capacidades, capacidade_de_efeito(efeito)) == nao ::
        lista_coloca(faltantes, efeito)
      fecha
    fecha
  fecha

  devolve ResultadoCapacidade {
    ok: lista_tamanho(faltantes) == 0,
    faltantes: faltantes
  }
fecha

campo capacidade_tem(capacidades: Lista<Capacidade>, capacidade: Capacidade) -> Bit ::
  para cada cap em capacidades ::
    veja cap == capacidade ::
      devolve sim
    fecha
  fecha

  devolve nao
fecha

campo capacidade_de_efeito(efeito: Texto) -> Capacidade ::
  veja efeito == "terminal" ::
    devolve CapTerminal
  fecha
  veja efeito == "disco" ::
    devolve CapDisco
  fecha
  veja efeito == "rede" ::
    devolve CapRede
  fecha
  veja efeito == "tempo" ::
    devolve CapTempo
  fecha
  veja efeito == "ambiente" ::
    devolve CapAmbiente
  fecha
  veja efeito == "frontend" ::
    devolve CapFrontend
  fecha
  veja efeito == "crypto" ::
    devolve CapCrypto
  fecha

  devolve CapPura
fecha
