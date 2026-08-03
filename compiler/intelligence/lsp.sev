modulo seven.compiler.intelligence.lsp

usa seven.compiler.intelligence.index
usa seven.compiler.intelligence.suggest
usa seven.compiler.intelligence.autofix
usa seven.compiler.intelligence.explain
usa seven.compiler.source
usa seven.compiler.diagnostic

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

molde DiagnosticoLsp ::
  codigo: Texto
  mensagem: Texto
  linha: U32
  coluna: U32
fecha

molde SimboloLsp ::
  nome: Texto
  especie: Texto
  linha: U32
  coluna: U32
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

campo lsp_diagnosticos(diags: Lista<Diagnostico>) -> Lista<DiagnosticoLsp> ::
  solta saida := lista<DiagnosticoLsp>()

  para cada diag em diags ::
    lista_coloca(saida, DiagnosticoLsp {
      codigo: diag.codigo,
      mensagem: diag.mensagem,
      linha: diag.linha,
      coluna: diag.coluna
    })
  fecha

  devolve saida
fecha

campo lsp_simbolos(indice: IndiceSemantico) -> Lista<SimboloLsp> ::
  solta saida := lista<SimboloLsp>()

  para cada no em indice.nos ::
    lista_coloca(saida, SimboloLsp {
      nome: no.nome,
      especie: no.especie,
      linha: 0,
      coluna: 0
    })
  fecha

  devolve saida
fecha
