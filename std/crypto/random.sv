modulo std.crypto.random

usa std.mem.bytes

campo aleatorio_bytes(tamanho: U64) -> Bytes toca ambiente ::
  devolve sys_aleatorio_bytes(tamanho)
fecha

campo aleatorio_u64() -> U64 toca ambiente ::
  devolve sys_aleatorio_u64()
fecha

campo uuid_v4() -> Texto toca ambiente ::
  devolve sys_uuid_v4()
fecha
