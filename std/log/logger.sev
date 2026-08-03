modulo std.log.logger

usa std.io.console
usa std.time.clock

selo NivelLog ::
  Debug
  Info
  Aviso
  Erro
fecha

molde Logger ::
  nome: Texto
  nivel: NivelLog
fecha

campo logger(nome: Texto) -> Logger ::
  devolve Logger {
    nome: nome,
    nivel: Info
  }
fecha

campo log_info(log: Logger, mensagem: Texto) -> Nada toca terminal, tempo ::
  diga tempo_iso() + " INFO " + log.nome + " " + mensagem
fecha

campo log_erro(log: Logger, mensagem: Texto) -> Nada toca terminal, tempo ::
  diga tempo_iso() + " ERROR " + log.nome + " " + mensagem
fecha
