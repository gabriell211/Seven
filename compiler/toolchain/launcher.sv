modulo seven.compiler.toolchain.launcher

usa std.fs.file

molde PlanoLauncher ::
  nome: Texto
  entrada: Texto
  imagem: Texto
  bytecode: Texto
  manifesto: Texto
  runtime: Lista<Texto>
  formato: Texto
  self_hosted: Bit
fecha

campo launcher_padrao() -> PlanoLauncher ::
  solta runtime := lista<Texto>()

  lista_coloca(runtime, "runtime/svbc/runner.sv")
  lista_coloca(runtime, "runtime/svbc/decoder.sv")
  lista_coloca(runtime, "runtime/svbc/verifier.sv")
  lista_coloca(runtime, "runtime/svbc/vm.sv")
  lista_coloca(runtime, "runtime/svbc/command_runner.sv")
  lista_coloca(runtime, "runtime/platform/svbc/toolchain.sv")
  lista_coloca(runtime, "runtime/platform/intrinsic.sv")

  devolve PlanoLauncher {
    nome: "seven",
    entrada: "runtime/launcher/seven.sv",
    imagem: "build/seven.svbc",
    bytecode: "build/seven.launcher.svbc",
    manifesto: "build/seven.launcher",
    runtime: runtime,
    formato: "SVBC-v1",
    self_hosted: nao
  }
fecha

campo launcher_release_caminho(destino: Texto) -> Texto ::
  devolve destino + "/seven.launcher"
fecha

campo launcher_bytecode_release_caminho(destino: Texto) -> Texto ::
  devolve destino + "/seven.launcher.svbc"
fecha

campo launcher_manifesto(plano: PlanoLauncher) -> Texto ::
  solta texto_manifesto := "seven-launcher 1\n"
  vira texto_manifesto := texto_manifesto + "nome " + plano.nome + "\n"
  vira texto_manifesto := texto_manifesto + "entrada " + plano.entrada + "\n"
  vira texto_manifesto := texto_manifesto + "imagem " + plano.imagem + "\n"
  vira texto_manifesto := texto_manifesto + "bytecode " + plano.bytecode + "\n"
  vira texto_manifesto := texto_manifesto + "formato " + plano.formato + "\n"

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

campo launcher_contrato_valido() -> Bit toca disco ::
  guarda plano := launcher_padrao()

  veja arquivo_existe(plano.entrada) == nao ::
    devolve nao
  fecha

  veja arquivo_existe(plano.imagem) == nao ::
    devolve nao
  fecha

  veja arquivo_existe(plano.bytecode) == nao ::
    devolve nao
  fecha

  para cada fonte em plano.runtime ::
    veja arquivo_existe(fonte) == nao ::
      devolve nao
    fecha
  fecha

  devolve sim
fecha
