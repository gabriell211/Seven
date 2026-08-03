modulo examples.snmp_monitor.main

usa std.env.runtime
usa std.net.snmp

campo inicio() -> Num toca rede, ambiente, terminal ::
  guarda host := env_ou("SNMP_HOST", "127.0.0.1")
  guarda comunidade := env_ou("SNMP_COMMUNITY", "public")
  guarda alvo := snmp_alvo(host, comunidade)
  guarda sysname := snmp_get(alvo, "1.3.6.1.2.1.1.5.0")

  veja sysname e Falha ::
    diga "falha lendo SNMP"
    devolve 1
  fecha

  diga "dispositivo: " + sysname.valor.valor
  devolve 0
fecha
