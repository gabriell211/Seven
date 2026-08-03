modulo std.crypto.hash

usa std.mem.bytes

molde Hash ::
  algoritmo: Texto
  valor: Bytes
fecha

campo sha256(dados: Bytes) -> Hash toca ambiente ::
  devolve Hash {
    algoritmo: "sha256",
    valor: sys_sha256(dados)
  }
fecha

campo hash_texto(hash: Hash) -> Texto ::
  devolve bytes_hex(hash.valor)
fecha
