modulo seven.compiler.intelligence.explain

usa seven.compiler.diagnostic
usa seven.compiler.intelligence.index

molde Explicacao ::
  resumo: Texto
  causa: Texto
  correcao: Texto
  referencia: Texto
fecha

campo explica_diagnostico(diag: Diagnostico, indice: IndiceSemantico) -> Explicacao ::
  veja diag.codigo == "SV-EFEITO-VAZOU" ::
    devolve Explicacao {
      resumo: "Um efeito externo escapou de um campo puro.",
      causa: "Campos sem `toca` sao puros por padrao.",
      correcao: "Declare o efeito, mova a chamada para outro campo ou injete uma abstracao pura.",
      referencia: "docs/effects.md"
    }
  fecha

  veja diag.codigo == "SV-MEM-LIMITE" ::
    devolve Explicacao {
      resumo: "Acesso fora do limite de memoria.",
      causa: "O indice usado nao cabe na caixa, fatia ou bloco.",
      correcao: "Confirme o tamanho antes de acessar ou ajuste o indice.",
      referencia: "docs/memory-model.md"
    }
  fecha

  devolve Explicacao {
    resumo: diag.mensagem,
    causa: "O compilador encontrou uma regra violada.",
    correcao: "Leia o diagnostico e as sugestoes associadas.",
    referencia: "docs/diagnostics.md"
  }
fecha
