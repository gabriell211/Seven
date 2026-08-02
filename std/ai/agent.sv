modulo std.ai.agent

usa std.ai.model
usa std.base.resultado

molde FerramentaAi ::
  nome: Texto
  descricao: Texto
  executa: Campo<Texto, Texto>
fecha

molde AgenteAi ::
  modelo: ModeloAi
  instrucoes: Texto
  ferramentas: Lista<FerramentaAi>
fecha

campo agente(modelo: ModeloAi, instrucoes: Texto) -> AgenteAi ::
  devolve AgenteAi {
    modelo: modelo,
    instrucoes: instrucoes,
    ferramentas: lista<FerramentaAi>()
  }
fecha

campo agente_ferramenta(agente: AgenteAi, ferramenta: FerramentaAi) -> AgenteAi ::
  lista_coloca(agente.ferramentas, ferramenta)
  devolve agente
fecha

campo agente_roda(agente: AgenteAi, entrada: Texto) -> Resultado<Texto, Falha> toca rede ::
  devolve sys_agente_roda(agente, entrada)
fecha
