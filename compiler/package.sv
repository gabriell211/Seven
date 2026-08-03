modulo seven.compiler.package

molde Pacote ::
  nome: Texto
  versao: Texto
  criador: Texto
  entrada: Texto
  alvo: Texto
  fontes: Lista<Texto>
  exemplos: Lista<Texto>
  dependencias: Lista<DependenciaPacote>
fecha

molde DependenciaPacote ::
  nome: Texto
  versao: Texto
  fonte: Texto
  hash: Texto
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
    exemplos: lista<Texto>(),
    dependencias: lista<DependenciaPacote>()
  }

  para cada linha em linhas(texto_manifesto) ::
    aplica_linha_manifesto(pacote, linha)
  fecha

  devolve pacote
fecha

campo dependencia_pacote(nome: Texto, versao: Texto, fonte: Texto) -> DependenciaPacote ::
  devolve DependenciaPacote {
    nome: nome,
    versao: versao,
    fonte: fonte,
    hash: pacote_hash_dependencia(nome, versao, fonte)
  }
fecha

campo pacote_adiciona_dependencia(pacote: Pacote, dep: DependenciaPacote) -> Pacote ::
  para cada atual em pacote.dependencias ::
    veja atual.nome == dep.nome ::
      vira atual.versao := dep.versao
      vira atual.fonte := dep.fonte
      vira atual.hash := dep.hash
      devolve pacote
    fecha
  fecha

  lista_coloca(pacote.dependencias, dep)
  devolve pacote
fecha

campo pacote_hash_dependencia(nome: Texto, versao: Texto, fonte: Texto) -> Texto ::
  devolve sha256_texto(nome + "|" + versao + "|" + fonte)
fecha

campo pacote_lock(pacote: Pacote) -> Texto ::
  solta saida := "# seven.lock\n"
  vira saida := saida + "version 1\n"
  vira saida := saida + "package " + pacote.nome + " " + pacote.versao + "\n"

  para cada dep em pacote.dependencias ::
    vira saida := saida + "dep " + dep.nome + " " + dep.versao + " " + dep.fonte + " " + dep.hash + "\n"
  fecha

  devolve saida
fecha
