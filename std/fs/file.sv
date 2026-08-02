modulo std.fs.file

usa std.base.resultado

campo arquivo_texto(caminho: Texto) -> Resultado<Texto, Falha> toca disco ::
  devolve sys_arquivo_ler_texto(caminho)
fecha

campo arquivo_bytes(caminho: Texto) -> Resultado<Bytes, Falha> toca disco ::
  devolve sys_arquivo_ler_bytes(caminho)
fecha

campo arquivo_salva_texto(caminho: Texto, conteudo: Texto) -> Resultado<Nada, Falha> toca disco ::
  devolve sys_arquivo_grava_texto(caminho, conteudo)
fecha

campo arquivo_existe(caminho: Texto) -> Bit toca disco ::
  devolve sys_arquivo_existe(caminho)
fecha
