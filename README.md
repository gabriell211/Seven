![Seven](brand/seven-logo.svg)

# Seven `.sev`

Seven e uma linguagem de programacao propria, criada para ir do baixo nivel ao alto nivel sem depender de uma linguagem hospedeira como identidade tecnica.

Criador: **Gabriel Barcelos** (`gabriell211`).

A extensao oficial e `.sev`.
O compilador oficial se chama `seven`.
A fonte do compilador oficial vive em Seven.

## Visao

Seven deve ser completa, genial e competitiva por desenho: simples para comecar, profunda para sistemas grandes, precisa para baixo nivel e elegante para codigo humano.

## Norte tecnico

Seven existe para competir com linguagens modernas em quatro frentes:

- **Controle**: memoria, layout, bytes, ABI e binarios previsiveis.
- **Seguranca**: tipos fortes, erros explicitos, efeitos declarados e limites verificados.
- **Escala**: modulos, pacotes, compilacao incremental e ferramentas de projeto.
- **Produtividade**: sintaxe limpa, mensagens de erro boas, biblioteca padrao coerente.

## Exemplo

```sv
modulo app

campo inicio() -> Num toca terminal ::
  guarda nome: Texto := "Seven"
  diga "linguagem: " + nome
  devolve 0
fecha
```

## Estrutura do repositorio

- `docs/language.md`: especificacao central da linguagem.
- `docs/identity.md`: identidade, autoria e principios da Seven.
- `docs/references.md`: referencias oficiais, citacao e atribuicao.
- `docs/community-growth.md`: plano publico de comunidade, reputacao e contribuicoes legitimas.
- `docs/grammar.svbnf`: gramatica inicial.
- `docs/compiler-architecture.md`: arquitetura do compilador.
- `docs/type-system.md`: tipos, genericos e contratos.
- `docs/memory-model.md`: memoria segura, memoria crua e posse.
- `docs/effects.md`: sistema de efeitos.
- `docs/fullstack.md`: APIs oficiais para frontend, backend e fullstack.
- `docs/frontend.md`: frontend, CSS, temas, assets e bundle.
- `docs/intelligence.md`: arquitetura de inteligencia da linguagem.
- `docs/platform.md`: intrinsecos de plataforma Seven.
- `docs/runtime.md`: VM, runtime e execucao de bytecode.
- `docs/debugger.md`: debugger inicial e contrato de breakpoints.
- `docs/toolchain.md`: CLI, instalador, formatter, test runner, LSP e release
  oficiais em Seven.
- `docs/targets.md`: alvos `svbc`, `web` e nativo.
- `docs/readiness.md`: estado de prontidao do release.
- `docs/enterprise-readiness.md`: matriz de adocao corporativa, riscos e gates.
- `docs/bytecode.md`: formato Seven Bytecode (`SVBC`).
- `docs/package-system.md`: pacotes e resolucao de modulos.
- `docs/c-interop.md`: interoperabilidade C/C++ por ABI explicita.
- `editors/vscode/seven-language`: recursos estaticos de editor para `.sv`,
  sem runtime JavaScript/TypeScript no nucleo oficial.
- `docs/standard-library.md`: mapa da biblioteca padrao.
- `docs/diagnostics.md`: codigos de erro estaveis.
- `docs/roadmap.md`: caminho ate self-hosting e binarios.
- `docs/market-readiness.md`: contrato para tornar Seven pronta para mercados
  reais sem depender de outra linguagem como identidade tecnica.
- `docs/c-js-parity.md`: matriz de capacidades para chegar ao nivel de C e
  JavaScript sem copiar suas dependencias.
- `docs/bridge-retirement.md`: plano para aposentar PowerShell e bootstrap
  binario do caminho oficial.
- `docs/production-gate.md`: checklist dos 10 pontos para producao self-hosted.
- `std/`: biblioteca padrao escrita em Seven.
- `compiler/`: compilador Seven escrito em Seven.
- `compiler/toolchain/`: toolchain oficial Seven-native.
- `compiler/toolchain/launcher.sv`: contrato do launcher e manifesto
  `seven.launcher` usado por instalador/release.
- `compiler0/`: compilador minimo Seven-0 usado no bootstrap.
- `runtime/`: VM Seven, VM Seven-0 e executor do seed.
- `bin/`: executavel de bootstrap e checksums.
- `brand/`: logo, marca, favicon e icone oficial.
- `CITATION.cff`: citacao oficial da linguagem.
- `NOTICE`: aviso de autoria para fonte, binarios e releases.
- `examples/`: programas de exemplo `.sv`.
- `conformance/`: suite de conformidade da linguagem.
- `seed/`: especificacao do seed minimo auditavel.
- `bootstrap/`: estagios planejados de nascimento.
- `build/`: imagens hexadecimais auditaveis de bootstrap.

