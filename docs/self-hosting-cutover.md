# Seven self-hosting cutover

## Objetivo

Definir os gates necessarios para retirar o compilador nativo de transicao do caminho ativo de CI sem enfraquecer as provas de bootstrap, runtime nativo ou releases historicas.

A release `v0.1.0` continua imutavel e pode continuar verificando os artefatos arquivados em `seed/native/final/v1`. O cutover descrito aqui vale para o desenvolvimento atual da Seven e para futuras releases.

## Estado atual

A cadeia atual ja prova:

- Seven-0 reconstruido deterministicamente a partir do bootstrap auditado;
- fixed point de Seven-0;
- Stage 1 gerado por Seven-0;
- Stage 2 reconstruindo a si proprio byte a byte;
- compilacao e execucao de pacote novo com retorno `42`;
- backend AOT gerando ELF64 e PE32+;
- runtime nativo com memoria, objetos, iteradores, Bytes, console e filesystem;
- gates separados para WebAssembly, Stage 0, Stage 1, runtime nativo e production readiness.

Ainda existe dependencia do compilador nativo de transicao em partes do CI, principalmente onde a suite usa a CLI completa para `check`, `build`, `run`, `web build` e `doctor`.

## Regra de cutover

O compilador de transicao deixa de ser dependencia do CI ativo somente quando uma cadeia produzida pela propria Seven conseguir substituir, com cobertura equivalente, todos os usos de `seed/native/final/v1` fora dos workflows dedicados a verificacao de releases historicas.

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

1. manter os gates atuais verdes;
2. fazer Stage 2 compilar a superficie canonica completa;
3. mover conformance para o compilador self-hosted;
4. provar a CLI usada pelo readiness;
5. provar `web build` pela mesma cadeia;
6. substituir a execucao do compilador de transicao no readiness;
7. adicionar um gate que rejeite novas referencias a `seed/native/final/v1` em workflows ativos;
8. manter somente os workflows de verificacao de release historica com acesso ao seed arquivado.

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
