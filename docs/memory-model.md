# Modelo de memoria Seven

## Principios

Seven oferece baixo nivel sem normalizar comportamento indefinido.

## Categorias

### Valor

Dados pequenos copiados por valor.

### Posse

Um valor com posse tem um dono claro.

```sv
guarda buffer: Posse<Byte[1024]> := reserva_bytes(1024)
```

### Vista

Uma vista observa memoria sem possuir.

```sv
campo soma(bytes: Vista<Byte>) -> U64 ::
  // leitura sem posse
fecha
```

### Vista mutavel

Apenas uma vista mutavel pode existir para a mesma regiao no mesmo tempo logico.

```sv
campo limpa(bytes: VistaMut<Byte>) -> Nada ::
  // escrita controlada
fecha
```

### Cru

Ponteiros crus exigem `zona crua`.

```sv
zona crua ::
  guarda p: Ptr<Byte> := endereco(4096)
fecha
```

## Limites

Acesso indexado deve carregar tamanho quando possivel.

```sv
caixa pacote: Byte[4]
marca pacote @ 4 := 1 // diagnostico: indice fora do limite
```

## Falhas definidas

Quando o compilador nao consegue provar o limite, o codigo gerado deve verificar em execucao no modo seguro.

## Modos

- `seguro`: checagens completas.
- `rapido`: remove checagens provadas redundantes.
- `cru`: permitido somente em zonas explicitas.

## Concorrencia

Memoria compartilhada entre tarefas precisa ser:

- imutavel;
- canalizada;
- protegida por primitiva de sincronizacao;
- ou declarada crua com justificativa.
