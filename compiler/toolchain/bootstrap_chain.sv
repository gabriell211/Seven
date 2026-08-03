modulo seven.compiler.toolchain.bootstrap_chain

usa std.base.resultado
usa std.base.texto
usa std.fs.file
usa std.mem.bytes

molde EtapaBootstrap ::
  nome: Texto
  entrada: Texto
  saida: Texto
  verificador: Texto
fecha

molde CadeiaBootstrap ::
  etapas: Lista<EtapaBootstrap>
  hash_seven: Texto
  hash_self: Texto
  equivalente: Bit
  produtivo: Bit
  comando_verificado: Bit
fecha

campo cadeia_bootstrap_padrao() -> CadeiaBootstrap toca disco ::
  solta etapas := lista<EtapaBootstrap>()

  lista_coloca(etapas, EtapaBootstrap {
    nome: "seed",
    entrada: "seed/genesis.svhex",
    saida: "build/seven0.svbc",
    verificador: "SVS0"
  })

  lista_coloca(etapas, EtapaBootstrap {
    nome: "seven0",
    entrada: "compiler0/seven0.sv",
    saida: "build/seven.svbc",
    verificador: "SVBC0"
  })

  lista_coloca(etapas, EtapaBootstrap {
    nome: "seven",
    entrada: "compiler/seven.sv",
    saida: "build/seven.self.svbc",
    verificador: "SVBC"
  })

  guarda h1 := hash_arquivo_ou_vazio("build/seven.svbc")
  guarda h2 := hash_arquivo_ou_vazio("build/seven.self.svbc")
  guarda p1 := artefato_bootstrap_svbc_produtivo("build/seven.svbc")
  guarda p2 := artefato_bootstrap_svbc_produtivo("build/seven.self.svbc")

  devolve CadeiaBootstrap {
    etapas: etapas,
    hash_seven: h1,
    hash_self: h2,
    equivalente: h1 != "" e h1 == h2,
    produtivo: p1 e p2,
    comando_verificado: nao
  }
fecha

campo verifica_cadeia_bootstrap() -> Resultado<CadeiaBootstrap, Falha> toca disco ::
  guarda cadeia := cadeia_bootstrap_padrao()

  para cada etapa em cadeia.etapas ::
    veja arquivo_existe(etapa.entrada) == nao ::
      devolve Falha(nova_falha("SV-BOOT-ENTRADA", "entrada ausente: " + etapa.entrada))
    fecha
  fecha

  devolve Valor(cadeia)
fecha

campo cadeia_self_hosted(cadeia: CadeiaBootstrap) -> Bit ::
  devolve cadeia.equivalente e cadeia.produtivo e cadeia.comando_verificado
fecha

campo hash_arquivo_ou_vazio(caminho: Texto) -> Texto toca disco ::
  veja arquivo_existe(caminho) == nao ::
    devolve ""
  fecha

  devolve sha256_arquivo(caminho)
fecha

campo artefato_bootstrap_svbc_produtivo(caminho: Texto) -> Bit toca disco ::
  guarda dados := arquivo_bytes(caminho)

  veja dados e Falha ::
    devolve nao
  fecha

  devolve bytes_tem_svbc_v1(dados.valor)
fecha

campo bytes_tem_svbc_v1(dados: Bytes) -> Bit ::
  veja dados.tamanho < 8 ::
    devolve nao
  fecha

  devolve bytes_pega(dados, 0) == 83 e
    bytes_pega(dados, 1) == 86 e
    bytes_pega(dados, 2) == 66 e
    bytes_pega(dados, 3) == 67 e
    bytes_pega(dados, 4) == 0 e
    bytes_pega(dados, 5) == 0 e
    bytes_pega(dados, 6) == 0 e
    bytes_pega(dados, 7) == 1
fecha
