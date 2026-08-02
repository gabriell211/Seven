modulo std.os.process

usa std.base.resultado
usa std.base.lista

molde ProcessoSaida ::
  codigo: Num
  stdout: Texto
  stderr: Texto
fecha

campo processo_roda(comando: Texto, args: Lista<Texto>) -> Resultado<ProcessoSaida, Falha> toca ambiente, disco ::
  devolve sys_processo_roda(comando, args)
fecha
