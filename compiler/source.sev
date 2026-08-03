modulo seven.compiler.source

usa seven.compiler.diagnostic
usa seven.compiler.package

molde Span ::
  arquivo: Texto
  inicio: U64
  fim: U64
  linha: U32
  coluna: U32
fecha

molde Fonte ::
  caminho: Texto
  texto: Texto
  linhas: Lista<U64>
fecha

molde UnidadeFonte ::
  arquivos: Lista<Fonte>
fecha

campo fonte_carrega(caminho: Texto) -> Resultado<Fonte, Diagnostico> toca disco ::
  guarda conteudo := arquivo_ler(caminho)
  guarda linhas := mapa_linhas(conteudo)

  devolve Valor(Fonte {
    caminho: caminho,
    texto: conteudo,
    linhas: linhas
  })
fecha

campo fonte_carrega_pacote(pacote: Pacote) -> UnidadeFonte toca disco ::
  solta arquivos := lista<Fonte>()

  para cada raiz em pacote.fontes ::
    para cada caminho em arquivos_sv(raiz) ::
      guarda fonte := fonte_carrega(caminho)
      lista_coloca(arquivos, fonte.valor)
    fecha
  fecha

  devolve UnidadeFonte { arquivos: arquivos }
fecha
