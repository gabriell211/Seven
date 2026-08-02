# Sistema de efeitos Seven

## Objetivo

Efeitos tornam visivel quando um campo interage com o mundo.

Campo sem `toca` e puro por padrao.

```sv
campo soma(a: U32, b: U32) -> U32 ::
  devolve a + b
fecha
```

Campo com efeito:

```sv
campo principal() -> Num toca terminal, disco ::
  diga "ok"
  devolve 0
fecha
```

## Efeitos base

- `terminal`: entrada ou saida no console.
- `disco`: leitura ou escrita de arquivos.
- `rede`: sockets, HTTP e DNS.
- `tempo`: relogio, timers e espera.
- `ambiente`: variaveis de ambiente e argumentos.
- `cru`: memoria crua, chamada ABI e instrucao especifica de alvo.
- `frontend`: DOM, navegador, armazenamento local e eventos de interface.
- `teste`: ambiente controlado de teste.

## Propagacao

Se `A` chama `B`, os efeitos de `B` precisam aparecer em `A`, exceto quando forem tratados por uma abstracao que os contenha.

## Testes

Testes podem substituir efeitos por ambientes controlados.

```sv
campo teste_saida() -> Nada toca teste ::
  guarda terminal := terminal_falso()
  principal_com_terminal(terminal)
fecha
```

## Beneficios

- Funcoes puras sao mais faceis de testar.
- Codigo de baixo nivel fica localizado.
- Ferramentas conseguem mostrar impacto operacional.
- Builds de alvo restrito podem recusar efeitos indisponiveis.
