modulo seven.runtime.svbc.opcode

selo Opcode ::
  Pare
  Const
  Carrega
  Guarda
  Soma
  Sub
  Mul
  Div
  Igual
  Diferente
  Menor
  MenorIgual
  Maior
  MaiorIgual
  Salta
  SaltaSeNao
  Chama
  Volta
  Caixa
  MarcaByte
  PegaByte
  Efeito
  Syscall
fecha

campo opcode_de_byte(valor: Byte) -> Resultado<Opcode, Falha> ::
  veja valor == 0 ::
    devolve Valor(Pare)
  fecha
  veja valor == 1 ::
    devolve Valor(Const)
  fecha
  veja valor == 2 ::
    devolve Valor(Carrega)
  fecha
  veja valor == 3 ::
    devolve Valor(Guarda)
  fecha
  veja valor == 4 ::
    devolve Valor(Soma)
  fecha
  veja valor == 5 ::
    devolve Valor(Sub)
  fecha
  veja valor == 6 ::
    devolve Valor(Mul)
  fecha
  veja valor == 7 ::
    devolve Valor(Div)
  fecha
  veja valor == 8 ::
    devolve Valor(Igual)
  fecha
  veja valor == 9 ::
    devolve Valor(Diferente)
  fecha
  veja valor == 10 ::
    devolve Valor(Menor)
  fecha
  veja valor == 11 ::
    devolve Valor(MenorIgual)
  fecha
  veja valor == 12 ::
    devolve Valor(Maior)
  fecha
  veja valor == 13 ::
    devolve Valor(MaiorIgual)
  fecha
  veja valor == 14 ::
    devolve Valor(Salta)
  fecha
  veja valor == 15 ::
    devolve Valor(SaltaSeNao)
  fecha
  veja valor == 16 ::
    devolve Valor(Chama)
  fecha
  veja valor == 17 ::
    devolve Valor(Volta)
  fecha
  veja valor == 18 ::
    devolve Valor(Caixa)
  fecha
  veja valor == 19 ::
    devolve Valor(MarcaByte)
  fecha
  veja valor == 20 ::
    devolve Valor(PegaByte)
  fecha
  veja valor == 21 ::
    devolve Valor(Efeito)
  fecha
  veja valor == 22 ::
    devolve Valor(Syscall)
  fecha

  devolve Falha(nova_falha("SVBC-OPCODE", "opcode desconhecido"))
fecha
