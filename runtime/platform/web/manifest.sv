modulo seven.runtime.platform.web.manifest

usa seven.runtime.platform.web.target

molde ManifestoWeb ::
  nome: Texto
  entrada: Texto
  arquivos: Lista<Texto>
fecha

campo web_manifesto(nome: Texto, entrada: Texto) -> ManifestoWeb ::
  devolve ManifestoWeb {
    nome: nome,
    entrada: entrada,
    arquivos: lista<Texto>()
  }
fecha

campo web_empacota(alvo: AlvoWeb, manifesto: ManifestoWeb, imagem: Bytes) -> Resultado<Bytes, Falha> ::
  devolve sys_web_empacota(alvo, manifesto, imagem)
fecha
