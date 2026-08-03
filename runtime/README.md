# Runtime Seven

Este diretorio contem o runtime oficial da Seven escrito em `.sev`.

## Camadas

- `runtime/svbc`: VM e verificador do bytecode Seven completo.
- `runtime/svbc0`: VM minima do bytecode Seven-0.
- `runtime/seed`: executor da fita `SVS0`.
- `runtime/platform`: contrato de intrinsecos `sys_*`.

## Regra

O runtime aqui e fonte Seven. Ele nao introduz nenhuma linguagem hospedeira como dependencia de identidade.

## Estado

Esta e a primeira materializacao do backend de execucao em Seven: carregamento de imagem, verificacao, interpretacao, efeitos e chamadas de plataforma.
