# Interoperabilidade C e C++

Seven usa uma fronteira explicita para codigo externo.

```sv
usa std.ffi.c

extern c campo c_puts(texto: Ptr<CChar>) -> I32 liga "puts"
extern cpp campo cpp_version() -> U32 liga "seven_cpp_version"
```

## Regra

- `extern c` usa ABI C estavel.
- `extern cpp` exige simbolo ligado por nome explicito e deve preferir shim C++
  com `extern "C"` quando o compilador C++ puder aplicar name mangling.
- Toda conversao de `Texto`, `Bytes` ou ponteiro toca efeito `cru`.
- Chamadas externas nao podem atravessar API publica sem tipos, efeito e contrato.

## Header C

Durante o bootstrap de fundacao, headers podem ser gerados por:

```powershell
.\tools\seven-dev.ps1 ffi header .\examples\interop-c\main.sev .\build\interop-c.h
.\tools\seven-dev.ps1 ffi manifest .\examples\interop-c\main.sev .\build\interop-c.json
```

O header gerado inclui guarda, tipos padrao e bloco `extern "C"` para consumo por
C++. O manifesto registra ABI, nome Seven, simbolo externo, retorno e parametros
para auditoria do linker.

## Proximo gate nativo

O backend nativo deve ligar:

```text
Seven extern -> simbolo C ABI -> objeto -> binario
```

Antes disso, `extern` e um contrato verificado e documentado, nao uma chamada
nativa executada pelo bootstrap Windows.
