modulo std.serial.xml

usa std.base.resultado

molde XmlAtributo ::
  nome: Texto
  valor: Texto
fecha

molde XmlNo ::
  nome: Texto
  atributos: Lista<XmlAtributo>
  texto: Texto
  filhos: Lista<XmlNo>
fecha

campo xml_parse(texto_xml: Texto) -> Resultado<XmlNo, Falha> ::
  devolve sys_xml_parse(texto_xml)
fecha

campo xml_codifica(no: XmlNo) -> Texto ::
  devolve sys_xml_codifica(no)
fecha
