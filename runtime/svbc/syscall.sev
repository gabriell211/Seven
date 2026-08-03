modulo seven.runtime.svbc.syscall

usa seven.runtime.platform.intrinsic
usa seven.runtime.svbc.value

molde TabelaSyscall ::
  intrinsecos: Lista<Intrinseco>
fecha

campo syscall_tabela_padrao() -> TabelaSyscall ::
  devolve TabelaSyscall {
    intrinsecos: intrinsecos_padrao()
  }
fecha

campo syscall_chama(tabela: TabelaSyscall, nome: Texto, args: Lista<ValorVm>) -> Resultado<ValorVm, Falha> toca rede, disco, terminal, tempo, ambiente, frontend ::
  para cada item em tabela.intrinsecos ::
    veja item.nome == nome ::
      devolve item.executa(args)
    fecha
  fecha

  devolve Falha(nova_falha("SVBC-SYSCALL", "intrinseco desconhecido: " + nome))
fecha
