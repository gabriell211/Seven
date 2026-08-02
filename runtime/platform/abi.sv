modulo seven.runtime.platform.abi

selo Capacidade ::
  CapPura
  CapTerminal
  CapDisco
  CapRede
  CapTempo
  CapAmbiente
  CapFrontend
  CapCrypto
fecha

selo EstadoIntrinseco ::
  IntrinsecoPuro
  IntrinsecoLigado
  IntrinsecoBloqueado
  IntrinsecoIndisponivel
fecha

molde ContratoIntrinseco ::
  nome: Texto
  capacidade: Capacidade
  estado: EstadoIntrinseco
  entrada: Lista<Texto>
  saida: Texto
  diagnostico: Texto
fecha

campo contrato_intrinseco(nome: Texto, capacidade: Capacidade, saida: Texto) -> ContratoIntrinseco ::
  devolve ContratoIntrinseco {
    nome: nome,
    capacidade: capacidade,
    estado: IntrinsecoLigado,
    entrada: lista<Texto>(),
    saida: saida,
    diagnostico: ""
  }
fecha
