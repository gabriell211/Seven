modulo seven.runtime.platform.svbc.kernel

usa std.base.talvez
usa std.mem.bytes

molde KernelSvbc ::
  terminal: Lista<Texto>
  arquivos: Mapa<Texto, Bytes>
  ambiente: Mapa<Texto, Texto>
  argumentos: Lista<Texto>
  relogio_ms: U64
fecha

campo kernel_svbc() -> KernelSvbc ::
  devolve KernelSvbc {
    terminal: lista<Texto>(),
    arquivos: mapa<Texto, Bytes>(),
    ambiente: mapa<Texto, Texto>(),
    argumentos: lista<Texto>(),
    relogio_ms: 0
  }
fecha

campo kernel_coloca_arquivo(kernel: KernelSvbc, caminho: Texto, conteudo: Bytes) -> KernelSvbc ::
  mapa_coloca(kernel.arquivos, caminho, conteudo)
  devolve kernel
fecha

campo kernel_coloca_env(kernel: KernelSvbc, nome: Texto, valor: Texto) -> KernelSvbc ::
  mapa_coloca(kernel.ambiente, nome, valor)
  devolve kernel
fecha
