modulo std.ffi.c

molde CVoid ::
fecha

molde CChar ::
fecha

molde CInt ::
  valor: I32
fecha

molde CSize ::
  valor: U64
fecha

molde CBuffer ::
  dados: Ptr<Byte>
  tamanho: U64
fecha

campo c_texto(valor: Texto) -> Ptr<CChar> toca cru ::
  devolve sys_ffi_c_texto(valor)
fecha

campo c_bytes(buffer: Bytes) -> CBuffer toca cru ::
  devolve sys_ffi_c_bytes(buffer)
fecha
