modulo seven.runtime.svbc.decoder

usa std.base.resultado
usa std.mem.bytes
usa seven.runtime.svbc.image
usa seven.runtime.svbc.opcode
usa seven.runtime.svbc.value

molde CursorBytes ::
  dados: Bytes
  pos: U64
fecha

campo svbc_decodifica(dados: Bytes) -> Resultado<ImagemSvbc, Falha> ::
  solta c := CursorBytes {
    dados: dados,
    pos: 0
  }

  guarda magic := le_texto_fixo(c, 4)

  veja magic != MagicSvbc ::
    devolve Falha(nova_falha("SVBC-MAGIC", "imagem SVBC invalida"))
  fecha

  guarda versao := le_u32(c)

  veja versao != VersaoSvbc ::
    devolve Falha(nova_falha("SVBC-VERSAO", "versao SVBC nao suportada"))
  fecha

  devolve Valor(decodifica_secoes(c, versao))
fecha

campo decodifica_secoes(c: CursorBytes, versao: U32) -> ImagemSvbc ::
  solta img := imagem_vazia()
  vira img.versao := versao

  decodifica_nomes(c, img)
  decodifica_constantes(c, img)
  decodifica_campos(c, img)
  decodifica_codigo(c, img)

  devolve img
fecha

campo le_texto_fixo(c: CursorBytes, tamanho: U64) -> Texto ::
  guarda texto_lido := sys_bytes_texto_intervalo(c.dados, c.pos, tamanho)
  vira c.pos := c.pos + tamanho
  devolve texto_lido
fecha

campo le_u32(c: CursorBytes) -> U32 ::
  guarda valor := sys_bytes_u32_be(c.dados, c.pos)
  vira c.pos := c.pos + 4
  devolve valor
fecha

campo decodifica_nomes(c: CursorBytes, img: ImagemSvbc) -> Nada ::
  sys_svbc_decodifica_nomes(c, img)
fecha

campo decodifica_constantes(c: CursorBytes, img: ImagemSvbc) -> Nada ::
  sys_svbc_decodifica_constantes(c, img)
fecha

campo decodifica_campos(c: CursorBytes, img: ImagemSvbc) -> Nada ::
  sys_svbc_decodifica_campos(c, img)
fecha

campo decodifica_codigo(c: CursorBytes, img: ImagemSvbc) -> Nada ::
  sys_svbc_decodifica_codigo(c, img)
fecha
