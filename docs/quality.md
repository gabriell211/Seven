# Barra de qualidade Seven

## Compilador

- Deterministico.
- Mensagens de erro estaveis.
- Sem panico silencioso.
- Testado por snapshots de diagnostico.
- Capaz de compilar a si mesmo.

## Linguagem

- Sintaxe pequena.
- Sem comportamento indefinido por padrao.
- Baixo nivel isolado por `zona crua`.
- Tipos fortes.
- Efeitos explicitos.

## Biblioteca padrao

- Minima no nucleo.
- Modulos pequenos.
- APIs previsiveis.
- Sem dependencias ocultas.

## Ferramentas

- Formatador oficial.
- Verificador rapido.
- Suite de conformidade.
- Documentacao gerada a partir de codigo.

## Performance

- Abstracoes sem alocacao escondida quando possivel.
- Genericos especializados nos caminhos quentes.
- Diagnosticos nao devem degradar builds incrementais grandes.

## Seguranca

- Leitura e escrita fora de limite sao erros definidos.
- Codigo cru e explicito.
- Efeitos revelam interacao externa.
- Pacotes travam versoes e hashes.
