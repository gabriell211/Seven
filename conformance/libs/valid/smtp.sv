modulo conformance.libs.valid.smtp

usa std.mail.mime
usa std.mail.smtp

campo cria() -> MensagemEmail ::
  devolve email("a@seven.dev", lista_de("b@seven.dev"), "ok", "corpo")
fecha
