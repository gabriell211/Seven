# Arquitetura do compilador Seven

## Objetivo

O compilador `seven` deve ser previsivel, auditavel e capaz de crescer para projetos grandes.

## Camadas

1. **Fonte**
   - Le arquivos como bytes.
   - Normaliza quebras de linha.
   - Mantem mapa entre byte, linha e coluna.

2. **Varredura**
   - Converte texto em tokens.
   - Nunca decide semantica.
   - Produz diagnosticos recuperaveis.

3. **Montagem**
   - Converte tokens em AST.
   - Preserva spans de origem.
   - Evita executar qualquer codigo.

4. **Ligacao**
   - Resolve modulos, imports e pacotes.
   - Cria tabela de simbolos.
   - Detecta ciclos invalidos.

5. **Medicao**
   - Infere e confere tipos.
   - Confere efeitos.
   - Confere posse, regioes e memoria.
   - Garante retorno em todos os caminhos.

6. **IR**
   - Representacao intermediaria tipada.
   - Independente de plataforma.
   - Preparada para otimizacao incremental.

7. **Otimizacao**
   - Dobra constantes.
   - Remove codigo morto.
   - Simplifica fluxo.
   - Especializa genericos.

8. **Inteligencia**
   - Cria indice semantico.
   - Gera sugestoes e autofixes.
   - Explica diagnosticos.
   - Detecta riscos de seguranca e performance.
   - Alimenta LSP e ferramentas.

9. **Emissao**
   - `SVBC`: bytecode Seven.
   - `obj`: objeto por alvo.
   - `bin`: executavel final.

## Diagnosticos

Todo erro deve ter:

- Codigo estavel.
- Mensagem humana.
- Arquivo.
- Linha e coluna.
- Trecho de origem.
- Sugestao quando possivel.

## Incrementalidade

O compilador deve usar hashes por arquivo, modulo e assinatura publica. Uma alteracao interna nao deve recompilar o mundo inteiro.

## Determinismo

Mesma entrada, mesmo alvo e mesmas opcoes devem gerar a mesma saida.

## Inteligencia da linguagem

A camada SIA vive em `compiler/intelligence`. Ela nao muda semantica do programa; apenas observa o resultado da compilacao para sugerir, explicar e guiar ferramentas.
