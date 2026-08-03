modulo std.mail.mime

usa std.mem.bytes

molde ParteMime ::
  tipo: Texto
  nome: Texto
  conteudo: Bytes
fecha

molde MensagemEmail ::
  de: Texto
  para: Lista<Texto>
  assunto: Texto
  texto: Texto
  html: Texto
  anexos: Lista<ParteMime>
fecha

campo email(de: Texto, para: Lista<Texto>, assunto: Texto, texto: Texto) -> MensagemEmail ::
  devolve MensagemEmail {
    de: de,
    para: para,
    assunto: assunto,
    texto: texto,
    html: "",
    anexos: lista<ParteMime>()
  }
fecha

campo anexo(nome: Texto, tipo: Texto, conteudo: Bytes) -> ParteMime ::
  devolve ParteMime {
    tipo: tipo,
    nome: nome,
    conteudo: conteudo
  }
fecha

campo email_com_html(msg: MensagemEmail, html: Texto) -> MensagemEmail ::
  vira msg.html := html
  devolve msg
fecha

campo email_anexa(msg: MensagemEmail, parte: ParteMime) -> MensagemEmail ::
  lista_coloca(msg.anexos, parte)
  devolve msg
fecha

campo mime_codifica(msg: MensagemEmail) -> Bytes ::
  devolve sys_mime_codifica(msg)
fecha
