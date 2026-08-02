modulo seven.compiler.intelligence.suggest

usa seven.compiler.diagnostic
usa seven.compiler.intelligence.index

selo SeveridadeSugestao ::
  Baixa
  Media
  Alta
fecha

molde Sugestao ::
  titulo: Texto
  detalhe: Texto
  codigo: Texto
  severidade: SeveridadeSugestao
  aplicavel: Bit
fecha

campo sugestoes_para(diag: Diagnostico, indice: IndiceSemantico) -> Lista<Sugestao> ::
  solta sugestoes := lista<Sugestao>()

  veja diag.codigo == "SV-NOME-INEXISTENTE" ::
    adiciona_nome_parecido(sugestoes, diag, indice)
  fecha

  veja diag.codigo == "SV-EFEITO-VAZOU" ::
    lista_coloca(sugestoes, Sugestao {
      titulo: "Declare o efeito no campo chamador",
      detalhe: "O campo chama codigo que toca mundo externo. Adicione o efeito em `toca` ou isole a chamada.",
      codigo: "SIA-EFEITO-DECLARAR",
      severidade: Alta,
      aplicavel: sim
    })
  fecha

  veja diag.codigo == "SV-TIPO-IMUTAVEL" ::
    lista_coloca(sugestoes, Sugestao {
      titulo: "Troque guarda por solta",
      detalhe: "O valor foi criado imutavel, mas depois recebe nova atribuicao.",
      codigo: "SIA-MUTAVEL",
      severidade: Media,
      aplicavel: sim
    })
  fecha

  devolve sugestoes
fecha
