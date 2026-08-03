# Seven Market Readiness

## Objetivo

Seven deve atender mercados diferentes sem virar uma camada por cima de outra
linguagem. O contrato tecnico e simples:

- o compilador oficial vive em Seven;
- o runtime oficial vive em Seven;
- a biblioteca padrao oficial vive em Seven;
- o bootstrap existe apenas para nascimento auditavel;
- FFI, WASM, ABI C, JavaScript host, JVM, CLR, POSIX e Win32 sao alvos ou
  pontes explicitas, nunca identidade tecnica da linguagem.

Isso nao impede interoperabilidade. Impede dependencia estrutural. Seven pode
chamar C, exportar WASM, gerar binarios nativos ou rodar no navegador, mas a
semantica, a toolchain e a experiencia principal pertencem a Seven.

## Filosofia

Seven resolve o problema de equipes que precisam cobrir baixo nivel, backend,
frontend, automacao, sistemas distribuidos e software corporativo com uma
linguagem coerente, segura e produtiva.

Publico-alvo:

- desenvolvedores de sistemas que precisam de controle de memoria e ABI;
- equipes de backend e cloud que precisam de concorrencia, rede e observabilidade;
- equipes full stack que querem frontend e backend na mesma linguagem;
- empresas que exigem auditoria, reproducibilidade, seguranca e suporte longo;
- pesquisadores e criadores de ferramentas que precisam de compilador hackeavel.

Diferenciais:

- self-hosting como requisito de producao, nao detalhe simbolico;
- efeitos explicitos para IO, rede, tempo, processo, unsafe e concorrencia;
- `zona crua` isolada para baixo nivel sem contaminar codigo comum;
- biblioteca padrao orientada a mercados reais desde o desenho inicial;
- diagnosticos, LSP, formatter, test runner e pacote como parte da linguagem;
- alvo `svbc` para portabilidade e alvos nativos para performance.

Comparacao direta:

- contra C/C++: Seven busca controle semelhante com memoria segura por padrao;
- contra Rust: Seven busca seguranca forte com sintaxe mais direta e efeitos
  declarados como contrato de arquitetura;
- contra Go: Seven busca simplicidade operacional com tipos, generics,
  ownership e baixo nivel mais fortes;
- contra Kotlin/Swift/C#: Seven busca produtividade moderna sem depender de uma
  VM externa como identidade obrigatoria;
- contra TypeScript/JavaScript: Seven busca full stack com runtime proprio,
  tipos reais de compilacao e escape para baixo nivel.

## Mercados-alvo

| Mercado | Necessario em Seven | Gate minimo |
| --- | --- | --- |
| CLI e automacao | args, env, fs, processo, logs, pacotes | `seven run`, `seven test`, binario nativo |
| Backend e APIs | HTTP, router, JSON, TLS, async, logs, metrics | conformance web + carga local |
| Frontend web | DOM, CSS tipado, assets, bundle, alvo `web` | app exemplo gerado e testado |
| Full stack | backend, frontend, sessoes, banco, migracoes | exemplo completo executavel |
| Sistemas | memoria crua isolada, ABI, threads, atomicos, FFI | testes de bounds, races e ABI |
| Cloud e DevOps | config, secrets, containers, health, tracing | build reprodutivel + SBOM |
| Dados e IA | serializacao, streams, embeddings, clientes de modelo | exemplos com cache e limites |
| Financeiro | decimal, tempo, auditoria, logs imutaveis | testes deterministas e snapshots |
| Saude e governo | seguranca, privacidade, trilha de auditoria | politica de suporte + hardening |
| IoT e embarcado | alvos pequenos, alloc opcional, IO crua | perfil `no_gc`/`no_std` |
| Desktop e mobile | GUI, pacotes, assets, assinaturas | alvo nativo por plataforma |
| Jogos e midia | loop, audio, grafico, SIMD, assets | runtime de frame e profiler |

Seven nao precisa entregar todos os mercados no 0.1.x. Precisa ter arquitetura,
gates e prioridade clara para nao crescer como colecao solta de wrappers.

## Arquitetura obrigatoria

Fluxo de compilacao:

