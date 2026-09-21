# Seven self-hosting cutover

## Objetivo

Definir os gates necessarios para retirar o compilador nativo de transicao do caminho ativo de CI sem enfraquecer as provas de bootstrap, runtime nativo ou releases historicas.

A release `v0.1.0` continua imutavel e pode continuar verificando os artefatos arquivados em `seed/native/final/v1`. O cutover descrito aqui vale para o desenvolvimento atual da Seven e para futuras releases.

## Estado atual

A cadeia corrente do hardening 1.0 prova:

- Seven-0 reconstruido deterministicamente a partir de `bootstrap/seed/v2`;
- fixed point de Seven-0;
- Stage 1 gerado por Seven-0;
- Stage 2 reconstruindo a si proprio byte a byte;
- compilacao e execucao de pacote novo com retorno `42`;
- backend AOT gerando ELF64 e PE32+;
- runtime nativo com memoria, objetos, iteradores, Bytes, console, filesystem e TCP;
- HTTP AOT real validado em Linux x64 e Windows x64;
- CLI portatil montada com Stage 2, launcher e imagens Web geradas pela cadeia corrente;
- `check`, `build`, `run`, `web build` e `doctor` exercitados fora da raiz do repositorio;
- conformance valid/invalid exercitada pela CLI self-hosted;
- workflows correntes de foundation, readiness, Pages, bootstrap e release migrados para a cadeia self-hosted.

O host em `bootstrap/host/v2` permanece como raiz minima auditavel que executa
SVBC e fornece capacidades de plataforma ao bootstrap. Ele nao e o compilador
Seven distribuido: o compilador corrente e `seven.stage2.svbc`, produzido por
Seven-0 -> Stage 1 -> Stage 2 e fechado em fixed point.

Os executaveis arquivados em `seed/native/final/v1` permanecem somente como
evidencia historica para workflows explicitamente versionados de releases 0.x.

## Regra de cutover

O compilador de transicao deixa de ser dependencia do CI ativo quando uma cadeia
produzida pela propria Seven substitui, com cobertura equivalente, todos os usos
de `seed/native/final/v1` fora dos workflows dedicados a releases historicas.

A raiz minima de bootstrap pode continuar contendo um host auditavel em outra
linguagem. Esse host deve apenas executar a representacao bootstrap/SVBC e ligar
capacidades primitivas; ele nao pode fornecer parser, type checker, emissor,
WebAssembly ou logica da toolchain que substitua o compilador Stage 2.

Nao vale substituir uma dependencia por outra prova mais fraca. Cada comando removido do compilador de transicao precisa ter uma prova equivalente ou superior executada pela cadeia self-hosted.

## Gates obrigatorios

### G1 - Bootstrap deterministico

`Seven-0 -> Seven-0 self` precisa permanecer byte a byte identico em Linux e Windows quando aplicavel.

### G2 - Fixed point do compilador

A cadeia deve continuar provando:

```text
Seven-0 -> Stage 1 -> Stage 2 -> Stage 2 self
```

`Stage 2` e `Stage 2 self` precisam permanecer byte a byte identicos.

### G3 - Compilacao do repositorio completo

O compilador self-hosted deve conseguir processar o indice canonico `seven.sources`, incluindo compilador, runtime, std, bootstrap e testes que fazem parte da superficie oficial.

A verificacao nao pode depender do executavel de transicao para validar os mesmos arquivos.

### G4 - Conformance

A suite `conformance/**` precisa ser executada pelo compilador self-hosted:

- casos validos devem ser aceitos;
- casos invalidos devem ser rejeitados;
- diagnosticos relevantes devem permanecer deterministicos quando o contrato exigir.

### G5 - CLI funcional

Os comandos usados no CI atual precisam possuir caminho self-hosted equivalente antes da retirada do seed nativo:

```text
seven --version
seven check <arquivo.sev>
seven build <arquivo.sev> [saida]
seven run <arquivo.sev>
seven web build <arquivo.sev> [diretorio]
seven doctor
```

A implementacao pode evoluir internamente, mas o gate deve testar o contrato publico real, nao apenas chamar funcoes internas do compilador.

### G6 - Backend nativo

A toolchain self-hosted deve gerar os artefatos nativos usados como prova:

- ELF64 valido;
- PE32+ valido;
- execucao com codigo de retorno esperado;
- imports de sistema coerentes;
- nenhuma chamada a lowering de transicao como `sys_native_baixa`.

### G7 - Runtime necessario ao compilador

O caminho nativo precisa cobrir tudo que o proprio compilador usa em execucao:

- texto;
- Bytes;
- objetos e variantes;
- listas e iteradores;
- console;
- filesystem;
- memoria;
- tratamento de falhas e resultados.

Nenhum desses recursos pode depender silenciosamente de um host de transicao quando o gate declarar execucao nativa.

### G8 - Production readiness sem seed de transicao

O workflow de production readiness deve passar sem reconstruir ou executar `seed/native/final/v1`.

Depois desse ponto, uma verificacao automatica deve impedir que workflows ativos voltem a depender desse caminho.

Excecao permanente: workflows destinados exclusivamente a verificar releases historicas imutaveis podem continuar acessando os respectivos artefatos arquivados.

## Ordem de migracao

Estado do cutover neste branch:

1. Stage 2 fixed point preservado;
2. `foundation.yml`, `readiness.yml`, `release.yml`, `pages.yml` e `bootstrap-stage0.yml` usam a acao self-hosted canonica;
3. release historica v0.1.0 foi separada para `historical-v0.1.0-release.yml`;
4. workflows 0.2.1/0.2.2 permanecem historicos e fora do CI corrente;
5. o gate 1.0 rejeita reintroducao do seed de transicao em qualquer workflow corrente;
6. o bundle corrente registra `transition_seed nao` na proveniencia;
7. o E2E `self-hosted-cli.yml` valida a CLI portatil em Linux e Windows;
8. o cutover so e declarado concluido quando todos esses gates estiverem verdes no mesmo commit.

## Criterio de conclusao

O cutover esta concluido quando:

```text
bootstrap auditado
        -> Seven-0
        -> Stage 1
        -> Stage 2 fixed point
        -> compilador/runtime self-hosted
        -> CLI + conformance + AOT + WebAssembly + readiness
```

passar integralmente sem executar o compilador nativo de transicao no caminho de desenvolvimento atual.

Nesse momento, `seed/native/final/v1` deixa de ser parte da fronteira operacional da versao corrente e permanece apenas como evidencia historica das releases que originalmente dependeram dele.
