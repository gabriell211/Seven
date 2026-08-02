# Sistema de pacotes Seven

## Manifesto

Todo projeto pode declarar `seven.pkg`.

```text
pacote app
versao 0.1.0
criador Gabriel Barcelos
perfil gabriel211
entrada app.inicio
alvo svbc
```

Campos oficiais iniciais:

- `pacote`: nome do pacote.
- `versao`: versao semantica.
- `criador`: pessoa ou grupo criador do pacote.
- `perfil`: identificador publico do criador ou mantenedor.
- `entrada`: campo inicial.
- `alvo`: formato principal de saida.
- `fonte`: raiz de codigo fonte.
- `exemplo`: raiz de exemplos.
- `conformidade`: raiz de testes de conformidade.
- `seed`: imagem inicial de bootstrap, quando existir.

Alvos oficiais iniciais:

- `svbc`: Seven Bytecode.
- `web`: pacote frontend para navegador.
- `bin`: binario nativo quando o backend estiver disponivel.
- `obj`: objeto de plataforma para ligacao posterior.

## Resolucao

Ordem:

1. Modulos do pacote atual.
2. Biblioteca padrao.
3. Dependencias declaradas.
4. Caminhos explicitamente passados ao compilador.

## Compatibilidade

Seven usa versao semantica para pacotes, mas a compatibilidade real e decidida por assinaturas publicas:

- campos publicos;
- moldes publicos;
- selos publicos;
- efeitos publicos;
- contratos publicos.

## Reprodutibilidade

Build profissional precisa registrar:

- versao do compilador;
- criador do pacote;
- hash dos arquivos;
- alvo;
- flags;
- dependencias resolvidas.
