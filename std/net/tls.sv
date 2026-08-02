modulo std.net.tls

usa std.base.resultado
usa std.net.tcp

molde TlsConfig ::
  servidor_nome: Texto
  verifica_certificado: Bit
  alpn: Lista<Texto>
fecha

molde ConexaoTls ::
  id: U64
fecha

campo tls_config(servidor_nome: Texto) -> TlsConfig ::
  devolve TlsConfig {
    servidor_nome: servidor_nome,
    verifica_certificado: sim,
    alpn: lista<Texto>()
  }
fecha

campo tls_conecta(conexao: ConexaoTcp, config: TlsConfig) -> Resultado<ConexaoTls, Falha> toca rede ::
  devolve sys_tls_conecta(conexao, config)
fecha

campo tls_le(conexao: ConexaoTls) -> Resultado<Bytes, Falha> toca rede ::
  devolve sys_tls_le(conexao)
fecha

campo tls_escreve(conexao: ConexaoTls, dados: Bytes) -> Resultado<Nada, Falha> toca rede ::
  devolve sys_tls_escreve(conexao, dados)
fecha
