modulo seven.compiler.intelligence.assist

usa std.ai.agent
usa std.ai.model
usa std.base.resultado
usa seven.compiler.diagnostic
usa seven.compiler.intelligence.explain

molde PedidoAssistente ::
  pergunta: Texto
  contexto: Texto
  diagnosticos: Lista<Diagnostico>
fecha

campo assistente_local(pergunta: Texto, explicacoes: Lista<Explicacao>) -> Texto ::
  solta resposta := "Analise Seven:\n"

  para cada item em explicacoes ::
    vira resposta := resposta + "- " + item.resumo + " Correcao: " + item.correcao + "\n"
  fecha

  devolve resposta
fecha

campo assistente_ai(modelo: ModeloAi, pedido: PedidoAssistente) -> Resultado<Texto, Falha> toca rede ::
  guarda agente := agente(modelo, "Voce e o assistente oficial da linguagem Seven criada por Gabriel Barcelos.")
  devolve agente_roda(agente, pedido.contexto + "\n" + pedido.pergunta)
fecha
