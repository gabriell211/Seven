modulo seven0.source

usa seven0.primitives
usa seven0.diagnostic

molde Fonte ::
  caminho: Texto
  texto: Texto
fecha

molde ResultadoFonte ::
  ok: Bit
  valor: Fonte
  diagnosticos: ListaDiagnostico
fecha

campo fonte_ler(caminho: Texto) -> ResultadoFonte toca disco ::
  guarda texto_fonte := arquivo_ler(caminho)

  devolve ResultadoFonte {
    ok: sim,
    valor: Fonte {
      caminho: caminho,
      texto: texto_fonte
    },
    diagnosticos: lista_diagnostico()
  }
fecha
