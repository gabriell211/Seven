modulo std.frontend.assets

usa std.base.resultado

molde Asset ::
  caminho: Texto
  tipo: Texto
  hash: Texto
fecha

molde ManifestoAssets ::
  assets: Lista<Asset>
fecha

campo asset(caminho: Texto, tipo: Texto) -> Asset ::
  devolve Asset {
    caminho: caminho,
    tipo: tipo,
    hash: ""
  }
fecha

campo asset_url(asset_ref: Asset) -> Texto ::
  veja asset_ref.hash == "" ::
    devolve asset_ref.caminho
  fecha

  devolve asset_ref.caminho + "?v=" + asset_ref.hash
fecha

campo assets_manifesto() -> ManifestoAssets ::
  devolve ManifestoAssets {
    assets: lista<Asset>()
  }
fecha

campo assets_adiciona(manifesto: ManifestoAssets, item: Asset) -> ManifestoAssets ::
  lista_coloca(manifesto.assets, item)
  devolve manifesto
fecha
