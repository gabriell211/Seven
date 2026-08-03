modulo seven.compiler.toolchain.native_host

usa std.fs.file

molde PlanoHostExecutavel ::
  nome: Texto
  entrada: Texto
  bytecode: Texto
  launcher: Texto
  imagem: Texto
  manifesto: Texto
  formato: Texto
  alvo_padrao: Texto
  runtime: Lista<Texto>
  self_hosted: Bit
fecha

campo host_executavel_padrao() -> PlanoHostExecutavel ::
  solta runtime := lista<Texto>()

  lista_coloca(runtime, "runtime/host/seven.sv")
  lista_coloca(runtime, "runtime/launcher/seven.sv")
  lista_coloca(runtime, "runtime/svbc/runner.sv")
  lista_coloca(runtime, "runtime/svbc/decoder.sv")
  lista_coloca(runtime, "runtime/svbc/verifier.sv")
  lista_coloca(runtime, "runtime/svbc/vm.sv")
  lista_coloca(runtime, "runtime/svbc/syscall.sv")
  lista_coloca(runtime, "runtime/platform/abi.sv")
  lista_coloca(runtime, "runtime/platform/native/target.sv")
  lista_coloca(runtime, "runtime/platform/native/linker.sv")

  devolve PlanoHostExecutavel {
    nome: "seven-host",
    entrada: "runtime/host/seven.sv",
    bytecode: "build/seven.host.svbc",
    launcher: "build/seven.launcher.svbc",
    imagem: "build/seven.svbc",
    manifesto: "build/seven.host",
    formato: "SVBC-v1",
    alvo_padrao: "win-x64-exe",
    runtime: runtime,
    self_hosted: nao
  }
fecha

campo host_executavel_release_caminho(destino: Texto) -> Texto ::
  devolve destino + "/seven.host.svbc"
fecha

campo host_manifesto_release_caminho(destino: Texto) -> Texto ::
  devolve destino + "/seven.host"
fecha

campo host_executavel_manifesto(plano: PlanoHostExecutavel) -> Texto ::
  solta texto_manifesto := "seven-host 1\n"
  vira texto_manifesto := texto_manifesto + "nome " + plano.nome + "\n"
  vira texto_manifesto := texto_manifesto + "entrada " + plano.entrada + "\n"
  vira texto_manifesto := texto_manifesto + "bytecode " + plano.bytecode + "\n"
  vira texto_manifesto := texto_manifesto + "launcher " + plano.launcher + "\n"
  vira texto_manifesto := texto_manifesto + "imagem " + plano.imagem + "\n"
  vira texto_manifesto := texto_manifesto + "formato " + plano.formato + "\n"
  vira texto_manifesto := texto_manifesto + "alvo_padrao " + plano.alvo_padrao + "\n"

  veja plano.self_hosted ::
    vira texto_manifesto := texto_manifesto + "self_hosted sim\n"
  outro ::
    vira texto_manifesto := texto_manifesto + "self_hosted transicao\n"
  fecha

  para cada fonte em plano.runtime ::
    vira texto_manifesto := texto_manifesto + "runtime " + fonte + "\n"
  fecha

  devolve texto_manifesto
fecha

campo host_executavel_contrato_valido() -> Bit toca disco ::
  guarda plano := host_executavel_padrao()

  veja arquivo_existe(plano.entrada) == nao ::
    devolve nao
  fecha

  veja arquivo_existe(plano.bytecode) == nao ::
    devolve nao
  fecha

  veja arquivo_existe(plano.launcher) == nao ::
    devolve nao
  fecha

  veja arquivo_existe(plano.imagem) == nao ::
    devolve nao
  fecha

  para cada fonte em plano.runtime ::
    veja arquivo_existe(fonte) == nao ::
      devolve nao
    fecha
  fecha

  devolve sim
fecha
