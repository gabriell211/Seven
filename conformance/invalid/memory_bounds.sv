modulo conformance.invalid.memory_bounds

// espera: SV-MEM-LIMITE
campo inicio() -> Num ::
  caixa pacote: Byte[2]
  marca pacote @ 2 := 99
  devolve 0
fecha