```text
Fonte .sv
  -> Lexer
  -> Parser
  -> AST
  -> Resolucao de modulos
  -> Analise semantica
  -> Type checker
  -> Effect checker
  -> Ownership e memoria
  -> IR tipada
  -> Otimizador
  -> Backend SVBC / WASM / nativo
  -> Runtime Seven
  -> Artefato verificavel
```

Responsabilidades:

- Lexer: bytes, tokens, spans e recuperacao lexica.
- Parser: AST completa sem executar codigo.
- AST: estrutura semantica preservando spans.
- IR: representacao tipada e independente de alvo.
- Semantic analyzer: nomes, modulos, imports, efeitos e visibilidade.
- Type checker: inferencia local, generics, unions, opcionais e traits.
- Optimizer: constant folding, DCE, inlining, escape analysis e especializacao.
- Backend: `svbc` primeiro, WASM e nativo depois.
- Runtime: VM, scheduler, memoria, IO, syscalls e sandbox.
- Memory manager: seguro por padrao, regioes/ownership para performance e
  `zona crua` para controle explicito.

## Sistema de tipos necessario

Requisitos para competir em mercados exigentes:

- inferencia local previsivel;
- tipos opcionais sem `null` implicito;
- `Resultado<T, E>` como erro comum;
- union types fechados;
- generics monomorfizados onde performance importar;
- traits para contratos de comportamento;
- interfaces para fronteiras dinamicas quando necessario;
- mutabilidade explicita;
- ownership e borrow checking nas regioes criticas;
- efeito no tipo de funcao para IO, rede, tempo, unsafe, async e processo.

Impacto:

- desempenho: generics especializados reduzem dispatch e boxing;
- seguranca: ausencia de `null` implicito reduz classe inteira de falhas;
- escala: efeitos tornam dependencias operacionais visiveis em revisao.

Limites:

- borrow checking completo aumenta complexidade de compilador;
- union types exigem bom pattern matching para nao virar casts manuais;
- efeitos precisam de ergonomia para nao poluir funcoes simples.

## Runtime e memoria

Perfis obrigatorios:

- `managed`: GC incremental/regional para apps, APIs e ferramentas.
- `owned`: ownership/regioes para sistemas e workloads de baixa latencia.
- `raw`: `zona crua` auditavel para ABI, drivers, kernel, embedded e SIMD.
- `no_std`: subconjunto sem heap global para embarcado e bootstrapping.

Scheduler:

- tarefas estruturadas;
- async/await sem data race por padrao;
- threads nativas para CPU;
- actors opcionais para isolamento;
- cancelamento e timeout como contrato de biblioteca.

## Biblioteca padrao de mercado

Nucleo minimo:

- base, texto, lista, mapa, resultado, talvez;
- fs, env, processo, tempo, console;
- bytes, memoria, atomicos e locks;
- net TCP/UDP/TLS/DNS/WebSocket/MQTT;
- web HTTP/router/JSON/cookies/sessoes/security/static;
- db query/migrate/client;
- serial CSV/XML/YAML/TOML/Protobuf;
- crypto hash/random/token;
- observability logs/metrics/traces;
- test/spec/bench;
- frontend DOM/CSS/router/state/assets/bundle;
- package resolver, lockfile e cache offline.

Regra de independencia:

- modulos oficiais podem usar intrinsecos de plataforma Seven;
- modulos oficiais nao devem ser implementados como shell permanente para outra
  linguagem;
- adaptadores externos ficam em `std.ffi`, `std.platform` ou pacote separado,
  com efeito explicito.

## Ecossistema obrigatorio

CLI esperada:

```text
seven new
seven init
seven check
seven build
seven run
seven test
seven bench
seven fmt
seven lint
seven doc
seven repl
seven pkg add
seven pkg remove
seven pkg verify
seven pkg publish
seven target list
seven web build
seven serve
seven debug
seven profile
seven doctor
```

Ferramentas:

- formatter estavel;
- linter com regras versionadas;
- test runner com snapshots;
- doc generator;
- REPL;
- debugger;
- profiler;
- LSP oficial;
- gerenciador de pacotes com lockfile, hashes, cache offline e assinatura;
- CI oficial com matrix de plataformas.

## Gates de prontidao

Fundacao publica:

