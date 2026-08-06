from pathlib import Path

path = Path("compiler0/parse.sev")
text = path.read_text(encoding="utf-8")
start = text.find("campo parse_nao_unario(")
if start < 0:
    raise RuntimeError("parse_nao_unario not found")
end = text.find("\nfecha", start)
if end < 0:
    raise RuntimeError("parse_nao_unario end not found")
end += len("\nfecha")
replacement = '''campo parse_nao_unario(p: Parser) -> Bit ::
  veja parse_atual(p).tipo == "palavra" e parse_proximo(p, "nao") ::
    guarda proximo := parse_olha(p, 1).marca
    devolve proximo != "," e proximo != ")" e proximo != "]" e proximo != "}" e proximo != "::" e proximo != "fecha" e proximo != "outro" e proximo != "fim" e proximo != "guarda" e proximo != "solta" e proximo != "vira" e proximo != "devolve" e proximo != "diga" e proximo != "veja" e proximo != "gira" e proximo != "para" e proximo != "falha"
  fecha

  devolve nao
fecha'''
path.write_text(text[:start] + replacement + text[end:], encoding="utf-8")
