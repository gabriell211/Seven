modulo std.serial.protobuf

usa std.base.resultado
usa std.base.mapa
usa std.mem.bytes

molde ProtoMensagem ::
  nome: Texto
  campos: Mapa<Texto, Bytes>
fecha

campo protobuf_codifica(msg: ProtoMensagem) -> Bytes ::
  devolve sys_protobuf_codifica(msg)
fecha

campo protobuf_parse(nome: Texto, dados: Bytes) -> Resultado<ProtoMensagem, Falha> ::
  devolve sys_protobuf_parse(nome, dados)
fecha
