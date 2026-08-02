modulo seven.runtime.platform.native.target

usa seven.runtime.platform.abi

selo SistemaNativo ::
  WinX64
  LinuxX64
  Arm64
fecha

molde AlvoNativo ::
  sistema: SistemaNativo
  imports: Lista<ContratoIntrinseco>
  formato: Texto
fecha

campo alvo_win_x64() -> AlvoNativo ::
  devolve alvo_nativo(WinX64, "exe")
fecha

campo alvo_linux_x64() -> AlvoNativo ::
  devolve alvo_nativo(LinuxX64, "elf")
fecha

campo alvo_nativo(sistema: SistemaNativo, formato: Texto) -> AlvoNativo ::
  solta imports := lista<ContratoIntrinseco>()

  lista_coloca(imports, contrato_intrinseco("sys_arquivo_ler_texto", CapDisco, "Resultado<Texto, Falha>"))
  lista_coloca(imports, contrato_intrinseco("sys_arquivo_grava_texto", CapDisco, "Resultado<Nada, Falha>"))
  lista_coloca(imports, contrato_intrinseco("sys_tcp_escuta", CapRede, "Resultado<ListenerTcp, Falha>"))
  lista_coloca(imports, contrato_intrinseco("sys_tcp_aceita", CapRede, "Resultado<ConexaoTcp, Falha>"))
  lista_coloca(imports, contrato_intrinseco("sys_tcp_le", CapRede, "Resultado<Bytes, Falha>"))
  lista_coloca(imports, contrato_intrinseco("sys_tcp_escreve", CapRede, "Resultado<Nada, Falha>"))
  lista_coloca(imports, contrato_intrinseco("sys_tempo_agora", CapTempo, "U64"))
  lista_coloca(imports, contrato_intrinseco("sys_env", CapAmbiente, "Resultado<Texto, Falha>"))

  devolve AlvoNativo {
    sistema: sistema,
    imports: imports,
    formato: formato
  }
fecha
