modulo conformance.runtime.valid.host_contract

usa seven.compiler.toolchain.native_host

campo inicio() -> Num toca disco ::
  guarda plano := host_executavel_padrao()

  veja plano.bytecode == "" ::
    devolve 1
  fecha

  veja plano.launcher == "" ::
    devolve 1
  fecha

  veja host_executavel_contrato_valido() ::
    devolve 0
  fecha

  devolve 1
fecha
