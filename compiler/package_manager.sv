modulo seven.compiler.package_manager

usa seven.compiler.package
usa seven.compiler.diagnostic

molde RequisicaoPacote ::
  manifesto: Texto
  nome: Texto
  versao: Texto
  fonte: Texto
fecha

selo ResultadoPacote ::
  PacoteAtualizado(Pacote)
  PacoteRemovido(Pacote)
  PacoteInstalado(Lista<Texto>)
  PacoteLockValido
  PacoteFalhou(Lista<Diagnostico>)
fecha

campo pacote_add(req: RequisicaoPacote) -> ResultadoPacote toca disco ::
  guarda pacote := pacote_carrega(req.manifesto)
  guarda dep := dependencia_pacote(req.nome, req.versao, req.fonte)
  guarda atualizado := pacote_adiciona_dependencia(pacote, dep)

  arquivo_grava(req.manifesto, pacote_manifesto(atualizado))
  arquivo_grava("seven.lock", pacote_lock(atualizado))

  devolve PacoteAtualizado(atualizado)
fecha

campo pacote_remove(manifesto: Texto, nome: Texto) -> ResultadoPacote toca disco ::
  guarda pacote := pacote_carrega(manifesto)
  solta deps := lista<DependenciaPacote>()
  solta removido := nao

  para cada dep em pacote.dependencias ::
    veja dep.nome == nome ::
      vira removido := sim
    outro ::
      lista_coloca(deps, dep)
    fecha
  fecha

  veja removido == nao ::
    devolve PacoteFalhou(lista_de(erro("SV-PKG-AUSENTE", "dependencia nao encontrada", manifesto, 1, 1)))
  fecha

  vira pacote.dependencias := deps
  arquivo_grava(manifesto, pacote_manifesto(pacote))
  arquivo_grava("seven.lock", pacote_lock(pacote))

  devolve PacoteRemovido(pacote)
fecha

campo pacote_verify(manifesto: Texto, lock: Texto) -> ResultadoPacote toca disco ::
  guarda pacote := pacote_carrega(manifesto)
  guarda esperado := pacote_lock(pacote)
  guarda atual := arquivo_ler(lock)

  veja esperado != atual ::
    devolve PacoteFalhou(lista_de(erro("SV-PKG-LOCK", "seven.lock divergente", lock, 1, 1)))
  fecha

  devolve PacoteLockValido
fecha

campo pacote_install(manifesto: Texto, cache: Texto) -> ResultadoPacote toca disco ::
  guarda pacote := pacote_carrega(manifesto)
  solta instalados := lista<Texto>()

  para cada dep em pacote.dependencias ::
    guarda caminho := cache + "/" + dep.nome + "/" + dep.versao
    diretorio_cria(caminho)
    arquivo_grava(caminho + "/package.txt", "nome " + dep.nome + "\nversao " + dep.versao + "\nfonte " + dep.fonte + "\n")
    lista_coloca(instalados, caminho)
  fecha

  devolve PacoteInstalado(instalados)
fecha

campo pacote_manifesto(pacote: Pacote) -> Texto ::
  solta texto := "pacote " + pacote.nome + "\n"
  vira texto := texto + "versao " + pacote.versao + "\n"
  vira texto := texto + "criador " + pacote.criador + "\n"
  vira texto := texto + "entrada " + pacote.entrada + "\n"
  vira texto := texto + "alvo " + pacote.alvo + "\n"

  para cada raiz em pacote.fontes ::
    vira texto := texto + "fonte " + raiz + "\n"
  fecha

  para cada exemplo em pacote.exemplos ::
    vira texto := texto + "exemplo " + exemplo + "\n"
  fecha

  para cada dep em pacote.dependencias ::
    vira texto := texto + "dep " + dep.nome + " " + dep.versao + " " + dep.fonte + "\n"
  fecha

  devolve texto
fecha
