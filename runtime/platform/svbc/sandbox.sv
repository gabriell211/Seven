modulo seven.runtime.platform.svbc.sandbox

usa std.base.resultado
usa std.base.talvez
usa std.mem.bytes
usa seven.runtime.platform.svbc.kernel

campo svbc_terminal_escreve(texto_saida: Texto) -> Nada toca terminal ::
  svbc_terminal_buffer_coloca(texto_saida)
fecha

campo svbc_arquivo_ler_texto(caminho: Texto) -> Resultado<Texto, Falha> toca disco ::
  guarda arquivo := svbc_arquivo_virtual(caminho)

  veja arquivo e Vazio ::
    devolve Falha(nova_falha("SVBC-FS-AUSENTE", "arquivo virtual ausente: " + caminho))
  fecha

  devolve Valor(bytes_texto(arquivo.valor))
fecha

campo svbc_arquivo_ler_bytes(caminho: Texto) -> Resultado<Bytes, Falha> toca disco ::
  guarda arquivo := svbc_arquivo_virtual(caminho)

  veja arquivo e Vazio ::
    devolve Falha(nova_falha("SVBC-FS-AUSENTE", "arquivo virtual ausente: " + caminho))
  fecha

  devolve Valor(arquivo.valor)
fecha

campo svbc_arquivo_grava_texto(caminho: Texto, conteudo: Texto) -> Resultado<Nada, Falha> toca disco ::
  svbc_arquivo_virtual_grava(caminho, texto_bytes(conteudo))
  devolve Valor(nulo)
fecha

campo svbc_arquivo_existe(caminho: Texto) -> Bit toca disco ::
  guarda arquivo := svbc_arquivo_virtual(caminho)
  devolve arquivo e Algo
fecha

campo svbc_env(nome: Texto) -> Resultado<Texto, Falha> toca ambiente ::
  guarda valor := svbc_ambiente_virtual(nome)

  veja valor e Vazio ::
    devolve Falha(nova_falha("SVBC-ENV-AUSENTE", "variavel virtual ausente: " + nome))
  fecha

  devolve Valor(valor.valor)
fecha

campo svbc_args() -> Lista<Texto> toca ambiente ::
  devolve svbc_argumentos_virtual()
fecha

campo svbc_tempo_agora() -> U64 toca tempo ::
  devolve svbc_relogio_virtual_ms()
fecha

campo svbc_tempo_iso() -> Texto toca tempo ::
  devolve svbc_relogio_virtual_iso()
fecha

campo svbc_dorme(ms: U64) -> Nada toca tempo ::
  svbc_relogio_virtual_avanca(ms)
fecha

campo svbc_terminal_buffer_coloca(texto_saida: Texto) -> Nada ::
  sys_svbc_terminal_buffer_coloca(texto_saida)
fecha

campo svbc_arquivo_virtual(caminho: Texto) -> Talvez<Bytes> ::
  devolve sys_svbc_arquivo_virtual(caminho)
fecha

campo svbc_arquivo_virtual_grava(caminho: Texto, conteudo: Bytes) -> Nada ::
  sys_svbc_arquivo_virtual_grava(caminho, conteudo)
fecha

campo svbc_ambiente_virtual(nome: Texto) -> Talvez<Texto> ::
  devolve sys_svbc_ambiente_virtual(nome)
fecha

campo svbc_argumentos_virtual() -> Lista<Texto> ::
  devolve sys_svbc_argumentos_virtual()
fecha

campo svbc_relogio_virtual_ms() -> U64 ::
  devolve sys_svbc_relogio_virtual_ms()
fecha

campo svbc_relogio_virtual_iso() -> Texto ::
  devolve sys_svbc_relogio_virtual_iso()
fecha

campo svbc_relogio_virtual_avanca(ms: U64) -> Nada ::
  sys_svbc_relogio_virtual_avanca(ms)
fecha
