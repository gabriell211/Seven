modulo seven.compiler.ast

usa seven.compiler.source
usa seven.compiler.token

molde Programa ::
  modulo: Texto
  usos: Lista<Uso>
  itens: Lista<Item>
fecha

molde Uso ::
  caminho: Texto
  apelido: Texto
  span: Span
fecha

selo Item ::
  ItemCampo(Campo)
  ItemMolde(Molde)
  ItemSelo(Selo)
  ItemConst(Constante)
fecha

molde Campo ::
  nome: Texto
  parametros: Lista<Parametro>
  retorno: TipoSintaxe
  efeitos: Lista<Texto>
  corpo: Lista<Comando>
  span: Span
fecha

molde Parametro ::
  nome: Texto
  tipo: TipoSintaxe
  span: Span
fecha

molde Molde ::
  nome: Texto
  membros: Lista<Membro>
  span: Span
fecha

molde Membro ::
  nome: Texto
  tipo: TipoSintaxe
  span: Span
fecha

molde Selo ::
  nome: Texto
  variantes: Lista<Variante>
  span: Span
fecha

molde Variante ::
  nome: Texto
  carga: Lista<TipoSintaxe>
  span: Span
fecha

molde Constante ::
  nome: Texto
  tipo: TipoSintaxe
  valor: Expressao
  span: Span
fecha

molde TipoSintaxe ::
  nome: Texto
  argumentos: Lista<TipoSintaxe>
  span: Span
fecha

selo Comando ::
  CmdCria(Cria)
  CmdVira(Vira)
  CmdDiga(Diga)
  CmdVeja(Veja)
  CmdGira(Gira)
  CmdDevolve(Devolve)
  CmdCaixa(Caixa)
  CmdMarca(Marca)
  CmdPega(Pega)
  CmdZona(Zona)
fecha

molde Cria ::
  mutavel: Bit
  nome: Texto
  tipo: TipoSintaxe
  valor: Expressao
  span: Span
fecha

molde Vira ::
  alvo: Expressao
  valor: Expressao
  span: Span
fecha

molde Diga ::
  valor: Expressao
  span: Span
fecha

molde Veja ::
  condicao: Expressao
  entao: Lista<Comando>
  senao: Lista<Comando>
  span: Span
fecha

molde Gira ::
  condicao: Expressao
  corpo: Lista<Comando>
  span: Span
fecha

molde Devolve ::
  valor: Expressao
  span: Span
fecha

molde Caixa ::
  nome: Texto
  tamanho: Expressao
  span: Span
fecha

molde Marca ::
  bloco: Texto
  indice: Expressao
  valor: Expressao
  span: Span
fecha

molde Pega ::
  bloco: Texto
  indice: Expressao
  destino: Texto
  span: Span
fecha

molde Zona ::
  efeito: Texto
  corpo: Lista<Comando>
  span: Span
fecha

selo Expressao ::
  ExprLiteral(Literal)
  ExprNome(NomeExpr)
  ExprAcesso(AcessoExpr)
  ExprChamada(ChamadaExpr)
  ExprBinaria(BinariaExpr)
  ExprUnaria(UnariaExpr)
  ExprConstrucao(ConstrucaoExpr)
fecha

selo Literal ::
  LitNum(Num)
  LitTexto(Texto)
  LitBit(Bit)
  LitNulo
fecha

molde NomeExpr ::
  nome: Texto
  span: Span
fecha

molde AcessoExpr ::
  base: Expressao
  membro: Texto
  span: Span
fecha

molde ChamadaExpr ::
  alvo: Expressao
  argumentos: Lista<Expressao>
  span: Span
fecha

molde BinariaExpr ::
  esquerda: Expressao
  operador: Texto
  direita: Expressao
  span: Span
fecha

molde UnariaExpr ::
  operador: Texto
  direita: Expressao
  span: Span
fecha

molde ConstrucaoExpr ::
  tipo: TipoSintaxe
  campos: Lista<CampoValor>
  span: Span
fecha

molde CampoValor ::
  nome: Texto
  valor: Expressao
  span: Span
fecha
