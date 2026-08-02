modulo seven.compiler.diagnostic

selo NivelDiagnostico ::
  Info
  Aviso
  Erro
fecha

molde Diagnostico ::
  nivel: NivelDiagnostico
  codigo: Texto
  mensagem: Texto
  arquivo: Texto
  linha: U32
  coluna: U32
  ajuda: Texto
fecha

campo diagnostico(
  nivel: NivelDiagnostico,
  codigo: Texto,
  mensagem: Texto,
  arquivo: Texto,
  linha: U32,
  coluna: U32,
  ajuda: Texto
) -> Diagnostico ::
  devolve Diagnostico {
    nivel: nivel,
    codigo: codigo,
    mensagem: mensagem,
    arquivo: arquivo,
    linha: linha,
    coluna: coluna,
    ajuda: ajuda
  }
fecha

campo erro(codigo: Texto, mensagem: Texto, arquivo: Texto, linha: U32, coluna: U32) -> Diagnostico ::
  devolve diagnostico(Erro, codigo, mensagem, arquivo, linha, coluna, "")
fecha

campo formatar_diagnostico(diag: Diagnostico) -> Texto ::
  devolve diag.arquivo + ":" + texto(diag.linha) + ":" + texto(diag.coluna) + " " + diag.codigo + " " + diag.mensagem
fecha
