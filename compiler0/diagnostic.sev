modulo seven0.diagnostic

usa seven0.primitives

molde Diagnostico ::
  codigo: Texto
  mensagem: Texto
  arquivo: Texto
  linha: U32
  coluna: U32
fecha

campo diag(codigo: Texto, mensagem: Texto, arquivo: Texto, linha: U32, coluna: U32) -> Diagnostico ::
  devolve Diagnostico {
    codigo: codigo,
    mensagem: mensagem,
    arquivo: arquivo,
    linha: linha,
    coluna: coluna
  }
fecha

campo diagnosticos_mostrar(diagnosticos: ListaDiagnostico) -> Nada toca terminal ::
  para cada d em diagnosticos ::
    diga d.arquivo + ":" + texto(d.linha) + ":" + texto(d.coluna) + " " + d.codigo + " " + d.mensagem
  fecha
fecha
