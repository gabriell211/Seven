modulo seven.compiler.emitter

usa seven.compiler.ir
usa seven.compiler.bytecode

selo FormatoSaida ::
  Svbc
  Objeto
  Binario
fecha

campo emite(unidade: UnidadeIr, formato: FormatoSaida) -> Bytes ::
  veja formato e Svbc ::
    devolve emite_svbc(unidade)
  outro ::
    falha "SV-EMIT-FORMATO" "formato ainda nao suportado"
  fecha
fecha
