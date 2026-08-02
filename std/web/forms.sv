modulo std.web.forms

usa std.base.resultado
usa std.web.http

molde CampoFormulario ::
  nome: Texto
  valor: Texto
fecha

molde Formulario ::
  campos: Lista<CampoFormulario>
fecha

campo campo_formulario(nome: Texto, valor: Texto) -> CampoFormulario ::
  devolve CampoFormulario {
    nome: nome,
    valor: valor
  }
fecha

campo formulario_ler(req: Requisicao) -> Resultado<Formulario, Falha> ::
  guarda texto_corpo := bytes_texto(req.corpo)
  devolve form_urlencoded_parse(texto_corpo)
fecha

campo formulario_pega(form: Formulario, nome: Texto) -> Resultado<Texto, Falha> ::
  para cada campo em form.campos ::
    veja campo.nome == nome ::
      devolve Valor(campo.valor)
    fecha
  fecha

  devolve Falha(nova_falha("SV-FORM-AUSENTE", "campo ausente: " + nome))
fecha
