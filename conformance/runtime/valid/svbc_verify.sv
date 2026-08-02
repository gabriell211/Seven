modulo conformance.runtime.valid.svbc_verify

usa seven.runtime.svbc.image
usa seven.runtime.svbc.opcode
usa seven.runtime.svbc.verifier

campo inicio() -> Num ::
  guarda img := imagem_vazia()
  lista_coloca(img.campos, CampoImagem {
    nome: "inicio",
    entrada: 0,
    locais: 0,
    parametros: 0,
    efeitos: lista<Texto>()
  })

  lista_coloca(img.codigo, Instrucao {
    opcode: Pare,
    a: 0,
    b: 0,
    c: 0,
    ip: 0
  })

  guarda r := verifica_svbc(img)

  veja r.ok ::
    devolve 0
  outro ::
    devolve 1
  fecha
fecha
