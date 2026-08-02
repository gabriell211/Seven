modulo std.math.core

const Pi: Real64 := 3.141592653589793
const E: Real64 := 2.718281828459045

campo abs(valor: Real64) -> Real64 ::
  veja valor < 0 ::
    devolve -valor
  fecha

  devolve valor
fecha

campo min(a: Real64, b: Real64) -> Real64 ::
  veja a < b ::
    devolve a
  outro ::
    devolve b
  fecha
fecha

campo max(a: Real64, b: Real64) -> Real64 ::
  veja a > b ::
    devolve a
  outro ::
    devolve b
  fecha
fecha

campo raiz(valor: Real64) -> Real64 ::
  devolve sys_raiz(valor)
fecha

campo potencia(base: Real64, expoente: Real64) -> Real64 ::
  devolve sys_potencia(base, expoente)
fecha
