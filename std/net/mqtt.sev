modulo std.net.mqtt

usa std.base.resultado
usa std.mem.bytes

molde MqttCliente ::
  id: U64
fecha

molde MqttConfig ::
  broker: Texto
  cliente_id: Texto
  usuario: Texto
  senha: Texto
fecha

molde MqttMensagem ::
  topico: Texto
  corpo: Bytes
  qos: U32
fecha

campo mqtt_conecta(config: MqttConfig) -> Resultado<MqttCliente, Falha> toca rede ::
  devolve sys_mqtt_conecta(config)
fecha

campo mqtt_publica(cliente: MqttCliente, msg: MqttMensagem) -> Resultado<Nada, Falha> toca rede ::
  devolve sys_mqtt_publica(cliente, msg)
fecha

campo mqtt_assina(cliente: MqttCliente, topico: Texto) -> Resultado<Nada, Falha> toca rede ::
  devolve sys_mqtt_assina(cliente, topico)
fecha

campo mqtt_recebe(cliente: MqttCliente) -> Resultado<MqttMensagem, Falha> toca rede ::
  devolve sys_mqtt_recebe(cliente)
fecha
