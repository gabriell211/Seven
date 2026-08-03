# Inteligencia da linguagem Seven

Seven deve ser inteligente no proprio compilador, nao apenas depender de editor externo.

## Nome da camada

**SIA**: Seven Intelligence Architecture.

## Objetivo

A SIA ajuda o programador em tempo de escrita, compilacao e revisao:

- diagnosticos com explicacao;
- sugestoes de correcao;
- autofix seguro;
- indice semantico do projeto;
- navegacao de simbolos;
- completions;
- refatoracoes;
- analise de seguranca;
- analise de performance;
- explicacao de tipos e efeitos;
- geracao de testes sugeridos;
- suporte oficial a LSP.

## Principio

A inteligencia da Seven nunca deve alterar codigo silenciosamente. Toda correcao precisa ser:

- explicita;
- revisavel;
- deterministica;
- associada a um diagnostico ou intencao clara.

## Camadas

1. `indice`: grafo de modulos, simbolos, tipos e chamadas.
2. `sugestao`: propostas baseadas em diagnosticos.
3. `autofix`: edicoes mecanicas seguras.
4. `explica`: explicacoes humanas para erros e tipos.
5. `risco`: seguranca, performance e efeitos perigosos.
6. `lsp`: ponte para editor.
7. `assist`: interface para assistentes de IA, quando disponivel.

## VS Code

A extensao inicial vive em:

```text
editors/vscode/seven-language
```

Ela registra `.sv`, realce de sintaxe e inicia o LSP de fundacao:

```powershell
.\tools\seven-lsp.ps1
```

Smoke test:

```powershell
.\tools\seven-lsp.ps1 -SelfTest -File .\examples\hello.sv
```

O MVP cobre:

- completions;
- diagnostics;
- document symbols;
- hover;
- comandos VS Code para check, run e debug.

## Inteligencia local

A Seven deve funcionar sem rede:

- completions por indice local;
- erro com ajuda;
- refatoracao basica;
- formatacao;
- grafo de chamadas;
- deteccao de codigo morto.

## Inteligencia com IA

Quando `std.ai` estiver configurado, a SIA pode pedir ajuda de modelos externos para:

- explicar um diagnostico em linguagem natural;
- sugerir refatoracao;
- gerar testes;
- resumir modulo;
- revisar riscos.

Esse uso toca efeito `rede` e deve ser opt-in.
