modulo std.web.html

selo NoHtml ::
  TextoNo(valor: Texto)
  ElementoNo(Elemento)
fecha

molde Atributo ::
  nome: Texto
  valor: Texto
fecha

molde Elemento ::
  nome: Texto
  atributos: Lista<Atributo>
  filhos: Lista<NoHtml>
fecha

campo attr(nome: Texto, valor: Texto) -> Atributo ::
  devolve Atributo {
    nome: nome,
    valor: valor
  }
fecha

campo texto_no(valor: Texto) -> NoHtml ::
  devolve TextoNo(valor)
fecha

campo elem(nome: Texto, atributos: Lista<Atributo>, filhos: Lista<NoHtml>) -> NoHtml ::
  devolve ElementoNo(Elemento {
    nome: nome,
    atributos: atributos,
    filhos: filhos
  })
fecha

campo pagina(titulo: Texto, corpo: Lista<NoHtml>) -> Texto ::
  solta filhos := lista<NoHtml>()
  lista_coloca(filhos, elem("head", lista<Atributo>(), lista_de(elem("title", lista<Atributo>(), lista_de(texto_no(titulo))))))
  lista_coloca(filhos, elem("body", lista<Atributo>(), corpo))

  devolve "<!doctype html>" + renderiza(elem("html", lista<Atributo>(), filhos))
fecha

campo renderiza(no: NoHtml) -> Texto ::
  veja no e TextoNo ::
    devolve html_escape(no.valor)
  outro ::
    devolve renderiza_elemento(no.valor)
  fecha
fecha

campo renderiza_elemento(elemento: Elemento) -> Texto ::
  devolve sys_html_renderiza(elemento)
fecha
