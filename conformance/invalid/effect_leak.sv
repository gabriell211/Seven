modulo conformance.invalid.effect_leak

campo escreve() -> Nada toca terminal ::
  diga "efeito"
fecha

// espera: SV-EFEITO-VAZOU
campo puro() -> Nada ::
  escreve()
fecha
