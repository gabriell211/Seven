modulo std.ai.model

usa std.base.resultado

molde ModeloAi ::
  nome: Texto
  fornecedor: Texto
  contexto: U32
fecha

molde MensagemAi ::
  papel: Texto
  conteudo: Texto
fecha

molde RespostaAi ::
  texto: Texto
  tokens_entrada: U32
  tokens_saida: U32
fecha

campo ai_chat(modelo: ModeloAi, mensagens: Lista<MensagemAi>) -> Resultado<RespostaAi, Falha> toca rede ::
  devolve sys_ai_chat(modelo, mensagens)
fecha

campo ai_mensagem(papel: Texto, conteudo: Texto) -> MensagemAi ::
  devolve MensagemAi {
    papel: papel,
    conteudo: conteudo
  }
fecha
