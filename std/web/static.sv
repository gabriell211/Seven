modulo std.web.static

usa std.base.resultado
usa std.fs.file
usa std.web.http
usa std.web.router

campo arquivos_estaticos(raiz: Texto) -> Campo<Contexto, Resposta> ::
  devolve campo(ctx: Contexto) -> Resposta toca disco ::
    guarda caminho := caminho_seguro(raiz, ctx.requisicao.caminho)
    guarda conteudo := arquivo_bytes(caminho)

    veja conteudo e Falha ::
      devolve nao_encontrado()
    fecha

    devolve Resposta {
      status: 200,
      cabecalhos: lista_de(cabecalho("content-type", mime_por_caminho(caminho))),
      corpo: conteudo.valor
    }
  fecha
fecha

campo caminho_seguro(raiz: Texto, caminho: Texto) -> Texto ::
  devolve sys_caminho_seguro(raiz, caminho)
fecha

campo mime_por_caminho(caminho: Texto) -> Texto ::
  devolve sys_mime_por_caminho(caminho)
fecha
