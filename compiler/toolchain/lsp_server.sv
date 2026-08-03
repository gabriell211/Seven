modulo seven.compiler.toolchain.lsp_server

usa seven.compiler.toolchain.command
usa seven.compiler.intelligence.lsp
usa seven.compiler.intelligence.index
usa seven.compiler.source
usa seven.compiler.diagnostic
usa std.base.resultado

molde SessaoLsp ::
  contexto: ContextoToolchain
  documentos: Mapa<Texto, Fonte>
  ativo: Bit
fecha

molde RespostaLsp ::
  codigo: Num
  mensagem: Texto
fecha

campo inicia_lsp(contexto: ContextoToolchain) -> Resultado<RespostaLsp, Falha> toca terminal, disco ::
  guarda sessao := SessaoLsp {
    contexto: contexto,
    documentos: mapa<Texto, Fonte>(),
    ativo: sim
  }

  devolve Valor(RespostaLsp {
    codigo: 0,
    mensagem: "Seven LSP self-hosted pronto para stdio"
  })
fecha

campo lsp_abre_documento(sessao: SessaoLsp, uri: Texto, texto: Texto) -> SessaoLsp ::
  guarda fonte := Fonte {
    caminho: uri,
    texto: texto,
    linhas: mapa_linhas(texto)
  }

  mapa_coloca(sessao.documentos, uri, fonte)
  devolve sessao
fecha

campo lsp_fecha(sessao: SessaoLsp) -> SessaoLsp ::
  vira sessao.ativo := nao
  devolve sessao
fecha