## Contrato do projeto

- A linguagem oficial e Seven.
- O criador da Seven e Gabriel Barcelos.
- O perfil oficial do criador e `gabriell211`.
- O compilador oficial e Seven.
- O seed inicial e apenas uma centelha auditavel para gerar o primeiro `seven`.
- Depois do bootstrap, Seven compila Seven.

## Comandos planejados

```text
seven build
seven run examples/hello.sv
seven check
seven fmt
seven test
seven doc
seven install
seven lsp
seven release
seven verify foundation
seven verify bootstrap
seven verify production
seven web build examples/frontend-counter
seven serve examples/api-server
```

## Verificacao de fundacao

O release de fundacao pode ser validado no Windows com:

```powershell
.\tools\verify-foundation.ps1
```

Esse gate executa o `bin/seven.exe`, valida `check/build/run` em smoke tests,
confere envelopes `SVBC`, percorre a conformidade valida e exige diagnosticos
estaveis para a conformidade invalida por meio do checker de desenvolvimento.

Tambem valida pacote/lock, LSP e FFI:

```powershell
.\tools\seven-dev.ps1 pkg add std.http 1.0.0 registry
.\tools\seven-lsp.ps1 -SelfTest -File .\examples\hello.sv
.\tools\seven-dev.ps1 ffi header .\examples\interop-c\main.sv .\build\interop-c.h
```

## Adocao por empresas

Seven 0.1.0 e uma fundacao publica verificavel para avaliacao, pesquisa,
pilotos internos e contribuicoes tecnicas. Para uso corporativo, comece por:

- `docs/market-readiness.md`: autonomia tecnica, mercados-alvo e gates 1.0;
- `docs/enterprise-readiness.md`: matriz de prontidao, riscos e gates;
- `SECURITY.md`: politica de seguranca e reporte privado;
- `SUPPORT.md`: escopo de suporte da fundacao;
- `.\tools\verify-foundation.ps1`: gate local e de CI.

Seven so deve ser chamado de compilador de producao depois que a cadeia abaixo
passar com saida deterministica equivalente:

```text
seed -> seven0 -> seven -> seven.self
```

## Prontidao para qualquer mercado

Seven deve crescer como uma linguagem completa, nao como wrapper permanente de
outra linguagem. A regra do projeto e:

- compilador oficial em Seven;
- runtime oficial em Seven;
- biblioteca padrao oficial em Seven;
- bootstrap apenas como nascimento auditavel;
- interoperabilidade por FFI, WASM, ABI C, Win32/POSIX e navegadores como ponte
  explicita, nao como dependencia estrutural.

O contrato de mercado esta em `docs/market-readiness.md` e cobre CLI, backend,
frontend, full stack, sistemas, cloud, dados, IA, financeiro, governo, saude,
IoT, desktop, mobile e jogos.

## Full Stack Kit

Seven agora define APIs oficiais para:

- backend HTTP;
- roteamento;
- JSON;
- HTML;
- formularios;
- cookies e sessoes;
- banco de dados;
- migracoes;
- crypto;
- arquivos;
- ambiente;
- logs;
- async;
- frontend DOM;
- estado de UI;
- cliente HTTP no navegador.

Os exemplos oficiais ficam em:

- `examples/api-server`
- `examples/frontend-counter`
- `examples/fullstack-blog`
- `examples/auth-system`
- `examples/mail-smtp`
- `examples/snmp-monitor`
- `examples/worker-queue`
- `examples/ai-assistant`

## Estado atual

Esta pasta contem a fundacao profissional da linguagem: especificacao, arquitetura, gramatica, standard library fullstack inicial, seed Seven-0, compilador minimo `compiler0`, fonte do compilador completo em `.sv`, exemplos de frontend/backend e conformidade.

O proximo marco e materializar `seed/genesis.svhex` no primeiro alvo fisico, gerar `build/seven0.svbc` e ligar os intrinsecos de plataforma definidos em `docs/platform.md`.

O bootstrap Windows continua sendo artefato de fundacao; a integracao final e
levar o checker, a VM, o gerenciador de pacotes, o LSP e a FFI de
`tools/seven-dev.ps1` para o `seven` self-hosted.
