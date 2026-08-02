modulo examples.mail_smtp.main

usa std.env.runtime
usa std.mail.mime
usa std.mail.smtp

campo inicio() -> Num toca rede, ambiente, terminal ::
  guarda host := env_ou("SMTP_HOST", "smtp.local")
  guarda usuario := env_ou("SMTP_USER", "seven")
  guarda senha := env_ou("SMTP_PASS", "secret")
  guarda destino := env_ou("MAIL_TO", "gabriel@example.com")

  guarda config := smtp_config(host, 587, usuario, senha)
  guarda msg := email("seven@example.com", lista_de(destino), "Seven SMTP", "Mensagem enviada pela Seven.")

  guarda saida := smtp_envia(config, msg)

  veja saida e Falha ::
    diga "falha enviando email"
    devolve 1
  fecha

  diga "email enviado"
  devolve 0
fecha
