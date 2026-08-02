modulo std.archive.zip

usa std.base.resultado
usa std.mem.bytes

molde ZipEntrada ::
  caminho: Texto
  dados: Bytes
fecha

molde ZipArquivo ::
  entradas: Lista<ZipEntrada>
fecha

campo zip_novo() -> ZipArquivo ::
  devolve ZipArquivo {
    entradas: lista<ZipEntrada>()
  }
fecha

campo zip_adiciona(zip: ZipArquivo, caminho: Texto, dados: Bytes) -> ZipArquivo ::
  lista_coloca(zip.entradas, ZipEntrada {
    caminho: caminho,
    dados: dados
  })

  devolve zip
fecha

campo zip_codifica(zip: ZipArquivo) -> Resultado<Bytes, Falha> ::
  devolve sys_zip_codifica(zip)
fecha

campo zip_parse(dados: Bytes) -> Resultado<ZipArquivo, Falha> ::
  devolve sys_zip_parse(dados)
fecha
