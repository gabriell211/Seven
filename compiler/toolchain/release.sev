modulo seven.compiler.toolchain.release

usa seven.compiler.toolchain.command
usa seven.compiler.toolchain.launcher
usa seven.compiler.toolchain.native_host
usa std.base.resultado
usa std.fs.file

molde ArtefatoRelease ::
  caminho: Texto
  hash: Texto
  tipo: Texto
fecha

molde PlanoRelease ::
  versao: Texto
  artefatos: Lista<ArtefatoRelease>
  sbom: Texto
  assinado: Bit
fecha

campo prepara_release(contexto: ContextoToolchain) -> Resultado<PlanoRelease, Falha> toca disco ::
  solta artefatos := lista<ArtefatoRelease>()

  lista_coloca(artefatos, ArtefatoRelease {
    caminho: contexto.destino + "/seven.svbc",
    hash: hash_release_ou_planejado(contexto.destino + "/seven.svbc"),
    tipo: "svbc"
  })

  lista_coloca(artefatos, ArtefatoRelease {
    caminho: launcher_release_caminho(contexto.destino),
    hash: hash_release_ou_planejado(launcher_release_caminho(contexto.destino)),
    tipo: "launcher-manifest"
  })

  lista_coloca(artefatos, ArtefatoRelease {
    caminho: launcher_bytecode_release_caminho(contexto.destino),
    hash: hash_release_ou_planejado(launcher_bytecode_release_caminho(contexto.destino)),
    tipo: "launcher-svbc"
  })

  lista_coloca(artefatos, ArtefatoRelease {
    caminho: host_manifesto_release_caminho(contexto.destino),
    hash: hash_release_ou_planejado(host_manifesto_release_caminho(contexto.destino)),
    tipo: "host-manifest"
  })

  lista_coloca(artefatos, ArtefatoRelease {
    caminho: host_executavel_release_caminho(contexto.destino),
    hash: hash_release_ou_planejado(host_executavel_release_caminho(contexto.destino)),
    tipo: "host-svbc"
  })

  devolve Valor(PlanoRelease {
    versao: "0.1.0",
    artefatos: artefatos,
    sbom: sbom_gera(contexto),
    assinado: nao
  })
fecha

campo sbom_gera(contexto: ContextoToolchain) -> Texto toca disco ::
  devolve "seven-sbom 1\nmanifesto " + contexto.manifesto + "\nalvo " + contexto.alvo + "\nlauncher " + launcher_release_caminho(contexto.destino) + "\nlauncher_bytecode " + launcher_bytecode_release_caminho(contexto.destino) + "\nhost " + host_manifesto_release_caminho(contexto.destino) + "\nhost_bytecode " + host_executavel_release_caminho(contexto.destino) + "\n" + launcher_manifesto(launcher_padrao()) + host_executavel_manifesto(host_executavel_padrao())
fecha

campo hash_release_ou_planejado(caminho: Texto) -> Texto toca disco ::
  veja arquivo_existe(caminho) ::
    devolve sha256_arquivo(caminho)
  fecha

  devolve "planejado"
fecha
