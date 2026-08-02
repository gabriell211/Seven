modulo std.observability.trace

molde SpanTrace ::
  id: Texto
  nome: Texto
  inicio_ms: U64
fecha

campo trace_inicio(nome: Texto) -> SpanTrace toca tempo, ambiente ::
  devolve sys_trace_inicio(nome)
fecha

campo trace_fecha(span: SpanTrace) -> Nada toca tempo, ambiente ::
  sys_trace_fecha(span)
fecha
