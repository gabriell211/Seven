modulo seven.runtime.platform.svbc.io

usa seven.runtime.platform.svbc.bytes
usa seven.runtime.platform.svbc.sandbox
usa seven.runtime.svbc.value

campo intr_terminal_escreve(args: Lista<ValorVm>) -> Resultado<ValorVm, Falha> toca terminal ::
  svbc_terminal_escreve(valor_texto(lista_pega(args, 0)))
  devolve Valor(VmNada)
fecha

campo intr_arquivo_ler_texto(args: Lista<ValorVm>) -> Resultado<ValorVm, Falha> toca disco ::
  guarda conteudo := svbc_arquivo_ler_texto(valor_texto(lista_pega(args, 0)))
  veja conteudo e Falha ::
    devolve conteudo
  fecha
  devolve Valor(VmTexto(conteudo.valor))
fecha

campo intr_arquivo_ler_bytes(args: Lista<ValorVm>) -> Resultado<ValorVm, Falha> toca disco ::
  guarda conteudo := svbc_arquivo_ler_bytes(valor_texto(lista_pega(args, 0)))
  veja conteudo e Falha ::
    devolve conteudo
  fecha
  devolve Valor(VmBytes(conteudo.valor))
fecha

campo intr_arquivo_grava_texto(args: Lista<ValorVm>) -> Resultado<ValorVm, Falha> toca disco ::
  guarda r := svbc_arquivo_grava_texto(valor_texto(lista_pega(args, 0)), valor_texto(lista_pega(args, 1)))
  veja r e Falha ::
    devolve r
  fecha
  devolve Valor(VmNada)
fecha

campo intr_arquivo_existe(args: Lista<ValorVm>) -> Resultado<ValorVm, Falha> toca disco ::
  devolve Valor(VmBit(svbc_arquivo_existe(valor_texto(lista_pega(args, 0)))))
fecha

campo intr_env(args: Lista<ValorVm>) -> Resultado<ValorVm, Falha> toca ambiente ::
  guarda valor := svbc_env(valor_texto(lista_pega(args, 0)))
  veja valor e Falha ::
    devolve valor
  fecha
  devolve Valor(VmTexto(valor.valor))
fecha

campo intr_args(args: Lista<ValorVm>) -> Resultado<ValorVm, Falha> toca ambiente ::
  devolve Valor(sys_vm_lista_texto(svbc_args()))
fecha

campo intr_tempo_agora(args: Lista<ValorVm>) -> Resultado<ValorVm, Falha> toca tempo ::
  devolve Valor(VmU64(svbc_tempo_agora()))
fecha

campo intr_tempo_iso(args: Lista<ValorVm>) -> Resultado<ValorVm, Falha> toca tempo ::
  devolve Valor(VmTexto(svbc_tempo_iso()))
fecha

campo intr_dorme(args: Lista<ValorVm>) -> Resultado<ValorVm, Falha> toca tempo ::
  svbc_dorme(valor_vm_u64(lista_pega(args, 0)))
  devolve Valor(VmNada)
fecha
