modulo std.mail.imap

usa std.base.resultado
usa std.mail.mime

molde ImapConfig ::
  host: Texto
  porta: U32
  usuario: Texto
  senha: Texto
  tls: Bit
fecha

molde CaixaEmail ::
  nome: Texto
  total: U64
fecha

molde ConexaoImap ::
  id: U64
fecha

campo imap_conecta(config: ImapConfig) -> Resultado<ConexaoImap, Falha> toca rede ::
  devolve sys_imap_conecta(config)
fecha

campo imap_caixas(conexao: ConexaoImap) -> Resultado<Lista<CaixaEmail>, Falha> toca rede ::
  devolve sys_imap_caixas(conexao)
fecha

campo imap_busca(conexao: ConexaoImap, caixa: Texto, limite: U32) -> Resultado<Lista<MensagemEmail>, Falha> toca rede ::
  devolve sys_imap_busca(conexao, caixa, limite)
fecha

campo imap_fecha(conexao: ConexaoImap) -> Nada toca rede ::
  sys_imap_fecha(conexao)
fecha
