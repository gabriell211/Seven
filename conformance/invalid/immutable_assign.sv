modulo conformance.invalid.immutable_assign

// espera: SV-TIPO-IMUTAVEL
campo inicio() -> Num ::
  guarda limite: U32 := 7
  vira limite := 8
  devolve limite
fecha
