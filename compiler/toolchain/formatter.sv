modulo seven.compiler.toolchain.formatter

usa std.base.resultado
usa std.fs.file

molde ResultadoFmt ::
  caminho: Texto
  alterado: Bit
  conteudo: Texto
fecha

campo fmt_caminho(caminho: Texto, escreve: Bit) -> Resultado<ResultadoFmt, Falha> toca disco ::
  guarda texto := arquivo_texto(caminho)

  veja texto e Falha ::
    devolve Falha(texto.valor)
  fecha

  guarda formatado := fmt_texto(texto.valor)
  guarda mudou := formatado != texto.valor

  veja escreve ::
    veja mudou ::
      arquivo_salva_texto(caminho, formatado)
    fecha
  fecha

  devolve Valor(ResultadoFmt {
    caminho: caminho,
    alterado: mudou,
    conteudo: formatado
  })
fecha

campo fmt_texto(fonte: Texto) -> Texto ::
  solta saida := ""
  solta nivel := 0

  para cada linha em linhas(fonte) ::
    guarda limpa := texto_trim(linha)

    veja limpa == "fecha" ::
      vira nivel := max(0, nivel - 1)
    fecha

    vira saida := saida + repete("  ", nivel) + limpa + "\n"

    veja texto_comeca(limpa, "campo ") ::
      vira nivel := nivel + 1
    fecha

    veja texto_comeca(limpa, "molde ") ::
      vira nivel := nivel + 1
    fecha

    veja texto_comeca(limpa, "selo ") ::
      vira nivel := nivel + 1
    fecha

    veja texto_comeca(limpa, "veja ") ::
      vira nivel := nivel + 1
    fecha

    veja texto_comeca(limpa, "para ") ::
      vira nivel := nivel + 1
    fecha
  fecha

  devolve saida
fecha
