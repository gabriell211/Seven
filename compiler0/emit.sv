modulo seven0.emit

usa seven0.primitives
usa seven0.ast
usa seven0.check
usa seven0.svbc0

campo emitir_svbc0(unidade: Unidade) -> Bytes ::
  solta bytes := bytes_novo()

  bytes_texto(bytes, MagicSvbc0)
  bytes_u32(bytes, VersaoSvbc0)
  emite_constantes(bytes, unidade)
  emite_campos(bytes, unidade)
  emite_codigo(bytes, unidade)
  bytes_byte(bytes, OpPare)

  devolve bytes
fecha

campo emite_codigo(bytes: Bytes, unidade: Unidade) -> Nada ::
  para cada item em unidade.programa.itens ::
    veja item.especie == "campo" ::
      emite_campo(bytes, item)
    fecha
  fecha
fecha
