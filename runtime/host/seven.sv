modulo seven.runtime.host

usa seven.runtime.svbc.runner

campo seven_host(argumentos: Lista<Texto>) -> Num toca disco, terminal, rede, tempo, ambiente, frontend ::
  devolve roda_svbc_com_args("build/seven.launcher.svbc", argumentos)
fecha

campo inicio(argumentos: Lista<Texto>) -> Num toca disco, terminal, rede, tempo, ambiente, frontend ::
  devolve seven_host(argumentos)
fecha
