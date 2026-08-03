modulo std.mem.ptr

usa std.base.resultado

molde Ponteiro<T> ::
  ptr: Ptr<T>
fecha

campo ptr_nulo<T>() -> Ponteiro<T> toca cru ::
  devolve Ponteiro<T> {
    ptr: sys_ptr_nulo()
  }
fecha

campo ptr_de<T>(ptr: Ptr<T>) -> Ponteiro<T> ::
  devolve Ponteiro<T> {
    ptr: ptr
  }
fecha

campo ptr_offset<T>(ponteiro: Ponteiro<T>, bytes: U64) -> Ponteiro<T> toca cru ::
  devolve Ponteiro<T> {
    ptr: sys_ptr_offset(ponteiro.ptr, bytes)
  }
fecha

campo ptr_igual<T>(a: Ponteiro<T>, b: Ponteiro<T>) -> Bit toca cru ::
  devolve sys_ptr_igual(a.ptr, b.ptr)
fecha

campo ptr_le_byte(ponteiro: Ponteiro<Byte>) -> Resultado<Byte, Falha> toca cru ::
  devolve sys_ptr_le_byte(ponteiro.ptr)
fecha

campo ptr_escreve_byte(ponteiro: Ponteiro<Byte>, valor: Byte) -> Resultado<Nada, Falha> toca cru ::
  devolve sys_ptr_escreve_byte(ponteiro.ptr, valor)
fecha
