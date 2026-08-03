modulo seven.runtime.platform.web.target

usa seven.runtime.platform.abi

molde AlvoWeb ::
  nome: Texto
  imports: Lista<ContratoIntrinseco>
  saida: Texto
fecha

campo alvo_web() -> AlvoWeb ::
  solta imports := lista<ContratoIntrinseco>()

  lista_coloca(imports, contrato_intrinseco("frontend_monta", CapFrontend, "Nada"))
  lista_coloca(imports, contrato_intrinseco("frontend_escuta", CapFrontend, "Nada"))
  lista_coloca(imports, contrato_intrinseco("frontend_navega", CapFrontend, "Nada"))
  lista_coloca(imports, contrato_intrinseco("frontend_fetch_texto", CapFrontend, "Resultado<Texto, Falha>"))
  lista_coloca(imports, contrato_intrinseco("frontend_injeta_css", CapFrontend, "Nada"))
  lista_coloca(imports, contrato_intrinseco("sys_frontend_empacota", CapFrontend, "Resultado<Bytes, Falha>"))
  lista_coloca(imports, contrato_intrinseco("sys_http_envia", CapRede, "Resultado<Resposta, Falha>"))
  lista_coloca(imports, contrato_intrinseco("sys_tempo_agora", CapTempo, "U64"))
  lista_coloca(imports, contrato_intrinseco("sys_env", CapAmbiente, "Resultado<Texto, Falha>"))

  devolve AlvoWeb {
    nome: "web",
    imports: imports,
    saida: "pacote-web"
  }
fecha
