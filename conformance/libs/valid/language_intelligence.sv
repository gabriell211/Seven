modulo conformance.libs.valid.language_intelligence

usa seven.compiler.intelligence.explain
usa seven.compiler.diagnostic

campo cria_explicacao() -> Texto ::
  guarda diag := erro("SV-MEM-LIMITE", "indice fora do limite", "app.sv", 1, 1)
  guarda exp := explica_diagnostico(diag, indice_vazio())
  devolve exp.resumo
fecha
