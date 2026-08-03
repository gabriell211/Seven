modulo examples.interop_c

usa std.ffi.c

extern c campo c_puts(texto: Ptr<CChar>) -> I32 liga "puts"
extern cpp campo cpp_version() -> U32 liga "seven_cpp_version"

campo inicio() -> Num toca terminal, cru ::
  guarda msg := c_texto("Hello from Seven FFI")
  guarda codigo := c_puts(msg)
  devolve codigo
fecha
