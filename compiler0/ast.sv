modulo seven0.ast

usa seven0.primitives

molde Programa ::
  modulo: Texto
  usos: ListaTexto
  itens: ListaNo
fecha

molde No ::
  especie: Texto
  nome: Texto
  tipo: Texto
  valor: Texto
  filhos: ListaNo
  linha: U32
  coluna: U32
fecha

campo no(especie: Texto, nome: Texto, tipo: Texto, valor: Texto, linha: U32, coluna: U32) -> No ::
  devolve No {
    especie: especie,
    nome: nome,
    tipo: tipo,
    valor: valor,
    filhos: lista_no(),
    linha: linha,
    coluna: coluna
  }
fecha
