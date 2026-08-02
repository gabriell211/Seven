modulo conformance.platform.valid.native_target

usa seven.runtime.platform.native.target

campo inicio() -> Num ::
  guarda alvo := alvo_win_x64()

  veja alvo.formato == "exe" ::
    devolve 0
  outro ::
    devolve 1
  fecha
fecha
