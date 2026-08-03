modulo seven0.check

usa seven0.primitives
usa seven0.ast
usa seven0.diagnostic

molde Simbolo ::
  nome: Texto
  especie: Texto
  tipo: Texto
  mutavel: Bit
fecha

molde Unidade ::
  programa: Programa
  simbolos: ListaSimbolo
  diagnosticos: ListaDiagnostico
fecha

campo conferir(programa: Programa) -> Unidade ::
  solta unidade := Unidade {
    programa: programa,
    simbolos: lista_simbolo(),
    diagnosticos: lista_diagnostico()
  }

  registra_publicos(unidade)
  confere_nomes(unidade)
  confere_tipos(unidade)
  confere_retorno(unidade)

  devolve unidade
fecha

campo simbolo(nome: Texto, especie: Texto, tipo: Texto, mutavel: Bit) -> Simbolo ::
  devolve Simbolo {
    nome: nome,
    especie: especie,
    tipo: tipo,
    mutavel: mutavel
  }
fecha
