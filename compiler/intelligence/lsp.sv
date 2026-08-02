modulo seven.compiler.intelligence.lsp

usa seven.compiler.intelligence.index
usa seven.compiler.intelligence.suggest
usa seven.compiler.intelligence.autofix
usa seven.compiler.intelligence.explain
usa seven.compiler.source

molde PosicaoLsp ::
  linha: U32
  coluna: U32
fecha

molde Completion ::
  rotulo: Texto
  detalhe: Texto
  inserir: Texto
fecha

molde AcaoCodigo ::
  titulo: Texto
  edicoes: Lista<EdicaoTexto>
fecha

campo lsp_completa(indice: IndiceSemantico, prefixo: Texto, pos: PosicaoLsp) -> Lista<Completion> ::
  solta itens := lista<Completion>()

  para cada no em indice.nos ::
    veja texto_comeca(no.nome, prefixo) ::
      lista_coloca(itens, Completion {
        rotulo: no.nome,
        detalhe: no.especie + " " + no.tipo,
        inserir: no.nome
      })
    fecha
  fecha

  devolve itens
fecha

campo lsp_acoes(sugestoes: Lista<Sugestao>, fonte: Fonte) -> Lista<AcaoCodigo> ::
  solta acoes := lista<AcaoCodigo>()

  para cada sugestao em sugestoes ::
    guarda fix := autofix_calcula(sugestao, fonte)

    veja fix e Algo ::
      lista_coloca(acoes, AcaoCodigo {
        titulo: fix.valor.titulo,
        edicoes: fix.valor.edicoes
      })
    fecha
  fecha

  devolve acoes
fecha
