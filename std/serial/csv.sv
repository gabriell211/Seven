modulo std.serial.csv

usa std.base.resultado

molde Csv ::
  cabecalho: Lista<Texto>
  linhas: Lista<Lista<Texto>>
fecha

campo csv_parse(texto_csv: Texto) -> Resultado<Csv, Falha> ::
  devolve sys_csv_parse(texto_csv)
fecha

campo csv_codifica(csv: Csv) -> Texto ::
  devolve sys_csv_codifica(csv)
fecha
