modulo seven.compiler.memory

usa seven.compiler.ast
usa seven.compiler.diagnostic

molde CaixaMemoria ::
  nome: Texto
  tamanho: U64
  span: Span
fecha

molde TabelaMemoria ::
  caixas: Mapa<Texto, CaixaMemoria>
  diagnosticos: Lista<Diagnostico>
fecha

campo confere_memoria(programas: Lista<Programa>) -> TabelaMemoria ::
  solta tabela := TabelaMemoria {
    caixas: mapa<Texto, CaixaMemoria>(),
    diagnosticos: lista<Diagnostico>()
  }

  para cada programa em programas ::
    para cada item em programa.itens ::
      veja item e ItemCampo ::
        confere_memoria_campo(item.valor, tabela)
      fecha
    fecha
  fecha

  devolve tabela
fecha

campo confere_memoria_campo(campo: Campo, tabela: TabelaMemoria) -> Nada ::
  para cada cmd em campo.corpo ::
    confere_memoria_comando(cmd, tabela)
  fecha
fecha

campo confere_memoria_comando(cmd: Comando, tabela: TabelaMemoria) -> Nada ::
  veja cmd e CmdCaixa ::
    guarda tamanho := literal_num(cmd.valor.tamanho)
    mapa_define(tabela.caixas, cmd.valor.nome, CaixaMemoria {
      nome: cmd.valor.nome,
      tamanho: tamanho,
      span: cmd.valor.span
    })
  fecha

  veja cmd e CmdMarca ::
    confere_acesso_caixa(tabela, cmd.valor.bloco, literal_num(cmd.valor.indice), cmd.valor.span)
  fecha

  veja cmd e CmdPega ::
    confere_acesso_caixa(tabela, cmd.valor.bloco, literal_num(cmd.valor.indice), cmd.valor.span)
  fecha
fecha

campo confere_acesso_caixa(tabela: TabelaMemoria, nome: Texto, indice: U64, span: Span) -> Nada ::
  guarda caixa := mapa_pega(tabela.caixas, nome)

  veja caixa e Algo ::
    veja indice >= caixa.valor.tamanho ::
      lista_coloca(tabela.diagnosticos, erro("SV-MEM-LIMITE", "indice fora do limite conhecido", span.arquivo, span.linha, span.coluna))
    fecha
  fecha
fecha

campo literal_num(expr: Expressao) -> U64 ::
  veja expr e ExprLiteral ::
    veja expr.valor e LitNum ::
      devolve expr.valor.valor
    fecha
  fecha

  devolve 0
fecha
