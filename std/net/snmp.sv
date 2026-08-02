modulo std.net.snmp

usa std.base.resultado

selo SnmpVersao ::
  V2c
  V3
fecha

molde SnmpAlvo ::
  host: Texto
  porta: U32
  comunidade: Texto
  versao: SnmpVersao
fecha

molde SnmpValor ::
  oid: Texto
  tipo: Texto
  valor: Texto
fecha

campo snmp_alvo(host: Texto, comunidade: Texto) -> SnmpAlvo ::
  devolve SnmpAlvo {
    host: host,
    porta: 161,
    comunidade: comunidade,
    versao: V2c
  }
fecha

campo snmp_get(alvo: SnmpAlvo, oid: Texto) -> Resultado<SnmpValor, Falha> toca rede ::
  devolve sys_snmp_get(alvo, oid)
fecha

campo snmp_walk(alvo: SnmpAlvo, raiz: Texto) -> Resultado<Lista<SnmpValor>, Falha> toca rede ::
  devolve sys_snmp_walk(alvo, raiz)
fecha
