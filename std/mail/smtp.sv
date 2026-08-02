modulo std.mail.smtp

usa std.base.resultado
usa std.mail.mime

molde SmtpConfig ::
  host: Texto
  porta: U32
  usuario: Texto
  senha: Texto
  tls: Bit
fecha

campo smtp_config(host: Texto, porta: U32, usuario: Texto, senha: Texto) -> SmtpConfig ::
  devolve SmtpConfig {
    host: host,
    porta: porta,
    usuario: usuario,
    senha: senha,
    tls: sim
  }
fecha

campo smtp_envia(config: SmtpConfig, msg: MensagemEmail) -> Resultado<Nada, Falha> toca rede ::
  devolve sys_smtp_envia(config, mime_codifica(msg))
fecha
