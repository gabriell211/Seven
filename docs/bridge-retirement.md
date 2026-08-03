# Bridge Retirement

## Objetivo

Remover PowerShell e o binario de bootstrap do caminho oficial da Seven sem
perder verificabilidade durante a transicao.

## Estado atual

Ainda existem pontes:

- `tools/verify-foundation.ps1`;
- `tools/seven-dev.ps1`;
- `tools/seven-lsp.ps1`;
- `tools/Seven.Foundation.psm1`;
- `bin/seven.exe`.

Essas pontes validam a fundacao no Windows, mas nao sao a identidade tecnica da
linguagem. O caminho oficial passa a ser a fonte Seven-native:

```text
compiler/toolchain/verify.sev
compiler/toolchain/bootstrap_chain.sev
compiler/toolchain/cli.sev
compiler/toolchain/installer.sev
compiler/toolchain/lsp_server.sev
runtime/svbc/command_runner.sev
runtime/host/seven.sev
runtime/launcher/seven.sev
```

## Comando substituto

O substituto oficial do verificador PowerShell e:

```text
seven verify foundation
```

O substituto oficial da auditoria de bootstrap e:

```text
seven verify bootstrap
```

O substituto oficial do checklist de producao e:

```text
seven verify production
```

## Fases

### Fase A: superficie nativa

- Criar `seven verify foundation` em Seven.
- Criar `seven verify bootstrap` em Seven.
- Fazer `compiler/seven.sev` delegar para a CLI Seven-native.
- Manter `tools/verify-foundation.ps1` apenas como executor legado de CI.

### Fase B: execucao self-hosted

- `seed/genesis.svhex` gera `build/seven0.svbc`.
- `seven0` gera `build/seven.svbc`.
- `seven` gera `build/seven.self.svbc`.
- `seven verify foundation` roda pela VM/runtime Seven.
- `seven verify bootstrap` roda pela VM/runtime Seven.
- `seven verify production` roda pela VM/runtime Seven.
- `build/seven.svbc` despacha comandos por `CHAMA` e `SALTA_SE_NAO`, sem emitir
  o syscall agregado `seven_cli`.
- `runtime/svbc/command_runner.sev` executa `build/seven.svbc verify foundation`
  `build/seven.svbc verify bootstrap` e `build/seven.svbc verify production`.
- `runtime/host/seven.sev` define o host Seven-native que carrega
  `build/seven.launcher.svbc`.
- `runtime/launcher/seven.sev` define o launcher Seven-native que substitui a
  autoridade do `bin/seven.exe`.
- `compiler/toolchain/native_host.sev` define o manifesto `seven.host` e o
  bytecode `build/seven.host.svbc`, validados pelo gate de producao e
  consumidos por instalador/release.
- `compiler/toolchain/launcher.sev` define o manifesto `seven.launcher` e o
  bytecode `build/seven.launcher.svbc`, validados pelo gate de producao e
  consumidos por instalador/release.
- `runtime/svbc/runner.sev` rejeita envelopes `seven-dev-vm-v1` no caminho
  produtivo.

### Fase C: remocao do caminho legado

- CI chama `build/seven.svbc verify foundation` e
  `build/seven.svbc verify bootstrap`, `build/seven.launcher.svbc verify bootstrap`,
  `build/seven.host.svbc verify bootstrap` e `build/seven.svbc verify production`
  via runtime Seven ou o binario self-hosted equivalente.
- `tools/*.ps1` saem do gate obrigatorio.
- `bin/seven.exe` deixa de ser artefato autoritativo.
- Releases passam a publicar artefatos gerados pela cadeia self-hosted.

## Regra

Enquanto a Fase B nao estiver completa, as pontes podem existir para auditoria.
Elas nao podem receber novas responsabilidades de produto que nao tenham fonte
correspondente em Seven.

## Linha de troca do CI

Hoje:

```text
tools/seven-dev.ps1 run build/seven.svbc verify foundation
tools/seven-dev.ps1 run build/seven.svbc verify bootstrap
tools/seven-dev.ps1 run build/seven.launcher.svbc verify bootstrap
tools/seven-dev.ps1 run build/seven.host.svbc verify bootstrap
tools/seven-dev.ps1 run build/seven.svbc verify production
pwsh tools/verify-foundation.ps1
```

Transicao:

```text
tools/seven-dev.ps1 run build/seven.svbc verify foundation
tools/seven-dev.ps1 run build/seven.svbc verify bootstrap
tools/seven-dev.ps1 run build/seven.launcher.svbc verify bootstrap
tools/seven-dev.ps1 run build/seven.host.svbc verify bootstrap
tools/seven-dev.ps1 run build/seven.svbc verify production
pwsh tools/verify-foundation.ps1
```

Destino:

```text
build/seven.svbc verify foundation
build/seven.svbc verify bootstrap
build/seven.launcher.svbc verify bootstrap
build/seven.host.svbc verify bootstrap
build/seven.svbc verify production
```
