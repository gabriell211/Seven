modulo std.mem.alloc

usa std.base.resultado

molde BlocoAlocado ::
  ptr: Ptr<Byte>
  tamanho: U64
  alinhamento: U64
fecha

campo aloca(tamanho: U64) -> Resultado<BlocoAlocado, Falha> toca cru ::
  devolve aloca_alinhado(tamanho, 8)
fecha

campo aloca_alinhado(tamanho: U64, alinhamento: U64) -> Resultado<BlocoAlocado, Falha> toca cru ::
  devolve sys_mem_aloca(tamanho, alinhamento)
fecha

campo realoca(bloco: BlocoAlocado, novo_tamanho: U64) -> Resultado<BlocoAlocado, Falha> toca cru ::
  devolve sys_mem_realoca(bloco, novo_tamanho)
fecha

campo libera(bloco: BlocoAlocado) -> Resultado<Nada, Falha> toca cru ::
  devolve sys_mem_libera(bloco)
fecha

campo zera(bloco: BlocoAlocado) -> Resultado<Nada, Falha> toca cru ::
  devolve sys_mem_zera(bloco)
fecha

campo copia(destino: BlocoAlocado, origem: BlocoAlocado, tamanho: U64) -> Resultado<Nada, Falha> toca cru ::
  devolve sys_mem_copia(destino, origem, tamanho)
fecha
