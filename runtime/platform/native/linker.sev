modulo seven.runtime.platform.native.linker

usa seven.runtime.platform.native.target
usa seven.runtime.svbc.image

molde ArtefatoNativo ::
  alvo: AlvoNativo
  bytes: Bytes
  simbolos: Lista<Texto>
fecha

campo baixa_nativo(imagem: ImagemSvbc, alvo: AlvoNativo) -> Resultado<ArtefatoNativo, Falha> ::
  devolve sys_native_baixa(imagem, alvo)
fecha

campo grava_nativo(artefato: ArtefatoNativo, caminho: Texto) -> Resultado<Nada, Falha> toca disco ::
  devolve sys_arquivo_grava_texto(caminho, bytes_texto(artefato.bytes))
fecha
