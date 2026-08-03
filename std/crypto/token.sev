modulo std.crypto.token

usa std.base.resultado
usa std.crypto.hash
usa std.mem.bytes

molde TokenSeguro ::
  valor: Texto
  expira_em: U64
fecha

campo token_novo(carga: Texto, segredo: Texto, expira_em: U64) -> TokenSeguro toca tempo ::
  guarda assinatura := hash_texto(sha256(texto_bytes(carga + "." + segredo)))

  devolve TokenSeguro {
    valor: carga + "." + assinatura,
    expira_em: expira_em
  }
fecha

campo token_confere(token: TokenSeguro, segredo: Texto) -> Resultado<Texto, Falha> toca tempo ::
  veja tempo_agora() > token.expira_em ::
    devolve Falha(nova_falha("SV-CRYPTO-EXPIRADO", "token expirado"))
  fecha

  devolve token_confere_assinatura(token, segredo)
fecha
