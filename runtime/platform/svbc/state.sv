modulo seven.runtime.platform.svbc.state

usa seven.runtime.platform.abi

molde ArquivoVirtual ::
  caminho: Texto
  conteudo: Bytes
fecha

molde AmbienteVirtual ::
  valores: Mapa<Texto, Texto>
fecha

molde TerminalVirtual ::
  saida: Lista<Texto>
fecha

molde PlataformaSvbc ::
  arquivos: Lista<ArquivoVirtual>
  ambiente: AmbienteVirtual
  terminal: TerminalVirtual
  capacidades: Lista<Capacidade>
fecha

campo svbc_plataforma_padrao() -> PlataformaSvbc ::
  devolve PlataformaSvbc {
    arquivos: lista<ArquivoVirtual>(),
    ambiente: AmbienteVirtual {
      valores: mapa<Texto, Texto>()
    },
    terminal: TerminalVirtual {
      saida: lista<Texto>()
    },
    capacidades: lista_de(CapPura)
  }
fecha
