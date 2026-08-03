# Suite de conformidade Seven

Esta pasta define comportamentos que todo compilador Seven precisa respeitar.

- `valid/`: programas que devem compilar.
- `invalid/`: programas que devem falhar com diagnostico estavel.

Os testes tambem sao escritos em `.sv` para manter a linguagem como centro do projeto.

## Verificacao atual

O release de fundacao roda a conformidade com:

```powershell
.\tools\verify-foundation.ps1
```

O gate exige:

- `valid/`: deve passar.
- `invalid/`: deve falhar com o codigo declarado em `espera:`.

O `bin/seven.exe` de bootstrap ainda e artefato de fundacao; os diagnosticos
estritos sao aplicados pelo checker de desenvolvimento ate a cadeia self-hosted.
