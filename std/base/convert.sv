modulo std.base.convert

campo texto(valor: Num) -> Texto ::
  devolve sys_texto_num(valor)
fecha

campo texto_u64(valor: U64) -> Texto ::
  devolve sys_texto_u64(valor)
fecha

campo numero(valor: Texto) -> Num ::
  devolve sys_numero(valor)
fecha
