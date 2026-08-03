modulo seven.compiler.toolchain.library_audit

usa std.base.resultado
usa std.fs.file

molde ModuloBiblioteca ::
  nome: Texto
  caminho: Texto
  area: Texto
fecha

molde RelatorioBiblioteca ::
  modulos: Lista<ModuloBiblioteca>
  faltantes: Lista<Texto>
  conformance: Lista<Texto>
  ok: Bit
fecha

campo audita_biblioteca_padrao() -> RelatorioBiblioteca toca disco ::
  solta modulos := modulos_obrigatorios()
  solta faltantes := lista<Texto>()
  solta conformidade := conformance_libs_obrigatoria()

  para cada modulo em modulos ::
    veja arquivo_existe(modulo.caminho) == nao ::
      lista_coloca(faltantes, modulo.caminho)
    fecha
  fecha

  para cada caso em conformidade ::
    veja arquivo_existe(caso) == nao ::
      lista_coloca(faltantes, caso)
    fecha
  fecha

  devolve RelatorioBiblioteca {
    modulos: modulos,
    faltantes: faltantes,
    conformance: conformidade,
    ok: lista_tamanho(faltantes) == 0
  }
fecha

campo modulos_obrigatorios() -> Lista<ModuloBiblioteca> ::
  solta itens := lista<ModuloBiblioteca>()

  modulo_obrigatorio(itens, "std.base.prelude", "std/base/prelude.sv", "base")
  modulo_obrigatorio(itens, "std.base.resultado", "std/base/resultado.sv", "base")
  modulo_obrigatorio(itens, "std.base.talvez", "std/base/talvez.sv", "base")
  modulo_obrigatorio(itens, "std.base.lista", "std/base/lista.sv", "base")
  modulo_obrigatorio(itens, "std.base.mapa", "std/base/mapa.sv", "base")
  modulo_obrigatorio(itens, "std.base.texto", "std/base/texto.sv", "base")
  modulo_obrigatorio(itens, "std.mem.bytes", "std/mem/bytes.sv", "memoria")
  modulo_obrigatorio(itens, "std.mem.alloc", "std/mem/alloc.sv", "memoria")
  modulo_obrigatorio(itens, "std.mem.ptr", "std/mem/ptr.sv", "memoria")
  modulo_obrigatorio(itens, "std.ffi.c", "std/ffi/c.sv", "ffi")
  modulo_obrigatorio(itens, "std.io.console", "std/io/console.sv", "io")
  modulo_obrigatorio(itens, "std.fs.file", "std/fs/file.sv", "io")
  modulo_obrigatorio(itens, "std.env.runtime", "std/env/runtime.sv", "io")
  modulo_obrigatorio(itens, "std.os.process", "std/os/process.sv", "io")
  modulo_obrigatorio(itens, "std.time.clock", "std/time/clock.sv", "tempo")
  modulo_obrigatorio(itens, "std.async.task", "std/async/task.sv", "concorrencia")
  modulo_obrigatorio(itens, "std.sync.atomic", "std/sync/atomic.sv", "concorrencia")
  modulo_obrigatorio(itens, "std.runtime.event_loop", "std/runtime/event_loop.sv", "concorrencia")
  modulo_obrigatorio(itens, "std.net.tcp", "std/net/tcp.sv", "rede")
  modulo_obrigatorio(itens, "std.net.udp", "std/net/udp.sv", "rede")
  modulo_obrigatorio(itens, "std.net.tls", "std/net/tls.sv", "rede")
  modulo_obrigatorio(itens, "std.net.dns", "std/net/dns.sv", "rede")
  modulo_obrigatorio(itens, "std.net.websocket", "std/net/websocket.sv", "rede")
  modulo_obrigatorio(itens, "std.net.mqtt", "std/net/mqtt.sv", "rede")
  modulo_obrigatorio(itens, "std.web.http", "std/web/http.sv", "web")
  modulo_obrigatorio(itens, "std.web.router", "std/web/router.sv", "web")
  modulo_obrigatorio(itens, "std.web.json", "std/web/json.sv", "web")
  modulo_obrigatorio(itens, "std.web.server", "std/web/server.sv", "web")
  modulo_obrigatorio(itens, "std.web.security", "std/web/security.sv", "web")
  modulo_obrigatorio(itens, "std.db.client", "std/db/client.sv", "dados")
  modulo_obrigatorio(itens, "std.db.query", "std/db/query.sv", "dados")
  modulo_obrigatorio(itens, "std.db.migrate", "std/db/migrate.sv", "dados")
  modulo_obrigatorio(itens, "std.serial.csv", "std/serial/csv.sv", "serial")
  modulo_obrigatorio(itens, "std.serial.xml", "std/serial/xml.sv", "serial")
  modulo_obrigatorio(itens, "std.serial.yaml", "std/serial/yaml.sv", "serial")
  modulo_obrigatorio(itens, "std.serial.toml", "std/serial/toml.sv", "serial")
  modulo_obrigatorio(itens, "std.serial.protobuf", "std/serial/protobuf.sv", "serial")
  modulo_obrigatorio(itens, "std.data.object", "std/data/object.sv", "dados")
  modulo_obrigatorio(itens, "std.system.bits", "std/system/bits.sv", "sistemas")
  modulo_obrigatorio(itens, "std.crypto.hash", "std/crypto/hash.sv", "seguranca")
  modulo_obrigatorio(itens, "std.crypto.random", "std/crypto/random.sv", "seguranca")
  modulo_obrigatorio(itens, "std.auth.jwt", "std/auth/jwt.sv", "seguranca")
  modulo_obrigatorio(itens, "std.frontend.dom", "std/frontend/dom.sv", "frontend")
  modulo_obrigatorio(itens, "std.frontend.css", "std/frontend/css.sv", "frontend")
  modulo_obrigatorio(itens, "std.frontend.bundle", "std/frontend/bundle.sv", "frontend")
  modulo_obrigatorio(itens, "std.log.logger", "std/log/logger.sv", "observabilidade")
  modulo_obrigatorio(itens, "std.observability.metrics", "std/observability/metrics.sv", "observabilidade")
  modulo_obrigatorio(itens, "std.observability.trace", "std/observability/trace.sv", "observabilidade")
  modulo_obrigatorio(itens, "std.test.spec", "std/test/spec.sv", "teste")
  modulo_obrigatorio(itens, "std.ai.model", "std/ai/model.sv", "ia")

  devolve itens
fecha

campo modulo_obrigatorio(itens: Lista<ModuloBiblioteca>, nome: Texto, caminho: Texto, area: Texto) -> Nada ::
  lista_coloca(itens, ModuloBiblioteca {
    nome: nome,
    caminho: caminho,
    area: area
  })
fecha

campo conformance_libs_obrigatoria() -> Lista<Texto> ::
  solta casos := lista<Texto>()

  lista_coloca(casos, "conformance/libs/valid/language_intelligence.sv")
  lista_coloca(casos, "conformance/libs/valid/serialization.sv")
  lista_coloca(casos, "conformance/libs/valid/smtp.sv")
  lista_coloca(casos, "conformance/libs/valid/snmp.sv")
  lista_coloca(casos, "conformance/libs/valid/system_level.sv")
  lista_coloca(casos, "conformance/libs/valid/dynamic_runtime.sv")

  devolve casos
fecha

campo biblioteca_resumo(rel: RelatorioBiblioteca) -> Texto ::
  devolve "modulos: " + texto(lista_tamanho(rel.modulos)) + "\nconformance: " + texto(lista_tamanho(rel.conformance)) + "\nfaltantes: " + texto(lista_tamanho(rel.faltantes)) + "\n"
fecha
