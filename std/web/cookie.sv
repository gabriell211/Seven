modulo std.web.cookie

usa std.web.http

molde Cookie ::
  nome: Texto
  valor: Texto
  caminho: Texto
  seguro: Bit
  http_only: Bit
  max_idade: U64
fecha

campo cookie(nome: Texto, valor: Texto) -> Cookie ::
  devolve Cookie {
    nome: nome,
    valor: valor,
    caminho: "/",
    seguro: sim,
    http_only: sim,
    max_idade: 0
  }
fecha

campo cookie_header(c: Cookie) -> Cabecalho ::
  solta valor := c.nome + "=" + url_encode(c.valor) + "; Path=" + c.caminho

  veja c.seguro ::
    vira valor := valor + "; Secure"
  fecha

  veja c.http_only ::
    vira valor := valor + "; HttpOnly"
  fecha

  veja c.max_idade > 0 ::
    vira valor := valor + "; Max-Age=" + texto(c.max_idade)
  fecha

  devolve cabecalho("set-cookie", valor)
fecha
