modulo std.ai.embedding

usa std.base.resultado
usa std.ai.model

molde Vetor ::
  valores: Lista<Real64>
fecha

campo ai_embedding(modelo: ModeloAi, texto: Texto) -> Resultado<Vetor, Falha> toca rede ::
  devolve sys_ai_embedding(modelo, texto)
fecha

campo similaridade_coseno(a: Vetor, b: Vetor) -> Real64 ::
  devolve sys_vetor_coseno(a, b)
fecha
