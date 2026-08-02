modulo seven.compiler.package

molde Pacote ::
  nome: Texto
  versao: Texto
  criador: Texto
  entrada: Texto
  alvo: Texto
  fontes: Lista<Texto>
  exemplos: Lista<Texto>
fecha

campo pacote_carrega(caminho: Texto) -> Pacote toca disco ::
  guarda texto_manifesto := arquivo_ler(caminho)
  devolve pacote_parse(texto_manifesto)
fecha

campo pacote_parse(texto_manifesto: Texto) -> Pacote ::
  solta pacote := Pacote {
    nome: "",
    versao: "0.0.0",
    criador: "",
    entrada: "",
    alvo: "svbc",
    fontes: lista<Texto>(),
    exemplos: lista<Texto>()
  }

  para cada linha em linhas(texto_manifesto) ::
    aplica_linha_manifesto(pacote, linha)
  fecha

  devolve pacote
fecha
