modulo seven.runtime.svbc.verifier

usa std.base.lista
usa seven.runtime.svbc.image
usa seven.runtime.svbc.opcode

molde ErroVerificacao ::
  codigo: Texto
  mensagem: Texto
  ip: U64
fecha

molde ResultadoVerificacao ::
  ok: Bit
  erros: Lista<ErroVerificacao>
fecha

campo verifica_svbc(img: ImagemSvbc) -> ResultadoVerificacao ::
  solta erros := lista<ErroVerificacao>()

  verifica_entrada(img, erros)
  verifica_saltos(img, erros)
  verifica_constantes(img, erros)
  verifica_locais(img, erros)
  verifica_pilha(img, erros)
  verifica_efeitos(img, erros)

  devolve ResultadoVerificacao {
    ok: lista_tamanho(erros) == 0,
    erros: erros
  }
fecha

campo erro_verificacao(erros: Lista<ErroVerificacao>, codigo: Texto, mensagem: Texto, ip: U64) -> Nada ::
  lista_coloca(erros, ErroVerificacao {
    codigo: codigo,
    mensagem: mensagem,
    ip: ip
  })
fecha

campo contem_texto(itens: Lista<Texto>, alvo: Texto) -> Bit ::
  para cada item em itens ::
    veja item == alvo ::
      devolve sim
    fecha
  fecha

  devolve nao
fecha

campo campo_da_instrucao(img: ImagemSvbc, ip: U64) -> CampoImagem ::
  solta achou := nao
  solta escolhido := CampoImagem {
    nome: "",
    entrada: 0,
    locais: 0,
    parametros: 0,
    efeitos: lista<Texto>()
  }

  para cada item em img.campos ::
    veja item.entrada <= ip ::
      veja achou == nao ::
        vira escolhido := item
        vira achou := sim
      outro ::
        veja item.entrada >= escolhido.entrada ::
          vira escolhido := item
        fecha
      fecha
    fecha
  fecha

  devolve escolhido
fecha

campo efeito_syscall(nome: Texto) -> Texto ::
  veja nome == "terminal_diga" ::
    devolve "terminal"
  fecha

  veja nome == "seven_cmd_help" ::
    devolve "terminal"
  fecha

  veja nome == "seven_cmd_version" ::
    devolve "terminal"
  fecha

  veja nome == "seven_cmd_unimplemented" ::
    devolve "terminal"
  fecha

  veja nome == "seven_verify_foundation" ::
    devolve "disco"
  fecha

  devolve "puro"
fecha

campo verifica_entrada(img: ImagemSvbc, erros: Lista<ErroVerificacao>) -> Nada ::
  veja campo_entrada_existe(img, "inicio") == nao ::
    erro_verificacao(erros, "SVBC-ENTRADA", "campo inicio ausente", 0)
  fecha
fecha

campo verifica_saltos(img: ImagemSvbc, erros: Lista<ErroVerificacao>) -> Nada ::
  solta ip := 0

  gira ip < lista_tamanho(img.codigo) ::
    guarda instr := lista_pega(img.codigo, ip)

    veja instr.opcode e Salta ::
      veja instr.a >= lista_tamanho(img.codigo) ::
        erro_verificacao(erros, "SVBC-SALTO", "destino de salto fora do codigo", instr.ip)
      fecha
    fecha

    veja instr.opcode e SaltaSeNao ::
      veja instr.a >= lista_tamanho(img.codigo) ::
        erro_verificacao(erros, "SVBC-SALTO", "destino de salto condicional fora do codigo", instr.ip)
      fecha
    fecha

    vira ip := ip + 1
  fecha
fecha

campo verifica_constantes(img: ImagemSvbc, erros: Lista<ErroVerificacao>) -> Nada ::
  solta ip := 0

  gira ip < lista_tamanho(img.codigo) ::
    guarda instr := lista_pega(img.codigo, ip)

    veja instr.opcode e Const ::
      veja instr.a >= lista_tamanho(img.constantes) ::
        erro_verificacao(erros, "SVBC-CONST", "constante fora do limite", instr.ip)
      fecha
    fecha

    veja instr.opcode e Syscall ::
      veja instr.a >= lista_tamanho(img.nomes) ::
        erro_verificacao(erros, "SVBC-NOME", "nome de syscall fora do limite", instr.ip)
      fecha
    fecha

    vira ip := ip + 1
  fecha
fecha

campo verifica_locais(img: ImagemSvbc, erros: Lista<ErroVerificacao>) -> Nada ::
  solta ip := 0

  gira ip < lista_tamanho(img.codigo) ::
    guarda instr := lista_pega(img.codigo, ip)
    guarda dono := campo_da_instrucao(img, ip)

    veja instr.opcode e Carrega ::
      veja instr.a >= dono.locais ::
        erro_verificacao(erros, "SVBC-LOCAL", "carrega local fora do limite", instr.ip)
      fecha
    fecha

    veja instr.opcode e Guarda ::
      veja instr.a >= dono.locais ::
        erro_verificacao(erros, "SVBC-LOCAL", "guarda local fora do limite", instr.ip)
      fecha
    fecha

    veja instr.opcode e Chama ::
      veja instr.a >= lista_tamanho(img.campos) ::
        erro_verificacao(erros, "SVBC-CAMPO", "chamada para campo fora do limite", instr.ip)
      outro ::
        guarda alvo := lista_pega(img.campos, instr.a)
        veja instr.b != alvo.parametros ::
          erro_verificacao(erros, "SVBC-ARGS", "quantidade de argumentos nao confere", instr.ip)
        fecha
      fecha
    fecha

    vira ip := ip + 1
  fecha
