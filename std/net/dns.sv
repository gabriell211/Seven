modulo std.net.dns

usa std.base.resultado

selo RegistroDns ::
  A(ip: Texto)
  AAAA(ip: Texto)
  CNAME(nome: Texto)
  MX(prioridade: U32, host: Texto)
  TXT(valor: Texto)
fecha

campo dns_resolve(nome: Texto, tipo: Texto) -> Resultado<Lista<RegistroDns>, Falha> toca rede ::
  devolve sys_dns_resolve(nome, tipo)
fecha

campo dns_a(nome: Texto) -> Resultado<Lista<RegistroDns>, Falha> toca rede ::
  devolve dns_resolve(nome, "A")
fecha

campo dns_mx(nome: Texto) -> Resultado<Lista<RegistroDns>, Falha> toca rede ::
  devolve dns_resolve(nome, "MX")
fecha
