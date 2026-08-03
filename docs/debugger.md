# Debugger Seven

O debugger inicial da Seven usa trace deterministico no runner de fundacao:

```powershell
.\tools\seven-dev.ps1 debug .\examples\control.sv --break 8 --locals
```

Ele imprime a entrada, cada comando executado pelo subconjunto suportado pela VM
de desenvolvimento, paradas por linha e locals quando solicitado.

O contrato self-hosted fica em `compiler/debugger.sv` e define:

- breakpoints por arquivo/linha;
- frames de chamada;
- eventos de inicio, passo, parada e saida.

O proximo passo para produto e expor isso como Debug Adapter Protocol para VS
Code, reaproveitando a extensao em `editors/vscode/seven-language`.