fecha

campo verifica_pilha(img: ImagemSvbc, erros: Lista<ErroVerificacao>) -> Nada ::
  solta profundidade := 0
  solta ip := 0

  gira ip < lista_tamanho(img.codigo) ::
    guarda instr := lista_pega(img.codigo, ip)

    veja instr.opcode e Const ::
      vira profundidade := profundidade + 1
    fecha

    veja instr.opcode e Carrega ::
      vira profundidade := profundidade + 1
    fecha

    veja instr.opcode e Guarda ::
      veja profundidade < 1 ::
        erro_verificacao(erros, "SVBC-PILHA", "guarda sem valor na pilha", instr.ip)
      outro ::
        vira profundidade := profundidade - 1
      fecha
    fecha

    veja instr.opcode e Soma ::
      vira profundidade := efeito_binario_pilha(profundidade, erros, instr.ip)
    fecha

    veja instr.opcode e Sub ::
      vira profundidade := efeito_binario_pilha(profundidade, erros, instr.ip)
    fecha

    veja instr.opcode e Mul ::
      vira profundidade := efeito_binario_pilha(profundidade, erros, instr.ip)
    fecha

    veja instr.opcode e Div ::
      vira profundidade := efeito_binario_pilha(profundidade, erros, instr.ip)
    fecha

    veja instr.opcode e Igual ::
      vira profundidade := efeito_binario_pilha(profundidade, erros, instr.ip)
    fecha

    veja instr.opcode e Diferente ::
      vira profundidade := efeito_binario_pilha(profundidade, erros, instr.ip)
    fecha

    veja instr.opcode e Menor ::
      vira profundidade := efeito_binario_pilha(profundidade, erros, instr.ip)
    fecha

    veja instr.opcode e MenorIgual ::
      vira profundidade := efeito_binario_pilha(profundidade, erros, instr.ip)
    fecha

    veja instr.opcode e Maior ::
      vira profundidade := efeito_binario_pilha(profundidade, erros, instr.ip)
    fecha

    veja instr.opcode e MaiorIgual ::
      vira profundidade := efeito_binario_pilha(profundidade, erros, instr.ip)
    fecha

    veja instr.opcode e SaltaSeNao ::
      veja profundidade < 1 ::
        erro_verificacao(erros, "SVBC-PILHA", "salto condicional sem condicao", instr.ip)
      outro ::
        vira profundidade := profundidade - 1
      fecha
    fecha

    veja instr.opcode e Chama ::
      veja profundidade < instr.b ::
        erro_verificacao(erros, "SVBC-PILHA", "chamada sem argumentos suficientes", instr.ip)
      outro ::
        vira profundidade := profundidade - instr.b + 1
      fecha
    fecha

    veja instr.opcode e Syscall ::
      veja profundidade < instr.b ::
        erro_verificacao(erros, "SVBC-PILHA", "syscall sem argumentos suficientes", instr.ip)
      outro ::
        vira profundidade := profundidade - instr.b + 1
      fecha
    fecha

    veja instr.opcode e Volta ::
      veja profundidade < 1 ::
        erro_verificacao(erros, "SVBC-PILHA", "retorno sem valor", instr.ip)
      fecha
    fecha

    vira ip := ip + 1
  fecha
fecha

campo verifica_efeitos(img: ImagemSvbc, erros: Lista<ErroVerificacao>) -> Nada ::
  solta ip := 0

  gira ip < lista_tamanho(img.codigo) ::
    guarda instr := lista_pega(img.codigo, ip)

    veja instr.opcode e Syscall ::
      veja instr.a < lista_tamanho(img.nomes) ::
        guarda nome := lista_pega(img.nomes, instr.a)
        guarda efeito := efeito_syscall(nome)
        guarda dono := campo_da_instrucao(img, ip)

        veja efeito != "puro" ::
          veja contem_texto(dono.efeitos, efeito) == nao ::
            erro_verificacao(erros, "SVBC-EFEITO", "syscall exige efeito ausente: " + efeito, instr.ip)
          fecha
        fecha
      fecha
    fecha

    vira ip := ip + 1
  fecha
fecha

campo campo_entrada_existe(img: ImagemSvbc, nome: Texto) -> Bit ::
  para cada item em img.campos ::
    veja item.nome == nome ::
      devolve sim
    fecha
  fecha

  devolve nao
fecha

campo efeito_binario_pilha(profundidade: Num, erros: Lista<ErroVerificacao>, ip: U64) -> Num ::
  veja profundidade < 2 ::
    erro_verificacao(erros, "SVBC-PILHA", "operacao binaria sem operandos", ip)
    devolve profundidade
  fecha

  devolve profundidade - 1
fecha
