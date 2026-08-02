modulo examples.ai_assistant.main

usa std.ai.agent
usa std.ai.model

campo inicio() -> Num toca rede, terminal ::
  guarda modelo := ModeloAi {
    nome: "seven-smart",
    fornecedor: "local",
    contexto: 8192
  }

  guarda dev := agente(modelo, "Explique codigo Seven com foco em seguranca, performance e clareza.")
  guarda resposta := agente_roda(dev, "Explique o sistema de efeitos da Seven em uma frase.")

  veja resposta e Falha ::
    diga "assistente indisponivel"
    devolve 1
  fecha

  diga resposta.valor
  devolve 0
fecha