- `tools/verify-foundation.ps1` retorna `falhas: 0`;
- fonte do nucleo em `compiler`, `compiler0`, `runtime`, `std` e `bootstrap`
  nao contem codigo-fonte hospedeiro como C, C++, Rust, Go, Python,
  JavaScript, TypeScript, Zig, Java, Kotlin, Swift, C# ou scripts shell;
- exemplos principais passam em `check`, `build` e `run`.

Beta tecnico:

- `seven0` gera `seven` a partir do seed;
- `seven` compila `compiler/seven.sv`;
- conformance valida/invalida cobre linguagem, runtime, memoria, efeitos,
  pacotes, FFI e web;
- LSP e formatter usam o mesmo parser oficial.

Producao 1.0:

- cadeia `seed -> seven0 -> seven -> seven.self` passa com saida equivalente;
- releases sao reproduziveis, assinados e acompanhados de SBOM;
- pacote verifica hash e assinatura por padrao;
- modo offline funciona para builds travados;
- runtime tem testes de sandbox, memoria e concorrencia;
- compatibilidade semantica tem politica publica.

Enterprise:

- matriz Windows, Linux e macOS;
- CVE/advisory flow exercitado;
- suporte LTS definido;
- auditoria de dependencias e supply chain;
- profiler e debugger suficientes para incidentes de producao;
- hardening de rede, TLS, secrets e logs.

## Exemplos exigidos

Antes de chamar Seven de pronta para qualquer mercado, o repositorio deve ter
exemplos executaveis para:

- Hello World;
- CLI com argumentos;
- CRUD com banco;
- API REST;
- servidor estatico;
- frontend com estado;
- full stack com sessao;
- threads;
- async;
- sockets TCP/UDP;
- TLS;
- filas;
- cache;
- email;
- observabilidade;
- WebAssembly;
- FFI C;
- biblioteca publicada;
- projeto completo com testes.

## Implementacao recomendada

Curto prazo:

- manter `bin/seven.exe` e PowerShell apenas como ponte de verificacao;
- manter a superficie oficial de CLI, instalador, formatter, test runner, LSP
  e release em `compiler/toolchain/*.sv`;
- usar `seven verify foundation` como substituto oficial do verificador
  PowerShell;
- mover cada gate de `tools/seven-dev.ps1` para `compiler/` e `runtime/`;
- garantir que todo novo modulo oficial tenha fonte `.sv` e teste de
  conformidade.

Medio prazo:

- materializar `seed/genesis.svhex` em `build/seven0.svbc`;
- executar `compiler0/seven0.sv` na VM Seven-0;
- emitir `compiler/seven.sv` como `seven.svbc`;
- comparar builds repetidos por hash estrutural.

Longo prazo:

- backend nativo via LLVM, Cranelift ou backend proprio;
- alvo WASM sem depender de JavaScript para semantica;
- runtime por plataforma com intrinsecos Seven;
- registry oficial com assinatura e espelhos.

Rust, C++, Zig, LLVM, Cranelift e WebAssembly podem ser usados como referencia,
ferramenta temporaria ou backend. Eles nao devem ser o lugar onde a linguagem
oficial vive.

## Otimizacoes exigidas

- inlining controlado por custo;
- dead code elimination;
- constant folding;
- loop unrolling seletivo;
- escape analysis;
- especializacao de generics;
- SIMD por intrinsecos tipados;
- alocacao elidida em caminhos quentes;
- cache de compilacao incremental;
- layout de dados orientado a cache.

## Seguranca

Seven deve bloquear por padrao:

- buffer overflow;
- use-after-free;
- double free;
- data race;
- null dereference;
- acesso fora de limites;
- conversao numerica silenciosa perigosa;
- importacao de pacote sem hash;
- FFI sem efeito/contrato explicito.

`zona crua` existe para codigo que precisa quebrar abstracoes, mas deve deixar
rastro no tipo, no efeito, no diagnostico e na revisao.

## Limites atuais

Seven 0.1.x ainda nao e producao universal. O repositorio ja contem a fundacao,
mas a prontidao real depende de fechar self-hosting, runtime, conformance,
pacotes assinados, alvos nativos e toolchain oficial sem ponte permanente.
