# Diagnosticos Seven

## Formato

Todo diagnostico publico usa:

```text
SV-AREA-NOME
```

Exemplo:

```text
SV-TIPO-IMUTAVEL
```

## Areas iniciais

- `SV-LEX-*`: varredura.
- `SV-PARSE-*`: sintaxe.
- `SV-NOME-*`: nomes e modulos.
- `SV-TIPO-*`: tipos.
- `SV-EFEITO-*`: efeitos.
- `SV-MEM-*`: memoria.
- `SV-EMIT-*`: emissao.
- `SV-PKG-*`: pacotes.
- `SV-FORM-*`: formularios.
- `SV-ENV-*`: ambiente.
- `SV-CRYPTO-*`: criptografia.
- `SV-TEST-*`: testes.
- `SIA-*`: sugestoes, autofixes e inteligencia da linguagem.
- `SV-MAIL-*`: email.
- `SV-NET-*`: rede e protocolos.
- `SV-SERIAL-*`: serializacao.
- `SV-AI-*`: inteligencia artificial.
- `SVBC-CAP-*`: capacidades ausentes no runtime.
- `SV-FRONTEND-*`: DOM, bundle e alvo web.
- `SV-CSS-*`: CSS, temas, media queries e assets.

## Codigos obrigatorios iniciais

### `SV-TIPO-IMUTAVEL`

Tentativa de alterar valor criado por `guarda`.

### `SV-MEM-LIMITE`

Acesso provadamente fora do limite de uma caixa, fatia ou bloco.

### `SV-EFEITO-VAZOU`

Campo sem efeito declarado chama outro campo que toca efeito externo.

### `SV-NOME-INEXISTENTE`

Nome usado antes de existir no escopo visivel.

### `SV-TIPO-INCOMPATIVEL`

Valor de um tipo usado onde outro tipo era exigido.

### `SV-FORM-AUSENTE`

Campo de formulario solicitado nao existe.

### `SV-ENV-AUSENTE`

Variavel de ambiente solicitada nao existe.

### `SV-CRYPTO-EXPIRADO`

Token ou credencial temporal expirou.

### `SV-TEST-FALHOU`

Assercao de teste falhou.

## Qualidade das mensagens

Cada diagnostico deve mostrar:

- arquivo;
- linha;
- coluna;
- mensagem curta;
- trecho de origem;
- ajuda objetiva quando houver correcao provavel.
