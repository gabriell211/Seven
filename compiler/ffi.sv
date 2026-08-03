modulo seven.compiler.ffi

usa seven.compiler.ast
usa seven.compiler.diagnostic

molde TabelaFfi ::
  campos: Lista<CampoExterno>
  diagnosticos: Lista<Diagnostico>
fecha

campo registra_externos(programas: Lista<Programa>) -> TabelaFfi ::
  solta tabela := TabelaFfi {
    campos: lista<CampoExterno>(),
    diagnosticos: lista<Diagnostico>()
  }

  para cada programa em programas ::
    para cada item em programa.itens ::
      veja item e ItemExterno ::
        lista_coloca(tabela.campos, item.valor)
      fecha
    fecha
  fecha

  devolve tabela
fecha

campo ffi_tipo_c(tipo: TipoSintaxe) -> Texto ::
  veja tipo.nome == "Nada" ::
    devolve "void"
  fecha
  veja tipo.nome == "Bit" ::
    devolve "bool"
  fecha
  veja tipo.nome == "I32" ::
    devolve "int32_t"
  fecha
  veja tipo.nome == "U32" ::
    devolve "uint32_t"
  fecha
  veja tipo.nome == "U64" ::
    devolve "uint64_t"
  fecha
  veja tipo.nome == "Texto" ::
    devolve "const char*"
  fecha
  veja tipo.nome == "Ptr" ::
    devolve ffi_tipo_c(lista_pega(tipo.argumentos, 0)) + "*"
  fecha

  devolve "void*"
fecha

campo ffi_manifesto(tabela: TabelaFfi) -> Texto ::
  solta saida := "formato seven-ffi-v1\n"

  para cada campo em tabela.campos ::
    vira saida := saida + "simbolo " + campo.nome + " " + campo.simbolo + " " + ffi_nome_abi(campo.abi) + "\n"
  fecha

  devolve saida
fecha

campo ffi_nome_abi(abi: AbiExterna) -> Texto ::
  veja abi e AbiCpp ::
    devolve "cpp"
  fecha

  devolve "c"
fecha
