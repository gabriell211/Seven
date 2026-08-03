modulo seven.compiler.toolchain.installer

usa seven.compiler.toolchain.launcher
usa seven.compiler.toolchain.native_host
usa std.base.resultado
usa std.fs.file

molde PlanoInstalacao ::
  prefixo: Texto
  binario: Texto
  host: Texto
  host_bytecode: Texto
  launcher: Texto
  launcher_bytecode: Texto
  stdlib: Texto
  cache: Texto
  registrar_path: Bit
fecha

molde InstalacaoSeven ::
  prefixo: Texto
  binario: Texto
  host: Texto
  host_bytecode: Texto
  launcher: Texto
  launcher_bytecode: Texto
  stdlib: Texto
  cache: Texto
fecha

campo plano_instalacao_padrao(prefixo: Texto) -> PlanoInstalacao ::
  guarda destino := prefixo_ou_padrao(prefixo)

  devolve PlanoInstalacao {
    prefixo: destino,
    binario: destino + "/bin/seven",
    host: destino + "/bin/seven.host",
    host_bytecode: destino + "/bin/seven.host.svbc",
    launcher: destino + "/bin/seven.launcher",
    launcher_bytecode: destino + "/bin/seven.launcher.svbc",
    stdlib: destino + "/std",
    cache: destino + "/cache",
    registrar_path: sim
  }
fecha

campo prefixo_ou_padrao(prefixo: Texto) -> Texto ::
  veja prefixo == "" ::
    devolve "~/.seven"
  fecha

  devolve prefixo
fecha

campo instala_seven(plano: PlanoInstalacao) -> Resultado<InstalacaoSeven, Falha> toca disco, ambiente ::
  diretorio_cria(plano.prefixo)
  diretorio_cria(plano.prefixo + "/bin")
  diretorio_cria(plano.stdlib)
  diretorio_cria(plano.cache)

  arquivo_salva_texto(plano.prefixo + "/install.txt", manifesto_instalacao(plano))
  arquivo_salva_texto(plano.prefixo + "/env.seven", ambiente_instalacao(plano))
  arquivo_salva_texto(plano.host, host_executavel_manifesto(host_executavel_padrao()))
  arquivo_salva_texto(plano.launcher, launcher_manifesto(launcher_padrao()))

  devolve Valor(InstalacaoSeven {
    prefixo: plano.prefixo,
    binario: plano.binario,
    host: plano.host,
    host_bytecode: plano.host_bytecode,
    launcher: plano.launcher,
    launcher_bytecode: plano.launcher_bytecode,
    stdlib: plano.stdlib,
    cache: plano.cache
  })
fecha

campo remove_instalacao(prefixo: Texto) -> Resultado<InstalacaoSeven, Falha> toca disco ::
  guarda plano := plano_instalacao_padrao(prefixo)
  arquivo_salva_texto(plano.prefixo + "/uninstall.request", "remove " + plano.prefixo + "\n")

  devolve Valor(InstalacaoSeven {
    prefixo: plano.prefixo,
    binario: plano.binario,
    host: plano.host,
    host_bytecode: plano.host_bytecode,
    launcher: plano.launcher,
    launcher_bytecode: plano.launcher_bytecode,
    stdlib: plano.stdlib,
    cache: plano.cache
  })
fecha

campo manifesto_instalacao(plano: PlanoInstalacao) -> Texto ::
  devolve "seven-install 1\nprefixo " + plano.prefixo + "\nbinario " + plano.binario + "\nhost " + plano.host + "\nhost_bytecode " + plano.host_bytecode + "\nlauncher " + plano.launcher + "\nlauncher_bytecode " + plano.launcher_bytecode + "\nstdlib " + plano.stdlib + "\ncache " + plano.cache + "\n"
fecha

campo ambiente_instalacao(plano: PlanoInstalacao) -> Texto ::
  veja plano.registrar_path ::
    devolve "SEVEN_HOME=" + plano.prefixo + "\nPATH+=" + plano.prefixo + "/bin\n"
  fecha

  devolve "SEVEN_HOME=" + plano.prefixo + "\n"
fecha
