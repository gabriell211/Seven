modulo std.mem.bytes

usa std.base.resultado

molde Bytes ::
  dados: VistaMut<Byte>
  tamanho: U64
fecha

campo bytes_vazio(bytes: Bytes) -> Bit ::
  devolve bytes.tamanho == 0
fecha

campo bytes_novo() -> Bytes ::
  devolve sys_bytes_novo()
fecha

campo texto_bytes(valor: Texto) -> Bytes ::
  devolve sys_texto_bytes(valor)
fecha

campo bytes_texto(valor: Bytes) -> Texto ::
  devolve sys_bytes_texto(valor)
fecha

campo bytes_hex(valor: Bytes) -> Texto ::
  devolve sys_bytes_hex(valor)
fecha

campo bytes_pega(bytes: Bytes, indice: U64) -> Byte ::
  devolve sys_bytes_pega(bytes, indice)
fecha

campo bytes_coloca_byte(bytes: Bytes, valor: Byte) -> Bytes ::
  devolve sys_bytes_coloca_byte(bytes, valor)
fecha

campo bytes_coloca_u32(bytes: Bytes, valor: U32) -> Bytes ::
  devolve sys_bytes_coloca_u32_be(bytes, valor)
fecha

campo bytes_coloca_u64(bytes: Bytes, valor: U64) -> Bytes ::
  devolve sys_bytes_coloca_u64_be(bytes, valor)
fecha

campo bytes_coloca_texto(bytes: Bytes, valor: Texto) -> Bytes ::
  devolve sys_bytes_coloca_texto(bytes, valor)
fecha

campo bytes_coloca_texto_com_tamanho(bytes: Bytes, valor: Texto) -> Bytes ::
  bytes_coloca_u32(bytes, tamanho(valor))
  devolve bytes_coloca_texto(bytes, valor)
fecha

campo byte_em(bytes: Bytes, indice: U64) -> Resultado<Byte, Falha> ::
  veja indice >= bytes.tamanho ::
    devolve Falha(nova_falha("SV-MEM-LIMITE", "indice fora do limite"))
  fecha

  devolve Valor(bytes.dados @ indice)
fecha
