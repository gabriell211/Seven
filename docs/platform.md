# Plataforma Seven

## Papel

A biblioteca padrao usa intrinsecos de plataforma com prefixos:

- `sys_*`: sistema operacional, rede, disco, tempo, memoria, banco e bytes.
- `frontend_*`: DOM, eventos, navegacao e fetch no alvo frontend.
- `ai_*` por meio de `sys_ai_*`: provedores de modelo e embeddings.

Esses intrinsecos nao tornam Seven dependente de outra linguagem. Eles sao pontos oficiais que cada alvo Seven precisa implementar.

## Exemplos

```sv
sys_tcp_escuta(host, porta)
sys_arquivo_ler_texto(caminho)
sys_sha256(dados)
sys_smtp_envia(config, mensagem)
sys_snmp_get(alvo, oid)
frontend_monta("#root", html)
frontend_injeta_css("app", css)
```

## Contrato

Todo intrinseco precisa declarar:

- nome estavel;
- tipos de entrada;
- tipo de saida;
- efeitos tocados;
- diagnosticos possiveis;
- comportamento em erro.

## Alvos

- `svbc`: executa intrinsecos por uma maquina Seven.
- `native`: baixa intrinsecos para contratos nativos de sistema.
- `web`: baixa `frontend_*` para APIs do navegador.

## Capacidades

Cada alvo declara capacidades antes da execucao. Um programa que toca `rede`, `disco`, `tempo`, `ambiente`, `frontend` ou `crypto` sem capacidade recebe erro de plataforma.

## Sandbox `svbc`

O alvo `svbc` nasce em sandbox:

- terminal escreve em buffer virtual;
- arquivos usam sistema de arquivos virtual;
- ambiente usa mapa virtual;
- tempo usa relogio virtual;
- rede, frontend, crypto e IA exigem provedor ligado.

Isso permite testar a linguagem sem depender de plataforma externa.

## Kernel interno do `svbc`

Funcoes `sys_svbc_*` sao intrinsecos internos da propria VM para armazenar:

- buffer de terminal;
- arquivos virtuais;
- variaveis de ambiente virtuais;
- argumentos;
- relogio virtual.

Elas nao fazem parte da API publica da biblioteca padrao.

## Seguranca

Intrinsecos que tocam mundo externo precisam de efeito declarado. Codigo puro nao pode chamar intrinsecos de rede, disco, tempo, ambiente ou frontend.
