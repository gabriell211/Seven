modulo conformance.runtime.invalid.svbc_bad_magic

usa seven.runtime.svbc.decoder

// espera: SVBC-MAGIC
campo inicio() -> Num ::
  guarda dados := texto_bytes("NOPE")
  guarda img := svbc_decodifica(dados)

  veja img e Falha ::
    devolve 0
  fecha

  devolve 1
fecha
