modulo seven.compiler.token

usa seven.compiler.source

selo TokenTipo ::
  Nome
  Numero
  TextoLit
  Palavra
  Sinal
  Fim
fecha

molde Token ::
  tipo: TokenTipo
  marca: Texto
  span: Span
fecha

molde FluxoTokens ::
  fonte: Fonte
  tokens: Lista<Token>
fecha

campo token(tipo: TokenTipo, marca: Texto, span: Span) -> Token ::
  devolve Token {
    tipo: tipo,
    marca: marca,
    span: span
  }
fecha
