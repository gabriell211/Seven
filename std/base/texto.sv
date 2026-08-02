modulo std.base.texto

usa std.base.lista

campo texto_vazio(valor: Texto) -> Bit ::
  devolve tamanho(valor) == 0
fecha

campo junta(a: Texto, b: Texto) -> Texto ::
  devolve a + b
fecha

campo tamanho(valor: Texto) -> U64 ::
  devolve sys_texto_tamanho(valor)
fecha

campo url_encode(valor: Texto) -> Texto ::
  devolve sys_url_encode(valor)
fecha

campo html_escape(valor: Texto) -> Texto ::
  devolve sys_html_escape(valor)
fecha

campo json_escape(valor: Texto) -> Texto ::
  devolve sys_json_escape(valor)
fecha

campo junta_com(separador: Texto, valores: Lista<Texto>) -> Texto ::
  devolve sys_texto_junta(separador, valores)
fecha

campo texto_comeca(valor: Texto, prefixo: Texto) -> Bit ::
  devolve sys_texto_comeca(valor, prefixo)
fecha
