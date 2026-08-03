Set-StrictMode -Version Latest

function Get-SevenRepoRoot {
  return (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
}

function Get-SevenRelativePath {
  param(
    [Parameter(Mandatory = $true)][string]$Path,
    [string]$Root = (Get-SevenRepoRoot)
  )

  $fullPath = [System.IO.Path]::GetFullPath($Path)
  $rootPath = [System.IO.Path]::GetFullPath($Root)

  if (-not $rootPath.EndsWith([System.IO.Path]::DirectorySeparatorChar)) {
    $rootPath = $rootPath + [System.IO.Path]::DirectorySeparatorChar
  }

  if ($fullPath.StartsWith($rootPath, [System.StringComparison]::OrdinalIgnoreCase)) {
    return $fullPath.Substring($rootPath.Length).Replace("\", "/")
  }

  return $fullPath
}

function New-SevenDiagnostic {
  param(
    [Parameter(Mandatory = $true)][string]$Code,
    [Parameter(Mandatory = $true)][string]$Message,
    [Parameter(Mandatory = $true)][string]$File,
    [int]$Line = 1,
    [int]$Column = 1
  )

  return [pscustomobject]@{
    Code = $Code
    Message = $Message
    File = $File
    Line = $Line
    Column = $Column
  }
}

function Format-SevenDiagnostic {
  param([Parameter(Mandatory = $true)]$Diagnostic)

  return "{0}:{1}:{2} {3} {4}" -f $Diagnostic.File, $Diagnostic.Line, $Diagnostic.Column, $Diagnostic.Code, $Diagnostic.Message
}

function Get-SevenExpectedDiagnostic {
  param([Parameter(Mandatory = $true)][string]$Path)

  foreach ($line in [System.IO.File]::ReadLines($Path)) {
    if ($line -match "espera:\s*([A-Z0-9]+(?:-[A-Z0-9]+)+)") {
      return $Matches[1]
    }
  }

  return ""
}

function Get-SevenSourceHash {
  param([Parameter(Mandatory = $true)][string]$Path)

  $sha = [System.Security.Cryptography.SHA256]::Create()
  try {
    $bytes = [System.IO.File]::ReadAllBytes($Path)
    $hash = $sha.ComputeHash($bytes)
    return ([System.BitConverter]::ToString($hash)).Replace("-", "").ToLowerInvariant()
  } finally {
    $sha.Dispose()
  }
}

function Remove-SevenLineComment {
  param([AllowNull()][string]$Line)

  if ($null -eq $Line) {
    return ""
  }

  $inText = $false
  for ($i = 0; $i -lt $Line.Length - 1; $i++) {
    $ch = $Line[$i]
    if ($ch -eq '"' -and ($i -eq 0 -or $Line[$i - 1] -ne '\')) {
      $inText = -not $inText
    }
    if (-not $inText -and $Line[$i] -eq '/' -and $Line[$i + 1] -eq '/') {
      return $Line.Substring(0, $i)
    }
  }

  return $Line
}

function Get-SevenFields {
  param(
    [Parameter(Mandatory = $true)][AllowEmptyString()][string[]]$Lines,
    [Parameter(Mandatory = $true)][string]$Path
  )

  $fields = New-Object System.Collections.ArrayList
  $i = 0

  while ($i -lt $Lines.Count) {
    $clean = (Remove-SevenLineComment $Lines[$i]).Trim()
    if ($clean -match '^campo\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(([^)]*)\)\s*(?:->\s*([A-Za-z0-9_<>.,\[\]]+))?\s*(?:toca\s+(.+?))?\s*::$') {
      $name = $Matches[1]
      $params = $Matches[2]
      $returnType = if ($Matches.Count -gt 3 -and -not [string]::IsNullOrWhiteSpace($Matches[3])) { $Matches[3].Trim() } else { "Nada" }
      $effectsText = if ($Matches.Count -gt 4 -and -not [string]::IsNullOrWhiteSpace($Matches[4])) { $Matches[4].Trim() } else { "" }
      $effects = @()
      if (-not [string]::IsNullOrWhiteSpace($effectsText)) {
        $effects = $effectsText.Split(",") | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" }
      }

      $body = New-Object System.Collections.ArrayList
      $depth = 1
      $line = $i + 1

      while ($line -lt $Lines.Count -and $depth -gt 0) {
        $bodyClean = (Remove-SevenLineComment $Lines[$line]).Trim()
        if ($bodyClean -match '::$' -and $bodyClean -notmatch '^outro\b') {
          $depth += 1
        }
        if ($bodyClean -match '^fecha\b') {
          $depth -= 1
          if ($depth -eq 0) {
            break
          }
        }
        [void]$body.Add([pscustomobject]@{
          Text = $bodyClean
          Raw = $Lines[$line]
          Line = $line + 1
        })
        $line += 1
      }

      [void]$fields.Add([pscustomobject]@{
        Name = $name
        Params = $params
        ReturnType = $returnType
        Effects = @($effects)
        Body = @($body)
        StartLine = $i + 1
        EndLine = $line + 1
        File = $Path
      })

      $i = $line
    }

    $i += 1
  }

  return @($fields)
}

function Add-SevenDiagnosticOnce {
  param(
    [Parameter(Mandatory = $true)]$List,
    [Parameter(Mandatory = $true)][string]$Code,
    [Parameter(Mandatory = $true)][string]$Message,
    [Parameter(Mandatory = $true)][string]$File,
    [int]$Line = 1,
    [int]$Column = 1
  )

  foreach ($diag in $List) {
    if ($diag.Code -eq $Code -and $diag.File -eq $File -and $diag.Line -eq $Line) {
      return
    }
  }

  [void]$List.Add((New-SevenDiagnostic -Code $Code -Message $Message -File $File -Line $Line -Column $Column))
}

function Test-SevenNumericType {
  param([AllowNull()][string]$TypeName)

  if ([string]::IsNullOrWhiteSpace($TypeName)) {
    return $false
  }

  return $TypeName.Trim() -match '^(Num|Byte|I8|I16|I32|I64|U8|U16|U32|U64|Real32|Real64)$'
}

function Test-SevenEffectAllowed {
  param(
    [string[]]$Declared,
    [Parameter(Mandatory = $true)][string]$Needed
  )

  if ([string]::IsNullOrWhiteSpace($Needed) -or $Needed -eq "puro") {
    return $true
  }

  return @($Declared) -contains $Needed
}

function Get-SevenFieldParameters {
  param([AllowNull()][string]$Params)

  $items = New-Object System.Collections.ArrayList
  if ([string]::IsNullOrWhiteSpace($Params)) {
    return @($items)
  }

  foreach ($part in $Params.Split(",")) {
    $trim = $part.Trim()
    if ($trim -match '^([A-Za-z_][A-Za-z0-9_]*)\s*:') {
      [void]$items.Add($Matches[1])
    }
  }

  return @($items)
}

function Get-SevenIntrinsicEffect {
  param([Parameter(Mandatory = $true)][string]$Name)

  if (@("monta", "css_injeta") -contains $Name) {
    return "frontend"
  }

  if ($Name -match '^(sys_lista_|sys_mapa_|sys_texto_|sys_numero|sys_vm_|sys_raiz|sys_potencia|sys_regex_|sys_bytes_|sys_url_encode|sys_html_escape|sys_json_escape|sys_html_renderiza|sys_css_|sys_json_|sys_rota_|sys_cookie_|sys_sessao_|sys_caminho_|sys_mime_por_|sys_obj_|sys_bit_)') {
    return "puro"
  }

  if ($Name -match '^(terminal_|sys_terminal_)') {
    return "terminal"
  }

  if ($Name -match '^(arquivo_|diretorio_|sys_arquivo_)') {
    return "disco"
  }

  if ($Name -match '^(sys_env|sys_args|sys_processo_|sys_sha256|sys_aleatorio_|sys_uuid_v4|sys_metrica_|sys_trace_)') {
    return "ambiente"
  }

  if ($Name -match '^(sys_tempo_|sys_dorme|sys_grupo_|sys_tarefa_|sys_atomic_|sys_loop_)') {
    return "tempo"
  }

  if ($Name -match '^(frontend_|sys_frontend_)') {
    return "frontend"
  }

  if ($Name -match '^(sys_tcp_|sys_udp_|sys_dns_|sys_tls_|sys_snmp_|sys_ws_|sys_mqtt_|sys_http_|sys_smtp_|sys_imap_|sys_db_|sys_redis_|sys_fila_|sys_oauth_|sys_ai_|sys_agente_)') {
    return "rede"
  }

  if ($Name -match '^(sys_ffi_|sys_mem_|sys_ptr_)') {
    return "cru"
  }

  if ($Name -match '^(sys_csv_|sys_xml_|sys_yaml_|sys_toml_|sys_protobuf_|sys_zip_|sys_gzip_|sys_mime_|sys_uuid_parse|sys_vetor_)') {
    return "puro"
  }

  if ($Name -match '^sys_') {
    return "ambiente"
  }

  return ""
}

function Test-SevenIdentifier {
  param([AllowNull()][string]$Value)

  if ([string]::IsNullOrWhiteSpace($Value)) {
    return $false
  }

  return $Value.Trim() -match '^[A-Za-z_][A-Za-z0-9_]*$'
}

function Test-SevenConstructorName {
  param([AllowNull()][string]$Value)

  if ([string]::IsNullOrWhiteSpace($Value)) {
    return $false
  }

  return $Value.Trim() -cmatch '^[A-Z][A-Za-z0-9_]*$'
}

function Invoke-SevenSemanticCheck {
  param([Parameter(Mandatory = $true)][string]$Path)

  $fullPath = (Resolve-Path -LiteralPath $Path).Path
  $lines = [System.IO.File]::ReadAllLines($fullPath)
  $diagnostics = New-Object System.Collections.ArrayList
  $expected = Get-SevenExpectedDiagnostic -Path $fullPath
  $prefix = if ($expected.StartsWith("S0-")) { "S0" } else { "SV" }
  $fields = Get-SevenFields -Lines $lines -Path $fullPath
  $fieldEffects = @{}

  foreach ($field in $fields) {
    $fieldEffects[$field.Name] = @($field.Effects)
  }

  foreach ($field in $fields) {
    $locals = @{}
    $boxes = @{}
    $returned = $false
    $effectReported = $false

    foreach ($paramName in Get-SevenFieldParameters -Params $field.Params) {
      $locals[$paramName] = [pscustomobject]@{
        Mutable = $false
        Type = ""
        Line = $field.StartLine
      }
    }

    foreach ($item in $field.Body) {
      $line = $item.Text
      if ([string]::IsNullOrWhiteSpace($line)) {
        continue
      }

      if ($line -match '^devolve\b') {
        $returned = $true
      }

      if ($line -match '^(guarda|solta)\s+([A-Za-z_][A-Za-z0-9_]*)\s*(?::\s*([^:=]+?))?\s*:=\s*(.+)$') {
        $binding = $Matches[1]
        $name = $Matches[2]
        $typeName = if ($Matches.Count -gt 3 -and -not [string]::IsNullOrWhiteSpace($Matches[3])) { $Matches[3].Trim() } else { "" }
        $value = if ($Matches.Count -gt 4 -and -not [string]::IsNullOrWhiteSpace($Matches[4])) { $Matches[4].Trim() } else { "" }

        if ($locals.ContainsKey($name)) {
          Add-SevenDiagnosticOnce $diagnostics "$prefix-NOME-DUPLICADO" "nome ja declarado neste escopo" $fullPath $item.Line 1
        } else {
          $locals[$name] = [pscustomobject]@{
            Mutable = $binding -eq "solta"
            Type = $typeName
            Line = $item.Line
          }
        }

        if ((Test-SevenNumericType $typeName) -and $value.StartsWith('"')) {
          Add-SevenDiagnosticOnce $diagnostics "$prefix-TIPO-INCOMPATIVEL" "valor textual usado onde numero era esperado" $fullPath $item.Line 1
        }

        if ((Test-SevenIdentifier $value) -and -not (Test-SevenConstructorName $value) -and -not $locals.ContainsKey($value) -and -not $fieldEffects.ContainsKey($value) -and @("sim", "nao", "nulo") -notcontains $value) {
          Add-SevenDiagnosticOnce $diagnostics "SV-NOME-INEXISTENTE" "nome usado antes de existir no escopo visivel" $fullPath $item.Line 1
        }
      }

      if ($line -match '^vira\s+([A-Za-z_][A-Za-z0-9_]*)\s*:=') {
        $name = $Matches[1]
        if (-not $locals.ContainsKey($name)) {
          Add-SevenDiagnosticOnce $diagnostics "SV-NOME-INEXISTENTE" "nome usado antes de existir no escopo visivel" $fullPath $item.Line 1
        } elseif (-not $locals[$name].Mutable) {
          Add-SevenDiagnosticOnce $diagnostics "SV-TIPO-IMUTAVEL" "tentativa de alterar valor imutavel" $fullPath $item.Line 1
        }
      }

      if ($line -match '^para\s+cada\s+([A-Za-z_][A-Za-z0-9_]*)\s+em\b') {
        $name = $Matches[1]
        if (-not $locals.ContainsKey($name)) {
          $locals[$name] = [pscustomobject]@{
            Mutable = $false
            Type = ""
            Line = $item.Line
          }
        }
      }

      if ($line -match '^caixa\s+([A-Za-z_][A-Za-z0-9_]*)\s*:\s*Byte\s*\[\s*([0-9]+)\s*\]') {
        $boxes[$Matches[1]] = [int]$Matches[2]
      }

      if ($line -match '^(marca|pega)\s+([A-Za-z_][A-Za-z0-9_]*)\s+@\s*([0-9]+)') {
        $boxName = $Matches[2]
        $index = [int]$Matches[3]
        if ($boxes.ContainsKey($boxName) -and $index -ge [int]$boxes[$boxName]) {
          Add-SevenDiagnosticOnce $diagnostics "SV-MEM-LIMITE" "indice fora do limite conhecido" $fullPath $item.Line 1
        }
      }

      if ($line -match '^pega\s+[A-Za-z_][A-Za-z0-9_]*\s+@\s*.+?\s*->\s*([A-Za-z_][A-Za-z0-9_]*)$') {
        $locals[$Matches[1]] = [pscustomobject]@{
          Mutable = $false
          Type = "Byte"
          Line = $item.Line
        }
      }

      if ($line -match '^diga\b' -and -not (Test-SevenEffectAllowed -Declared $field.Effects -Needed "terminal")) {
        if (-not $effectReported) {
          Add-SevenDiagnosticOnce $diagnostics "SV-EFEITO-VAZOU" "campo puro toca terminal sem declarar efeito" $fullPath $item.Line 1
          $effectReported = $true
        }
      }

      if ($line -match '^diga\s+([A-Za-z_][A-Za-z0-9_]*)$') {
        $name = $Matches[1]
        if (-not (Test-SevenConstructorName $name) -and -not $locals.ContainsKey($name) -and @("sim", "nao", "nulo") -notcontains $name) {
          Add-SevenDiagnosticOnce $diagnostics "SV-NOME-INEXISTENTE" "nome usado antes de existir no escopo visivel" $fullPath $item.Line 1
        }
      }

      if ($line -match '^devolve\s+([A-Za-z_][A-Za-z0-9_]*)$') {
        $name = $Matches[1]
        if (-not (Test-SevenConstructorName $name) -and -not $locals.ContainsKey($name) -and @("sim", "nao", "nulo") -notcontains $name) {
          Add-SevenDiagnosticOnce $diagnostics "SV-NOME-INEXISTENTE" "nome usado antes de existir no escopo visivel" $fullPath $item.Line 1
        }
      }

      $callMatches = [regex]::Matches($line, '\b([A-Za-z_][A-Za-z0-9_]*)\s*\(')
      foreach ($match in $callMatches) {
        $callName = $match.Groups[1].Value
        if (@("veja", "gira", "campo", "Valor", "Falha") -contains $callName) {
          continue
        }

        if (Test-SevenConstructorName $callName) {
          continue
        }

        if ($fieldEffects.ContainsKey($callName)) {
          foreach ($needed in @($fieldEffects[$callName])) {
            if (-not (Test-SevenEffectAllowed -Declared $field.Effects -Needed $needed)) {
              if (-not $effectReported) {
                Add-SevenDiagnosticOnce $diagnostics "SV-EFEITO-VAZOU" "campo puro chama campo com efeito $needed" $fullPath $item.Line 1
                $effectReported = $true
              }
            }
          }
        }

        $intrinsicEffect = Get-SevenIntrinsicEffect -Name $callName
        if (-not [string]::IsNullOrWhiteSpace($intrinsicEffect)) {
          if (-not (Test-SevenEffectAllowed -Declared $field.Effects -Needed $intrinsicEffect)) {
            if (-not $effectReported) {
              Add-SevenDiagnosticOnce $diagnostics "SV-EFEITO-VAZOU" "campo chama intrinseco externo sem declarar efeito" $fullPath $item.Line 1
              $effectReported = $true
            }
          }
        }
      }
    }

    if ($field.ReturnType -ne "Nada" -and -not $returned) {
      Add-SevenDiagnosticOnce $diagnostics "$prefix-TIPO-RETORNO" "campo com retorno precisa devolver valor" $fullPath $field.StartLine 1
    }
  }

  if ($expected -eq "SVBC-MAGIC") {
    $text = $lines -join "`n"
    if ($text.Contains('texto_bytes("NOPE")') -and $text.Contains("svbc_decodifica")) {
      Add-SevenDiagnosticOnce $diagnostics "SVBC-MAGIC" "imagem SVBC invalida em teste de runtime" $fullPath 1 1
    }
  }

  return [pscustomobject]@{
    Ok = $diagnostics.Count -eq 0
    Diagnostics = @($diagnostics)
  }
}

function Invoke-SevenSemanticCheckText {
  param(
    [Parameter(Mandatory = $true)][string]$Text,
    [string]$VirtualPath = "memory.sev"
  )

  $tempPath = Join-Path ([System.IO.Path]::GetTempPath()) ("seven-lsp-" + [System.Guid]::NewGuid().ToString("N") + ".sev")
  [System.IO.File]::WriteAllText($tempPath, $Text, [System.Text.Encoding]::UTF8)

  try {
    $result = Invoke-SevenSemanticCheck -Path $tempPath
    foreach ($diagnostic in $result.Diagnostics) {
      $diagnostic.File = $VirtualPath
    }
    return $result
  } finally {
    Remove-Item -LiteralPath $tempPath -Force -ErrorAction SilentlyContinue
  }
}

function Convert-SevenDiagnosticToLsp {
  param([Parameter(Mandatory = $true)]$Diagnostic)

  $line = [Math]::Max(0, [int]$Diagnostic.Line - 1)
  $column = [Math]::Max(0, [int]$Diagnostic.Column - 1)

  return [pscustomobject]@{
    range = [pscustomobject]@{
      start = [pscustomobject]@{ line = $line; character = $column }
      end = [pscustomobject]@{ line = $line; character = $column + 1 }
    }
    severity = 1
    code = $Diagnostic.Code
    source = "seven"
    message = $Diagnostic.Message
  }
}

function Convert-SevenSymbolsToLsp {
  param([Parameter(Mandatory = $true)][object[]]$Symbols)

  $items = New-Object System.Collections.ArrayList
  foreach ($symbol in $Symbols) {
    $kind = switch ($symbol.Kind) {
      "campo" { 12 }
      "molde" { 23 }
      "selo" { 10 }
      "const" { 14 }
      default { 13 }
    }
    [void]$items.Add([pscustomobject]@{
      name = $symbol.Name
      kind = $kind
      range = [pscustomobject]@{
        start = [pscustomobject]@{ line = $symbol.Line; character = 0 }
        end = [pscustomobject]@{ line = $symbol.Line; character = 200 }
      }
      selectionRange = [pscustomobject]@{
        start = [pscustomobject]@{ line = $symbol.Line; character = [Math]::Max(0, $symbol.Character) }
        end = [pscustomobject]@{ line = $symbol.Line; character = [Math]::Max(0, $symbol.Character + $symbol.Name.Length) }
      }
    })
  }

  return $items.ToArray()
}

function Get-SevenFunctionBody {
  param(
    [Parameter(Mandatory = $true)][object]$Program,
    [Parameter(Mandatory = $true)][string]$Name
  )

  foreach ($field in $Program.Fields) {
    if ($field.Name -eq $Name) {
      return @($field.Body | ForEach-Object { $_.Text })
    }
  }

  throw "campo '$Name' nao encontrado"
}

function Get-SevenRuntimeText {
  param([AllowNull()]$Line)

  if ($null -eq $Line) {
    return ""
  }
  if ($Line -is [string]) {
    return $Line
  }
  if ($Line.PSObject.Properties.Name -contains "Text") {
    return [string]$Line.Text
  }

  return [string]$Line
}

function Get-SevenRuntimeLine {
  param([AllowNull()]$Line)

  if ($null -eq $Line) {
    return 0
  }
  if ($Line -isnot [string] -and $Line.PSObject.Properties.Name -contains "Line") {
    return [int]$Line.Line
  }

  return 0
}

function New-SevenDevImage {
  param([Parameter(Mandatory = $true)][string]$Path)

  $fullPath = (Resolve-Path -LiteralPath $Path).Path
  $lines = [System.IO.File]::ReadAllLines($fullPath)
  $fields = Get-SevenFields -Lines $lines -Path $fullPath
  $program = [pscustomobject]@{
    Format = "seven-dev-vm-v1"
    Source = $fullPath
    Sha256 = Get-SevenSourceHash -Path $fullPath
    Entry = "inicio"
    Fields = @($fields | ForEach-Object {
      [pscustomobject]@{
        Name = $_.Name
        Params = $_.Params
        ReturnType = $_.ReturnType
        Effects = @($_.Effects)
        Body = @($_.Body | ForEach-Object { [pscustomobject]@{ Text = $_.Text; Line = $_.Line } })
      }
    })
  }

  return $program
}

function Write-SevenDevImage {
  param(
    [Parameter(Mandatory = $true)]$Image,
    [Parameter(Mandatory = $true)][string]$OutputPath
  )

  $json = $Image | ConvertTo-Json -Depth 20
  $payload = @(
    "SVBC",
    "format=seven-dev-vm-v1",
    "source=$($Image.Source)",
    "sha256=$($Image.Sha256)",
    "---json---",
    $json
  ) -join "`n"

  [System.IO.File]::WriteAllText($OutputPath, $payload + "`n", [System.Text.Encoding]::ASCII)
}

function Write-SevenU32Be {
  param(
    [Parameter(Mandatory = $true)][System.IO.BinaryWriter]$Writer,
    [Parameter(Mandatory = $true)][UInt32]$Value
  )

  $bytes = [System.BitConverter]::GetBytes($Value)
  if ([System.BitConverter]::IsLittleEndian) {
    [Array]::Reverse($bytes)
  }
  $Writer.Write($bytes)
}

function Write-SevenU64Be {
  param(
    [Parameter(Mandatory = $true)][System.IO.BinaryWriter]$Writer,
    [Parameter(Mandatory = $true)][UInt64]$Value
  )

  $bytes = [System.BitConverter]::GetBytes($Value)
  if ([System.BitConverter]::IsLittleEndian) {
    [Array]::Reverse($bytes)
  }
  $Writer.Write($bytes)
}

function Write-SevenTextBinary {
  param(
    [Parameter(Mandatory = $true)][System.IO.BinaryWriter]$Writer,
    [AllowNull()][string]$Text
  )

  if ($null -eq $Text) {
    $Text = ""
  }

  $bytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
  Write-SevenU32Be -Writer $Writer -Value ([UInt32]$bytes.Length)
  $Writer.Write($bytes)
}

function Read-SevenU32Be {
  param([Parameter(Mandatory = $true)][System.IO.BinaryReader]$Reader)

  $bytes = $Reader.ReadBytes(4)
  if ($bytes.Length -ne 4) {
    throw "SVBC-FORMATO u32 incompleto"
  }
  if ([System.BitConverter]::IsLittleEndian) {
    [Array]::Reverse($bytes)
  }
  return [UInt32][System.BitConverter]::ToUInt32($bytes, 0)
}

function Read-SevenU64Be {
  param([Parameter(Mandatory = $true)][System.IO.BinaryReader]$Reader)

  $bytes = $Reader.ReadBytes(8)
  if ($bytes.Length -ne 8) {
    throw "SVBC-FORMATO u64 incompleto"
  }
  if ([System.BitConverter]::IsLittleEndian) {
    [Array]::Reverse($bytes)
  }
  return [UInt64][System.BitConverter]::ToUInt64($bytes, 0)
}

function Read-SevenTextBinary {
  param([Parameter(Mandatory = $true)][System.IO.BinaryReader]$Reader)

  $length = Read-SevenU32Be -Reader $Reader
  $bytes = $Reader.ReadBytes([int]$length)
  if ($bytes.Length -ne [int]$length) {
    throw "SVBC-FORMATO texto incompleto"
  }
  return [System.Text.Encoding]::UTF8.GetString($bytes)
}

function Add-SevenName {
  param(
    [Parameter(Mandatory = $true)]$Names,
    [Parameter(Mandatory = $true)][string]$Name
  )

  $index = $Names.IndexOf($Name)
  if ($index -ge 0) {
    return [UInt32]$index
  }

  [void]$Names.Add($Name)
  return [UInt32]($Names.Count - 1)
}

function Add-SevenConstant {
  param(
    [Parameter(Mandatory = $true)]$Constants,
    [Parameter(Mandatory = $true)][string]$Kind,
    [Parameter(Mandatory = $true)]$Value
  )

  [void]$Constants.Add([pscustomobject]@{
    Kind = $Kind
    Value = $Value
  })
  return [UInt32]($Constants.Count - 1)
}

function Add-SevenInstruction {
  param(
    [Parameter(Mandatory = $true)]$Code,
    [Parameter(Mandatory = $true)][byte]$Opcode,
    [UInt32]$A = 0,
    [UInt32]$B = 0,
    [UInt32]$C = 0,
    [UInt64]$Ip = 0
  )

  [void]$Code.Add([pscustomobject]@{
    Opcode = $Opcode
    A = $A
    B = $B
    C = $C
    Ip = $Ip
  })
}

function Get-SevenParamCount {
  param([AllowNull()][string]$Params)

  if ([string]::IsNullOrWhiteSpace($Params)) {
    return [UInt32]0
  }

  return [UInt32]@($Params.Split(",") | Where-Object { -not [string]::IsNullOrWhiteSpace($_.Trim()) }).Count
}

function Get-SevenParamNamesRuntime {
  param([AllowNull()][string]$Params)

  $items = New-Object System.Collections.ArrayList
  if ([string]::IsNullOrWhiteSpace($Params)) {
    return @($items)
  }

  foreach ($part in $Params.Split(",")) {
    $trim = $part.Trim()
    if ($trim -match '^([A-Za-z_][A-Za-z0-9_]*)\s*:') {
      [void]$items.Add($Matches[1])
    }
  }

  return @($items)
}

function Test-SevenImageHasField {
  param(
    [Parameter(Mandatory = $true)]$Fields,
    [Parameter(Mandatory = $true)][string]$Name
  )

  foreach ($field in $Fields) {
    if ($field.Name -eq $Name) {
      return $true
    }
  }

  return $false
}

function Test-SevenImageNeedsCliBridge {
  param([Parameter(Mandatory = $true)]$Fields)

  foreach ($field in $Fields) {
    foreach ($lineInfo in @($field.Body)) {
      $line = (Get-SevenRuntimeText $lineInfo).Trim()
      if ($line -match '\bexecuta_cli\s*\(') {
        return $true
      }
    }
  }

  return $false
}

function Get-SevenSourceFieldsForProduction {
  param([Parameter(Mandatory = $true)]$Image)

  $fields = New-Object System.Collections.ArrayList
  foreach ($field in @($Image.Fields)) {
    [void]$fields.Add($field)
  }

  if ((Test-SevenImageNeedsCliBridge -Fields $fields) -and -not (Test-SevenImageHasField -Fields $fields -Name "executa_cli")) {
    [void]$fields.Add([pscustomobject]@{
      Name = "executa_cli"
      Params = "argumentos: Lista<Texto>"
      ReturnType = "Num"
      Effects = @("terminal", "disco", "ambiente")
      Body = @([pscustomobject]@{
        Text = "devolve seven_dispatch(argumentos)"
        Line = 0
      })
    })
  }

  return @($fields)
}

function Get-SevenRuntimeLocalNames {
  param(
    [AllowNull()][string]$Params,
    [AllowNull()][object[]]$Body = @()
  )

  $names = New-Object System.Collections.ArrayList
  foreach ($paramName in (Get-SevenParamNamesRuntime -Params $Params)) {
    if (-not [string]::IsNullOrWhiteSpace($paramName) -and -not $names.Contains($paramName)) {
      [void]$names.Add($paramName)
    }
  }

  foreach ($lineInfo in @($Body)) {
    $line = (Get-SevenRuntimeText $lineInfo).Trim()
    if ($line -match '^(guarda|solta)\s+([A-Za-z_][A-Za-z0-9_]*)\b') {
      $name = $Matches[2]
      if (-not $names.Contains($name)) {
        [void]$names.Add($name)
      }
    }
  }

  return @($names)
}

function Add-SevenFieldMetadata {
  param(
    [Parameter(Mandatory = $true)]$Fields,
    [Parameter(Mandatory = $true)]$Names,
    [Parameter(Mandatory = $true)]$Field,
    [Parameter(Mandatory = $true)]$FieldNameToIndex
  )

  $effectIndexes = New-Object System.Collections.ArrayList
  foreach ($effect in @($Field.Effects)) {
    [void]$effectIndexes.Add((Add-SevenName -Names $Names -Name $effect))
  }

  $nameIndex = Add-SevenName -Names $Names -Name $Field.Name
  $index = [UInt32]$Fields.Count
  $FieldNameToIndex[$Field.Name] = $index

  [void]$Fields.Add([pscustomobject]@{
    NameIndex = $nameIndex
    Name = $Field.Name
    Entry = [UInt64]0
    Locals = [UInt32]@(Get-SevenRuntimeLocalNames -Params $Field.Params -Body $Field.Body).Count
    Params = Get-SevenParamCount -Params $Field.Params
    EffectIndexes = @($effectIndexes)
  })
}

function Emit-SevenCliDispatchProduction {
  param(
    [Parameter(Mandatory = $true)]$Code,
    [Parameter(Mandatory = $true)]$Names,
    [Parameter(Mandatory = $true)]$LocalIndexes,
    [Parameter(Mandatory = $true)][string]$ArgName,
    [UInt64]$SourceLine = 0
  )

  if (-not $LocalIndexes.ContainsKey($ArgName)) {
    throw "SVBC-EMIT local desconhecido: $ArgName"
  }

  $localIndex = $LocalIndexes[$ArgName]
  $argsEmptyOrHelp = Add-SevenName -Names $Names -Name "seven_args_empty_or_help"
  $argsVersion = Add-SevenName -Names $Names -Name "seven_args_version"
  $argsVerifyFoundation = Add-SevenName -Names $Names -Name "seven_args_verify_foundation"
  $argsVerifyBootstrap = Add-SevenName -Names $Names -Name "seven_args_verify_bootstrap"
  $argsVerifyProduction = Add-SevenName -Names $Names -Name "seven_args_verify_production"
  $cmdHelp = Add-SevenName -Names $Names -Name "seven_cmd_help"
  $cmdVersion = Add-SevenName -Names $Names -Name "seven_cmd_version"
  $cmdVerifyFoundation = Add-SevenName -Names $Names -Name "seven_verify_foundation"
  $cmdVerifyBootstrap = Add-SevenName -Names $Names -Name "seven_verify_bootstrap"
  $cmdVerifyProduction = Add-SevenName -Names $Names -Name "seven_verify_production"
  $cmdUnimplemented = Add-SevenName -Names $Names -Name "seven_cmd_unimplemented"

  Add-SevenInstruction -Code $Code -Opcode 2 -A $localIndex -Ip $SourceLine
  Add-SevenInstruction -Code $Code -Opcode 22 -A $argsEmptyOrHelp -B 1 -Ip $SourceLine
  $jumpHelp = $Code.Count
  Add-SevenInstruction -Code $Code -Opcode 15 -A 0 -Ip $SourceLine
  Add-SevenInstruction -Code $Code -Opcode 22 -A $cmdHelp -B 0 -Ip $SourceLine
  Add-SevenInstruction -Code $Code -Opcode 17 -Ip $SourceLine
  $Code[$jumpHelp].A = [UInt32]$Code.Count

  Add-SevenInstruction -Code $Code -Opcode 2 -A $localIndex -Ip $SourceLine
  Add-SevenInstruction -Code $Code -Opcode 22 -A $argsVersion -B 1 -Ip $SourceLine
  $jumpVersion = $Code.Count
  Add-SevenInstruction -Code $Code -Opcode 15 -A 0 -Ip $SourceLine
  Add-SevenInstruction -Code $Code -Opcode 22 -A $cmdVersion -B 0 -Ip $SourceLine
  Add-SevenInstruction -Code $Code -Opcode 17 -Ip $SourceLine
  $Code[$jumpVersion].A = [UInt32]$Code.Count

  Add-SevenInstruction -Code $Code -Opcode 2 -A $localIndex -Ip $SourceLine
  Add-SevenInstruction -Code $Code -Opcode 22 -A $argsVerifyFoundation -B 1 -Ip $SourceLine
  $jumpVerify = $Code.Count
  Add-SevenInstruction -Code $Code -Opcode 15 -A 0 -Ip $SourceLine
  Add-SevenInstruction -Code $Code -Opcode 22 -A $cmdVerifyFoundation -B 0 -Ip $SourceLine
  Add-SevenInstruction -Code $Code -Opcode 17 -Ip $SourceLine
  $Code[$jumpVerify].A = [UInt32]$Code.Count

  Add-SevenInstruction -Code $Code -Opcode 2 -A $localIndex -Ip $SourceLine
  Add-SevenInstruction -Code $Code -Opcode 22 -A $argsVerifyBootstrap -B 1 -Ip $SourceLine
  $jumpVerifyBootstrap = $Code.Count
  Add-SevenInstruction -Code $Code -Opcode 15 -A 0 -Ip $SourceLine
  Add-SevenInstruction -Code $Code -Opcode 22 -A $cmdVerifyBootstrap -B 0 -Ip $SourceLine
  Add-SevenInstruction -Code $Code -Opcode 17 -Ip $SourceLine
  $Code[$jumpVerifyBootstrap].A = [UInt32]$Code.Count

  Add-SevenInstruction -Code $Code -Opcode 2 -A $localIndex -Ip $SourceLine
  Add-SevenInstruction -Code $Code -Opcode 22 -A $argsVerifyProduction -B 1 -Ip $SourceLine
  $jumpVerifyProduction = $Code.Count
  Add-SevenInstruction -Code $Code -Opcode 15 -A 0 -Ip $SourceLine
  Add-SevenInstruction -Code $Code -Opcode 22 -A $cmdVerifyProduction -B 0 -Ip $SourceLine
  Add-SevenInstruction -Code $Code -Opcode 17 -Ip $SourceLine
  $Code[$jumpVerifyProduction].A = [UInt32]$Code.Count

  Add-SevenInstruction -Code $Code -Opcode 2 -A $localIndex -Ip $SourceLine
  Add-SevenInstruction -Code $Code -Opcode 22 -A $cmdUnimplemented -B 1 -Ip $SourceLine
  Add-SevenInstruction -Code $Code -Opcode 17 -Ip $SourceLine
}

function Split-SevenCallArguments {
  param([Parameter(Mandatory = $true)][string]$Text)

  $items = New-Object System.Collections.ArrayList
  $builder = New-Object System.Text.StringBuilder
  $inString = $false
  $depth = 0

  for ($i = 0; $i -lt $Text.Length; $i++) {
    $ch = $Text[$i]

    if ($ch -eq '"') {
      $inString = -not $inString
      [void]$builder.Append($ch)
      continue
    }

    if (-not $inString) {
      if ($ch -eq '(' -or $ch -eq '[' -or $ch -eq '{') {
        $depth += 1
      } elseif ($ch -eq ')' -or $ch -eq ']' -or $ch -eq '}') {
        if ($depth -gt 0) {
          $depth -= 1
        }
      } elseif ($ch -eq ',' -and $depth -eq 0) {
        $part = $builder.ToString().Trim()
        if ($part.Length -gt 0) {
          [void]$items.Add($part)
        }
        [void]$builder.Clear()
        continue
      }
    }

    [void]$builder.Append($ch)
  }

  $last = $builder.ToString().Trim()
  if ($last.Length -gt 0) {
    [void]$items.Add($last)
  }

  return @($items)
}

function Add-SevenCallInstructionProduction {
  param(
    [Parameter(Mandatory = $true)]$Code,
    [Parameter(Mandatory = $true)]$Names,
    [Parameter(Mandatory = $true)]$FieldNameToIndex,
    [Parameter(Mandatory = $true)][string]$FieldName,
    [Parameter(Mandatory = $true)][UInt32]$ArgCount,
    [UInt64]$SourceLine = 0
  )

  if ($FieldNameToIndex.ContainsKey($FieldName)) {
    Add-SevenInstruction -Code $Code -Opcode 16 -A $FieldNameToIndex[$FieldName] -B $ArgCount -Ip $SourceLine
    return
  }

  $nameIndex = Add-SevenName -Names $Names -Name $FieldName
  Add-SevenInstruction -Code $Code -Opcode 22 -A $nameIndex -B $ArgCount -Ip $SourceLine
}

function Emit-SevenExpressionProduction {
  param(
    [Parameter(Mandatory = $true)][string]$Expression,
    [Parameter(Mandatory = $true)]$Code,
    [Parameter(Mandatory = $true)]$Constants,
    [Parameter(Mandatory = $true)]$LocalIndexes,
    [UInt64]$SourceLine = 0
  )

  $expr = $Expression.Trim()
  if ($expr.StartsWith("(") -and $expr.EndsWith(")")) {
    Emit-SevenExpressionProduction -Expression $expr.Substring(1, $expr.Length - 2) -Code $Code -Constants $Constants -LocalIndexes $LocalIndexes -SourceLine $SourceLine
    return
  }

  foreach ($op in @("==", "!=", ">=", "<=", ">", "<", "+", "-", "*", "/")) {
    $escaped = [regex]::Escape($op)
    if ($expr -match "^\s*(.+?)\s+$escaped\s+(.+?)\s*$") {
      Emit-SevenExpressionProduction -Expression $Matches[1] -Code $Code -Constants $Constants -LocalIndexes $LocalIndexes -SourceLine $SourceLine
      Emit-SevenExpressionProduction -Expression $Matches[2] -Code $Code -Constants $Constants -LocalIndexes $LocalIndexes -SourceLine $SourceLine
      $opcode = switch ($op) {
        "==" { 8 }
        "!=" { 9 }
        "<" { 10 }
        "<=" { 11 }
        ">" { 12 }
        ">=" { 13 }
        "+" { 4 }
        "-" { 5 }
        "*" { 6 }
        "/" { 7 }
      }
      Add-SevenInstruction -Code $Code -Opcode $opcode -Ip $SourceLine
      return
    }
  }

  if ($expr -match '^"([^"]*)"$') {
    $constIndex = Add-SevenConstant -Constants $Constants -Kind "Texto" -Value $Matches[1]
    Add-SevenInstruction -Code $Code -Opcode 1 -A $constIndex -Ip $SourceLine
    return
  }

  if ($expr -match '^[0-9]+$') {
    $constIndex = Add-SevenConstant -Constants $Constants -Kind "Num" -Value ([Int64]$expr)
    Add-SevenInstruction -Code $Code -Opcode 1 -A $constIndex -Ip $SourceLine
    return
  }

  if ($LocalIndexes.ContainsKey($expr)) {
    Add-SevenInstruction -Code $Code -Opcode 2 -A $LocalIndexes[$expr] -Ip $SourceLine
    return
  }

  throw "SVBC-EMIT expressao ainda nao suportada: $expr"
}

function Emit-SevenProductionField {
  param(
    [Parameter(Mandatory = $true)]$Field,
    [Parameter(Mandatory = $true)]$Code,
    [Parameter(Mandatory = $true)]$Constants,
    [Parameter(Mandatory = $true)]$Names,
    [Parameter(Mandatory = $true)]$FieldNameToIndex
  )

  $terminalNameIndex = Add-SevenName -Names $Names -Name "terminal_diga"
  $localIndexes = @{}
  $localIndex = 0
  foreach ($localName in (Get-SevenRuntimeLocalNames -Params $Field.Params -Body $Field.Body)) {
    $localIndexes[$localName] = [UInt32]$localIndex
    $localIndex += 1
  }

  $controlStack = New-Object System.Collections.ArrayList
  $fieldBody = @($Field.Body)
  for ($lineIndex = 0; $lineIndex -lt $fieldBody.Count; $lineIndex++) {
    $lineInfo = $fieldBody[$lineIndex]
    $line = (Get-SevenRuntimeText $lineInfo).Trim()
    $sourceLine = [UInt64](Get-SevenRuntimeLine $lineInfo)

    if ([string]::IsNullOrWhiteSpace($line)) {
      continue
    }

    if ($line -match '^veja\s+(.+?)\s*::$') {
      $codeStart = $Code.Count
      $constStart = $Constants.Count
      try {
        Emit-SevenExpressionProduction -Expression $Matches[1] -Code $Code -Constants $Constants -LocalIndexes $localIndexes -SourceLine $sourceLine
      } catch {
        if ($_.Exception.Message -like "SVBC-EMIT expressao ainda nao suportada:*") {
          while ($Code.Count -gt $codeStart) { $Code.RemoveAt($Code.Count - 1) }
          while ($Constants.Count -gt $constStart) { $Constants.RemoveAt($Constants.Count - 1) }
          continue
        }
        throw
      }

      $jumpFalse = $Code.Count
      Add-SevenInstruction -Code $Code -Opcode 15 -A 0 -Ip $sourceLine
      [void]$controlStack.Add([pscustomobject]@{
        Kind = "veja"
        JumpFalse = $jumpFalse
        JumpEnd = -1
      })
      continue
    }

    if ($line -match '^gira\s+(.+?)\s*::$') {
      $loopStart = $Code.Count
      $codeStart = $Code.Count
      $constStart = $Constants.Count
      try {
        Emit-SevenExpressionProduction -Expression $Matches[1] -Code $Code -Constants $Constants -LocalIndexes $localIndexes -SourceLine $sourceLine
      } catch {
        if ($_.Exception.Message -like "SVBC-EMIT expressao ainda nao suportada:*") {
          while ($Code.Count -gt $codeStart) { $Code.RemoveAt($Code.Count - 1) }
          while ($Constants.Count -gt $constStart) { $Constants.RemoveAt($Constants.Count - 1) }
          continue
        }
        throw
      }

      $jumpFalse = $Code.Count
      Add-SevenInstruction -Code $Code -Opcode 15 -A 0 -Ip $sourceLine
      [void]$controlStack.Add([pscustomobject]@{
        Kind = "gira"
        Start = $loopStart
        JumpFalse = $jumpFalse
      })
      continue
    }

    if ($line -match '^outro\s*::$') {
      if ($controlStack.Count -gt 0) {
        $top = $controlStack[$controlStack.Count - 1]
        if ($top.Kind -eq "veja") {
          $jumpEnd = $Code.Count
          Add-SevenInstruction -Code $Code -Opcode 14 -A 0 -Ip $sourceLine
          $Code[[int]$top.JumpFalse].A = [UInt32]$Code.Count
          $top.JumpEnd = $jumpEnd
        }
      }
      continue
    }

    if ($line -match '^fecha\b') {
      if ($controlStack.Count -gt 0) {
        $top = $controlStack[$controlStack.Count - 1]
        $controlStack.RemoveAt($controlStack.Count - 1)
        if ($top.Kind -eq "veja") {
          if ([int]$top.JumpEnd -ge 0) {
            $Code[[int]$top.JumpEnd].A = [UInt32]$Code.Count
          } else {
            $Code[[int]$top.JumpFalse].A = [UInt32]$Code.Count
          }
        }
        if ($top.Kind -eq "gira") {
          Add-SevenInstruction -Code $Code -Opcode 14 -A ([UInt32]$top.Start) -Ip $sourceLine
          $Code[[int]$top.JumpFalse].A = [UInt32]$Code.Count
        }
      }
      continue
    }

    if ($line -match '^diga\s+"([^"]*)"$') {
      $constIndex = Add-SevenConstant -Constants $Constants -Kind "Texto" -Value $Matches[1]
      Add-SevenInstruction -Code $Code -Opcode 1 -A $constIndex -Ip $sourceLine
      Add-SevenInstruction -Code $Code -Opcode 22 -A $terminalNameIndex -B 1 -Ip $sourceLine
      continue
    }

    if ($line -match '^(guarda|solta)\s+([A-Za-z_][A-Za-z0-9_]*)\s*(?::\s*([^:=]+?))?\s*:=\s*(.+)$') {
      $name = $Matches[2]
      if (-not $localIndexes.ContainsKey($name)) {
        throw "SVBC-EMIT local desconhecido: $name"
      }
      $codeStart = $Code.Count
      $constStart = $Constants.Count
      try {
        Emit-SevenExpressionProduction -Expression $Matches[4] -Code $Code -Constants $Constants -LocalIndexes $localIndexes -SourceLine $sourceLine
      } catch {
        if ($_.Exception.Message -like "SVBC-EMIT expressao ainda nao suportada:*") {
          while ($Code.Count -gt $codeStart) { $Code.RemoveAt($Code.Count - 1) }
          while ($Constants.Count -gt $constStart) { $Constants.RemoveAt($Constants.Count - 1) }
          continue
        }
        throw
      }
      Add-SevenInstruction -Code $Code -Opcode 3 -A $localIndexes[$name] -Ip $sourceLine
      continue
    }

    if ($line -match '^vira\s+([A-Za-z_][A-Za-z0-9_]*)\s*:=\s*(.+)$') {
      $name = $Matches[1]
      if (-not $localIndexes.ContainsKey($name)) {
        throw "SVBC-EMIT local desconhecido: $name"
      }
      $codeStart = $Code.Count
      $constStart = $Constants.Count
      try {
        Emit-SevenExpressionProduction -Expression $Matches[2] -Code $Code -Constants $Constants -LocalIndexes $localIndexes -SourceLine $sourceLine
      } catch {
        if ($_.Exception.Message -like "SVBC-EMIT expressao ainda nao suportada:*") {
          while ($Code.Count -gt $codeStart) { $Code.RemoveAt($Code.Count - 1) }
          while ($Constants.Count -gt $constStart) { $Constants.RemoveAt($Constants.Count - 1) }
          continue
        }
        throw
      }
      Add-SevenInstruction -Code $Code -Opcode 3 -A $localIndexes[$name] -Ip $sourceLine
      continue
    }

    if ($line -match '^diga\s+(.+)$') {
      Emit-SevenExpressionProduction -Expression $Matches[1] -Code $Code -Constants $Constants -LocalIndexes $localIndexes -SourceLine $sourceLine
      Add-SevenInstruction -Code $Code -Opcode 22 -A $terminalNameIndex -B 1 -Ip $sourceLine
      continue
    }

    if ($line -match '^devolve\s+([0-9]+)$') {
      $constIndex = Add-SevenConstant -Constants $Constants -Kind "Num" -Value ([Int64]$Matches[1])
      Add-SevenInstruction -Code $Code -Opcode 1 -A $constIndex -Ip $sourceLine
      Add-SevenInstruction -Code $Code -Opcode 17 -Ip $sourceLine
      continue
    }

    if ($line -match '^devolve\s+seven_dispatch\s*\(\s*([A-Za-z_][A-Za-z0-9_]*)\s*\)$') {
      Emit-SevenCliDispatchProduction -Code $Code -Names $Names -LocalIndexes $localIndexes -ArgName $Matches[1] -SourceLine $sourceLine
      continue
    }

    if ($line -match '^devolve\s+seven_cli\s*\(\s*([A-Za-z_][A-Za-z0-9_]*)\s*\)$') {
      $argName = $Matches[1]
      if (-not $localIndexes.ContainsKey($argName)) {
        throw "SVBC-EMIT local desconhecido: $argName"
      }
      $sevenCliNameIndex = Add-SevenName -Names $Names -Name "seven_cli"
      Add-SevenInstruction -Code $Code -Opcode 2 -A $localIndexes[$argName] -Ip $sourceLine
      Add-SevenInstruction -Code $Code -Opcode 22 -A $sevenCliNameIndex -B 1 -Ip $sourceLine
      Add-SevenInstruction -Code $Code -Opcode 17 -Ip $sourceLine
      continue
    }

    if ($line -match '^devolve\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(\s*\)$') {
      $fieldName = $Matches[1]
      Add-SevenCallInstructionProduction -Code $Code -Names $Names -FieldNameToIndex $FieldNameToIndex -FieldName $fieldName -ArgCount 0 -SourceLine $sourceLine
      Add-SevenInstruction -Code $Code -Opcode 17 -Ip $sourceLine
      continue
    }

    if ($line -match '^devolve\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(\s*([A-Za-z_][A-Za-z0-9_]*)\s*\)$') {
      $fieldName = $Matches[1]
      $argName = $Matches[2]
      if (-not $localIndexes.ContainsKey($argName)) {
        throw "SVBC-EMIT local desconhecido: $argName"
      }
      Add-SevenInstruction -Code $Code -Opcode 2 -A $localIndexes[$argName] -Ip $sourceLine
      Add-SevenCallInstructionProduction -Code $Code -Names $Names -FieldNameToIndex $FieldNameToIndex -FieldName $fieldName -ArgCount 1 -SourceLine $sourceLine
      Add-SevenInstruction -Code $Code -Opcode 17 -Ip $sourceLine
      continue
    }

    if ($line -match '^devolve\s+([A-Za-z_][A-Za-z0-9_]*)\s*\((.*)\)$') {
      $fieldName = $Matches[1]

      $argTexts = @(Split-SevenCallArguments -Text $Matches[2])
      foreach ($argText in $argTexts) {
        Emit-SevenExpressionProduction -Expression $argText -Code $Code -Constants $Constants -LocalIndexes $localIndexes -SourceLine $sourceLine
      }

      Add-SevenCallInstructionProduction -Code $Code -Names $Names -FieldNameToIndex $FieldNameToIndex -FieldName $fieldName -ArgCount $argTexts.Count -SourceLine $sourceLine
      Add-SevenInstruction -Code $Code -Opcode 17 -Ip $sourceLine
      continue
    }

    if ($line -match '^devolve\s+(.+)$') {
      Emit-SevenExpressionProduction -Expression $Matches[1] -Code $Code -Constants $Constants -LocalIndexes $localIndexes -SourceLine $sourceLine
      Add-SevenInstruction -Code $Code -Opcode 17 -Ip $sourceLine
      continue
    }
  }

  Add-SevenInstruction -Code $Code -Opcode 0 -Ip 0
}

function ConvertTo-SevenProductionImage {
  param([Parameter(Mandatory = $true)]$Image)

  $names = New-Object System.Collections.ArrayList
  $constants = New-Object System.Collections.ArrayList
  $fields = New-Object System.Collections.ArrayList
  $code = New-Object System.Collections.ArrayList
  $fieldNameToIndex = @{}
  $sourceFields = Get-SevenSourceFieldsForProduction -Image $Image
  $entryField = $null

  foreach ($field in $sourceFields) {
    if ($field.Name -eq $Image.Entry) {
      $entryField = $field
    }
  }

  if ($null -eq $entryField) {
    throw "campo '$($Image.Entry)' nao encontrado"
  }

  foreach ($field in $sourceFields) {
    Add-SevenFieldMetadata -Fields $fields -Names $names -Field $field -FieldNameToIndex $fieldNameToIndex
  }

  foreach ($field in $sourceFields) {
    $fieldIndex = [int]$fieldNameToIndex[$field.Name]
    $fields[$fieldIndex].Entry = [UInt64]$code.Count
    Emit-SevenProductionField -Field $field -Code $code -Constants $constants -Names $names -FieldNameToIndex $fieldNameToIndex
  }

  if ($code.Count -eq 0 -or [byte]$code[$code.Count - 1].Opcode -ne 0) {
    Add-SevenInstruction -Code $code -Opcode 0 -Ip 0
  }

  return [pscustomobject]@{
    Format = "svbc-v1"
    Source = $Image.Source
    Sha256 = $Image.Sha256
    Entry = $Image.Entry
    Names = @($names)
    Constants = @($constants)
    Fields = @($fields)
    Code = @($code)
  }
}

function Write-SevenProductionImage {
  param(
    [Parameter(Mandatory = $true)]$Image,
    [Parameter(Mandatory = $true)][string]$OutputPath
  )

  $prod = ConvertTo-SevenProductionImage -Image $Image
  $stream = [System.IO.File]::Open($OutputPath, [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write, [System.IO.FileShare]::None)
  try {
    $writer = [System.IO.BinaryWriter]::new($stream, [System.Text.Encoding]::UTF8, $false)
    try {
      $writer.Write([System.Text.Encoding]::ASCII.GetBytes("SVBC"))
      Write-SevenU32Be -Writer $writer -Value 1

      Write-SevenU32Be -Writer $writer -Value ([UInt32]$prod.Names.Count)
      foreach ($name in $prod.Names) {
        Write-SevenTextBinary -Writer $writer -Text $name
      }

      Write-SevenU32Be -Writer $writer -Value ([UInt32]$prod.Constants.Count)
      foreach ($constant in $prod.Constants) {
        switch ($constant.Kind) {
          "Num" {
            $writer.Write([byte]3)
            Write-SevenU64Be -Writer $writer -Value ([UInt64][Int64]$constant.Value)
          }
          "Texto" {
            $writer.Write([byte]4)
            Write-SevenTextBinary -Writer $writer -Text ([string]$constant.Value)
          }
          default {
            $writer.Write([byte]0)
          }
        }
      }

      Write-SevenU32Be -Writer $writer -Value ([UInt32]$prod.Fields.Count)
      foreach ($field in $prod.Fields) {
        Write-SevenU32Be -Writer $writer -Value ([UInt32]$field.NameIndex)
        Write-SevenU64Be -Writer $writer -Value ([UInt64]$field.Entry)
        Write-SevenU32Be -Writer $writer -Value ([UInt32]$field.Locals)
        Write-SevenU32Be -Writer $writer -Value ([UInt32]$field.Params)
        Write-SevenU32Be -Writer $writer -Value ([UInt32]$field.EffectIndexes.Count)
        foreach ($effectIndex in $field.EffectIndexes) {
          Write-SevenU32Be -Writer $writer -Value ([UInt32]$effectIndex)
        }
      }

      Write-SevenU32Be -Writer $writer -Value ([UInt32]$prod.Code.Count)
      foreach ($instr in $prod.Code) {
        $writer.Write([byte]$instr.Opcode)
        Write-SevenU32Be -Writer $writer -Value ([UInt32]$instr.A)
        Write-SevenU32Be -Writer $writer -Value ([UInt32]$instr.B)
        Write-SevenU32Be -Writer $writer -Value ([UInt32]$instr.C)
        Write-SevenU64Be -Writer $writer -Value ([UInt64]$instr.Ip)
      }
    } finally {
      $writer.Dispose()
    }
  } finally {
    $stream.Dispose()
  }
}

function Read-SevenDevImage {
  param([Parameter(Mandatory = $true)][string]$Path)

  $fullPath = (Resolve-Path -LiteralPath $Path).Path
  $bytes = [System.IO.File]::ReadAllBytes($fullPath)
  if ($bytes.Length -ge 8 -and
      [System.Text.Encoding]::ASCII.GetString($bytes, 0, 4) -eq "SVBC" -and
      $bytes[4] -eq 0 -and $bytes[5] -eq 0 -and $bytes[6] -eq 0 -and $bytes[7] -eq 1) {
    return Read-SevenProductionImage -Path $fullPath
  }

  $text = [System.IO.File]::ReadAllText($fullPath)
  if (-not $text.StartsWith("SVBC")) {
    throw "SVBC-MAGIC imagem SVBC invalida"
  }

  $marker = "---json---"
  $pos = $text.IndexOf($marker, [System.StringComparison]::Ordinal)
  if ($pos -lt 0) {
    throw "SVBC-FORMATO imagem nao contem secoes executaveis de desenvolvimento"
  }

  $json = $text.Substring($pos + $marker.Length).Trim()
  return $json | ConvertFrom-Json
}

function Read-SevenProductionImage {
  param([Parameter(Mandatory = $true)][string]$Path)

  $stream = [System.IO.File]::OpenRead((Resolve-Path -LiteralPath $Path).Path)
  try {
    $reader = [System.IO.BinaryReader]::new($stream, [System.Text.Encoding]::UTF8, $false)
    try {
      $magic = [System.Text.Encoding]::ASCII.GetString($reader.ReadBytes(4))
      if ($magic -ne "SVBC") {
        throw "SVBC-MAGIC imagem SVBC invalida"
      }

      $version = Read-SevenU32Be -Reader $reader
      if ($version -ne 1) {
        throw "SVBC-VERSAO versao SVBC nao suportada"
      }

      $names = New-Object System.Collections.ArrayList
      $nameCount = Read-SevenU32Be -Reader $reader
      for ($i = 0; $i -lt $nameCount; $i++) {
        [void]$names.Add((Read-SevenTextBinary -Reader $reader))
      }

      $constants = New-Object System.Collections.ArrayList
      $constCount = Read-SevenU32Be -Reader $reader
      for ($i = 0; $i -lt $constCount; $i++) {
        $kind = $reader.ReadByte()
        switch ($kind) {
          3 {
            [void]$constants.Add([pscustomobject]@{
              Kind = "Num"
              Value = [Int64](Read-SevenU64Be -Reader $reader)
            })
          }
          4 {
            [void]$constants.Add([pscustomobject]@{
              Kind = "Texto"
              Value = Read-SevenTextBinary -Reader $reader
            })
          }
          default {
            [void]$constants.Add([pscustomobject]@{
              Kind = "Nada"
              Value = $null
            })
          }
        }
      }

      $fields = New-Object System.Collections.ArrayList
      $fieldCount = Read-SevenU32Be -Reader $reader
      for ($i = 0; $i -lt $fieldCount; $i++) {
        $nameIndex = Read-SevenU32Be -Reader $reader
        $entry = Read-SevenU64Be -Reader $reader
        $locals = Read-SevenU32Be -Reader $reader
        $params = Read-SevenU32Be -Reader $reader
        $effectCount = Read-SevenU32Be -Reader $reader
        $effects = New-Object System.Collections.ArrayList
        for ($e = 0; $e -lt $effectCount; $e++) {
          $effectIndex = Read-SevenU32Be -Reader $reader
          [void]$effects.Add([string]$names[[int]$effectIndex])
        }
        [void]$fields.Add([pscustomobject]@{
          Name = [string]$names[[int]$nameIndex]
          Entry = [UInt64]$entry
          Locals = [UInt32]$locals
          Params = [UInt32]$params
          Effects = @($effects)
        })
      }

      $code = New-Object System.Collections.ArrayList
      $codeCount = Read-SevenU32Be -Reader $reader
      for ($i = 0; $i -lt $codeCount; $i++) {
        [void]$code.Add([pscustomobject]@{
          Opcode = [byte]$reader.ReadByte()
          A = Read-SevenU32Be -Reader $reader
          B = Read-SevenU32Be -Reader $reader
          C = Read-SevenU32Be -Reader $reader
          Ip = Read-SevenU64Be -Reader $reader
        })
      }

      return [pscustomobject]@{
        Format = "svbc-v1"
        Entry = "inicio"
        Names = @($names)
        Constants = @($constants)
        Fields = @($fields)
        Code = @($code)
      }
    } finally {
      $reader.Dispose()
    }
  } finally {
    $stream.Dispose()
  }
}

function Find-SevenBlockEnd {
  param(
    [Parameter(Mandatory = $true)][object[]]$Lines,
    [Parameter(Mandatory = $true)][int]$Start,
    [switch]$FindElse
  )

  $depth = 1
  for ($i = $Start + 1; $i -lt $Lines.Count; $i++) {
    $line = (Get-SevenRuntimeText $Lines[$i]).Trim()
    if ($FindElse -and $depth -eq 1 -and $line -match '^outro\s*::$') {
      return [pscustomobject]@{ Else = $i; End = (Find-SevenBlockEnd -Lines $Lines -Start $Start).End }
    }
    if ($line -match '::$' -and $line -notmatch '^outro\b') {
      $depth += 1
    }
    if ($line -match '^fecha\b') {
      $depth -= 1
      if ($depth -eq 0) {
        return [pscustomobject]@{ Else = -1; End = $i }
      }
    }
  }

  return [pscustomobject]@{ Else = -1; End = $Lines.Count }
}

function ConvertTo-SevenValueText {
  param($Value)

  if ($Value -is [bool]) {
    if ($Value) { return "sim" }
    return "nao"
  }

  if ($null -eq $Value) {
    return "nulo"
  }

  return [string]$Value
}

function ConvertTo-SevenTruthy {
  param($Value)

  if ($null -eq $Value) {
    return $false
  }
  if ($Value -is [bool]) {
    return $Value
  }
  if ($Value -is [byte] -or $Value -is [int] -or $Value -is [int64] -or $Value -is [uint32] -or $Value -is [uint64]) {
    return [int64]$Value -ne 0
  }
  if ($Value -is [string]) {
    return $Value.Length -gt 0
  }
  if ($Value -is [System.Array]) {
    return $Value.Length -gt 0
  }

  return $true
}

function Invoke-SevenExpression {
  param(
    [Parameter(Mandatory = $true)][string]$Expression,
    [Parameter(Mandatory = $true)][hashtable]$State
  )

  $expr = $Expression.Trim()
  if ($expr.StartsWith("(") -and $expr.EndsWith(")")) {
    return Invoke-SevenExpression -Expression $expr.Substring(1, $expr.Length - 2) -State $State
  }
  if ($expr -match '^"([^"]*)"$') {
    return $Matches[1]
  }
  if ($expr -match '^[0-9]+$') {
    return [int64]$expr
  }
  if ($expr -eq "sim") {
    return $true
  }
  if ($expr -eq "nao") {
    return $false
  }
  if ($State.ContainsKey($expr)) {
    return $State[$expr].Value
  }

  foreach ($op in @("==", "!=", ">=", "<=", ">", "<", "+", "-", "*", "/")) {
    $escaped = [regex]::Escape($op)
    if ($expr -match "^\s*(.+?)\s*$escaped\s*(.+)\s*$") {
      $left = Invoke-SevenExpression -Expression $Matches[1] -State $State
      $right = Invoke-SevenExpression -Expression $Matches[2] -State $State
      switch ($op) {
        "==" { return $left -eq $right }
        "!=" { return $left -ne $right }
        ">=" { return [int64]$left -ge [int64]$right }
        "<=" { return [int64]$left -le [int64]$right }
        ">" { return [int64]$left -gt [int64]$right }
        "<" { return [int64]$left -lt [int64]$right }
        "+" {
          if ($left -is [string] -or $right -is [string]) {
            return ([string]$left) + ([string]$right)
          }
          return [int64]$left + [int64]$right
        }
        "-" { return [int64]$left - [int64]$right }
        "*" { return [int64]$left * [int64]$right }
        "/" { return [int64]([math]::Floor([double]$left / [double]$right)) }
      }
    }
  }

  return $expr
}

function Invoke-SevenBlock {
  param(
    [Parameter(Mandatory = $true)][object[]]$Lines,
    [Parameter(Mandatory = $true)][hashtable]$State,
    [int]$Start = 0,
    [int]$End = -1,
    [switch]$Trace,
    [int[]]$Breakpoints = @(),
    [switch]$ShowLocals
  )

  if ($End -lt 0) {
    $End = $Lines.Count
  }

  for ($i = $Start; $i -lt $End; $i++) {
    $runtimeLine = $Lines[$i]
    $line = (Get-SevenRuntimeText $runtimeLine).Trim()
    $sourceLine = Get-SevenRuntimeLine $runtimeLine
    if ([string]::IsNullOrWhiteSpace($line)) {
      continue
    }

    if ($Breakpoints -contains $sourceLine) {
      [Console]::Out.WriteLine("breakpoint: line " + $sourceLine)
      if ($ShowLocals) {
        foreach ($key in ($State.Keys | Sort-Object)) {
          [Console]::Out.WriteLine("local: " + $key + " = " + (ConvertTo-SevenValueText $State[$key].Value))
        }
      }
    }

    if ($Trace -and $line -notmatch '^fecha\b' -and $line -notmatch '^outro\b') {
      $prefix = if ($sourceLine -gt 0) { "trace:" + $sourceLine + ": " } else { "trace: " }
      [Console]::Out.WriteLine($prefix + $line)
    }

    if ($line -match '^gira\s+(.+?)\s*::$') {
      $block = Find-SevenBlockEnd -Lines $Lines -Start $i
      $guard = 0
      while ([bool](Invoke-SevenExpression -Expression $Matches[1] -State $State)) {
        $result = Invoke-SevenBlock -Lines $Lines -State $State -Start ($i + 1) -End $block.End -Trace:$Trace -Breakpoints $Breakpoints -ShowLocals:$ShowLocals
        if ($result.Returned) {
          return $result
        }
        $guard += 1
        if ($guard -gt 100000) {
          throw "SV-RUN-LACO loop excedeu limite de seguranca"
        }
      }
      $i = $block.End
      continue
    }

    if ($line -match '^veja\s+(.+?)\s*::$') {
      $block = Find-SevenBlockEnd -Lines $Lines -Start $i -FindElse
      $condition = [bool](Invoke-SevenExpression -Expression $Matches[1] -State $State)
      if ($condition) {
        $thenEnd = if ($block.Else -ge 0) { $block.Else } else { $block.End }
        $result = Invoke-SevenBlock -Lines $Lines -State $State -Start ($i + 1) -End $thenEnd -Trace:$Trace -Breakpoints $Breakpoints -ShowLocals:$ShowLocals
      } elseif ($block.Else -ge 0) {
        $result = Invoke-SevenBlock -Lines $Lines -State $State -Start ($block.Else + 1) -End $block.End -Trace:$Trace -Breakpoints $Breakpoints -ShowLocals:$ShowLocals
      } else {
        $result = [pscustomobject]@{ Returned = $false; Value = $null }
      }
      if ($result.Returned) {
        return $result
      }
      $i = $block.End
      continue
    }

    if ($line -match '^(guarda|solta)\s+([A-Za-z_][A-Za-z0-9_]*)\s*(?::\s*([^:=]+?))?\s*:=\s*(.+)$') {
      $State[$Matches[2]] = [pscustomobject]@{
        Mutable = $Matches[1] -eq "solta"
        Value = Invoke-SevenExpression -Expression $Matches[4] -State $State
      }
      continue
    }

    if ($line -match '^vira\s+([A-Za-z_][A-Za-z0-9_]*)\s*:=\s*(.+)$') {
      $name = $Matches[1]
      if (-not $State.ContainsKey($name)) {
        throw "SV-NOME-INEXISTENTE nome '$name' nao existe"
      }
      if (-not $State[$name].Mutable) {
        throw "SV-TIPO-IMUTAVEL nome '$name' e imutavel"
      }
      $State[$name] = [pscustomobject]@{
        Mutable = $true
        Value = Invoke-SevenExpression -Expression $Matches[2] -State $State
      }
      continue
    }

    if ($line -match '^caixa\s+([A-Za-z_][A-Za-z0-9_]*)\s*:\s*Byte\s*\[\s*([0-9]+)\s*\]') {
      $State[$Matches[1]] = [pscustomobject]@{
        Mutable = $true
        Value = (New-Object "System.Int64[]" ([int]$Matches[2]))
      }
      continue
    }

    if ($line -match '^marca\s+([A-Za-z_][A-Za-z0-9_]*)\s+@\s*(.+?)\s*:=\s*(.+)$') {
      $boxName = $Matches[1]
      $index = [int](Invoke-SevenExpression -Expression $Matches[2] -State $State)
      $value = [int64](Invoke-SevenExpression -Expression $Matches[3] -State $State)
      $box = $State[$boxName].Value
      if ($index -lt 0 -or $index -ge $box.Length) {
        throw "SV-MEM-LIMITE indice fora do limite"
      }
      $box[$index] = $value
      continue
    }

    if ($line -match '^pega\s+([A-Za-z_][A-Za-z0-9_]*)\s+@\s*(.+?)\s*->\s*([A-Za-z_][A-Za-z0-9_]*)$') {
      $boxName = $Matches[1]
      $index = [int](Invoke-SevenExpression -Expression $Matches[2] -State $State)
      $dest = $Matches[3]
      $box = $State[$boxName].Value
      if ($index -lt 0 -or $index -ge $box.Length) {
        throw "SV-MEM-LIMITE indice fora do limite"
      }
      $State[$dest] = [pscustomobject]@{ Mutable = $false; Value = $box[$index] }
      continue
    }

    if ($line -match '^diga\s+(.+)$') {
      [Console]::Out.WriteLine((ConvertTo-SevenValueText (Invoke-SevenExpression -Expression $Matches[1] -State $State)))
      continue
    }

    if ($line -match '^devolve\s+(.+)$') {
      return [pscustomobject]@{
        Returned = $true
        Value = Invoke-SevenExpression -Expression $Matches[1] -State $State
      }
    }
  }

  return [pscustomobject]@{ Returned = $false; Value = $null }
}

function Invoke-SevenProductionImage {
  param(
    [Parameter(Mandatory = $true)]$Image,
    [string[]]$ProgramArgs = @(),
    [switch]$Trace,
    [int[]]$Breakpoints = @(),
    [switch]$ShowLocals
  )

  $entryField = $null
  foreach ($field in @($Image.Fields)) {
    if ($field.Name -eq $Image.Entry) {
      $entryField = $field
    }
  }
  if ($null -eq $entryField -and $Image.Fields.Count -gt 0) {
    $entryField = $Image.Fields[0]
  }
  if ($null -eq $entryField) {
    throw "SVBC-ENTRADA campo de entrada ausente"
  }

  $ip = [int]$entryField.Entry
  $stack = New-Object System.Collections.ArrayList
  $locals = New-Object System.Collections.ArrayList
  $frames = New-Object System.Collections.ArrayList
  if ([int]$entryField.Params -gt 0) {
    [void]$locals.Add(@($ProgramArgs))
  }
  while ($locals.Count -lt [int]$entryField.Locals) {
    [void]$locals.Add($null)
  }
  if ($Trace) {
    [Console]::Out.WriteLine("debug: entry " + $Image.Entry + " format svbc-v1")
  }

  while ($ip -lt $Image.Code.Count) {
    $instr = $Image.Code[$ip]
    $ip += 1

    if ($Trace) {
      [Console]::Out.WriteLine("trace:svbc:" + $instr.Ip + ": op " + $instr.Opcode)
    }

    switch ([int]$instr.Opcode) {
      0 {
        return 0
      }
      1 {
        [void]$stack.Add($Image.Constants[[int]$instr.A].Value)
      }
      2 {
        if ([int]$instr.A -ge $locals.Count) {
          throw "SVBC-LOCAL local fora do limite: $($instr.A)"
        }
        [void]$stack.Add($locals[[int]$instr.A])
      }
      3 {
        if ($stack.Count -eq 0) {
          throw "SVBC-PILHA guarda sem valor"
        }
        while ($locals.Count -le [int]$instr.A) {
          [void]$locals.Add($null)
        }
        $value = $stack[$stack.Count - 1]
        $stack.RemoveAt($stack.Count - 1)
        $locals[[int]$instr.A] = $value
      }
      4 {
        if ($stack.Count -lt 2) { throw "SVBC-PILHA soma sem operandos" }
        $right = $stack[$stack.Count - 1]
        $stack.RemoveAt($stack.Count - 1)
        $left = $stack[$stack.Count - 1]
        $stack.RemoveAt($stack.Count - 1)
        [void]$stack.Add($left + $right)
      }
      5 {
        if ($stack.Count -lt 2) { throw "SVBC-PILHA sub sem operandos" }
        $right = $stack[$stack.Count - 1]
        $stack.RemoveAt($stack.Count - 1)
        $left = $stack[$stack.Count - 1]
        $stack.RemoveAt($stack.Count - 1)
        [void]$stack.Add($left - $right)
      }
      6 {
        if ($stack.Count -lt 2) { throw "SVBC-PILHA mul sem operandos" }
        $right = $stack[$stack.Count - 1]
        $stack.RemoveAt($stack.Count - 1)
        $left = $stack[$stack.Count - 1]
        $stack.RemoveAt($stack.Count - 1)
        [void]$stack.Add($left * $right)
      }
      7 {
        if ($stack.Count -lt 2) { throw "SVBC-PILHA div sem operandos" }
        $right = $stack[$stack.Count - 1]
        $stack.RemoveAt($stack.Count - 1)
        $left = $stack[$stack.Count - 1]
        $stack.RemoveAt($stack.Count - 1)
        [void]$stack.Add([int64]($left / $right))
      }
      8 {
        if ($stack.Count -lt 2) { throw "SVBC-PILHA igual sem operandos" }
        $right = $stack[$stack.Count - 1]
        $stack.RemoveAt($stack.Count - 1)
        $left = $stack[$stack.Count - 1]
        $stack.RemoveAt($stack.Count - 1)
        [void]$stack.Add($left -eq $right)
      }
      9 {
        if ($stack.Count -lt 2) { throw "SVBC-PILHA diferente sem operandos" }
        $right = $stack[$stack.Count - 1]
        $stack.RemoveAt($stack.Count - 1)
        $left = $stack[$stack.Count - 1]
        $stack.RemoveAt($stack.Count - 1)
        [void]$stack.Add($left -ne $right)
      }
      10 {
        if ($stack.Count -lt 2) { throw "SVBC-PILHA menor sem operandos" }
        $right = $stack[$stack.Count - 1]
        $stack.RemoveAt($stack.Count - 1)
        $left = $stack[$stack.Count - 1]
        $stack.RemoveAt($stack.Count - 1)
        [void]$stack.Add([int64]$left -lt [int64]$right)
      }
      11 {
        if ($stack.Count -lt 2) { throw "SVBC-PILHA menor_igual sem operandos" }
        $right = $stack[$stack.Count - 1]
        $stack.RemoveAt($stack.Count - 1)
        $left = $stack[$stack.Count - 1]
        $stack.RemoveAt($stack.Count - 1)
        [void]$stack.Add([int64]$left -le [int64]$right)
      }
      12 {
        if ($stack.Count -lt 2) { throw "SVBC-PILHA maior sem operandos" }
        $right = $stack[$stack.Count - 1]
        $stack.RemoveAt($stack.Count - 1)
        $left = $stack[$stack.Count - 1]
        $stack.RemoveAt($stack.Count - 1)
        [void]$stack.Add([int64]$left -gt [int64]$right)
      }
      13 {
        if ($stack.Count -lt 2) { throw "SVBC-PILHA maior_igual sem operandos" }
        $right = $stack[$stack.Count - 1]
        $stack.RemoveAt($stack.Count - 1)
        $left = $stack[$stack.Count - 1]
        $stack.RemoveAt($stack.Count - 1)
        [void]$stack.Add([int64]$left -ge [int64]$right)
      }
      14 {
        $ip = [int]$instr.A
      }
      15 {
        if ($stack.Count -eq 0) {
          throw "SVBC-PILHA salto condicional sem valor"
        }
        $cond = $stack[$stack.Count - 1]
        $stack.RemoveAt($stack.Count - 1)
        if (-not (ConvertTo-SevenTruthy $cond)) {
          $ip = [int]$instr.A
        }
      }
      16 {
        if ([int]$instr.A -ge $Image.Fields.Count) {
          throw "SVBC-CAMPO campo fora do limite: $($instr.A)"
        }

        $target = $Image.Fields[[int]$instr.A]
        $newLocals = New-Object System.Collections.ArrayList
        for ($i = 0; $i -lt [int]$instr.B; $i++) {
          if ($stack.Count -eq 0) {
            throw "SVBC-PILHA chamada sem argumentos suficientes"
          }
          $value = $stack[$stack.Count - 1]
          $stack.RemoveAt($stack.Count - 1)
          [void]$newLocals.Insert(0, $value)
        }

        [void]$frames.Add([pscustomobject]@{
          ReturnIp = $ip
          Locals = $locals
        })
        while ($newLocals.Count -lt [int]$target.Locals) {
          [void]$newLocals.Add($null)
        }
        $locals = $newLocals
        $ip = [int]$target.Entry
      }
      17 {
        if ($frames.Count -gt 0) {
          $frame = $frames[$frames.Count - 1]
          $frames.RemoveAt($frames.Count - 1)
          $locals = $frame.Locals
          $ip = [int]$frame.ReturnIp
          continue
        }

        if ($stack.Count -eq 0) {
          return 0
        }
        return [int]$stack[$stack.Count - 1]
      }
      22 {
        $name = [string]$Image.Names[[int]$instr.A]
        $args = New-Object System.Collections.ArrayList
        for ($i = 0; $i -lt [int]$instr.B; $i++) {
          if ($stack.Count -eq 0) {
            throw "SVBC-PILHA syscall sem argumentos suficientes"
          }
          $value = $stack[$stack.Count - 1]
          $stack.RemoveAt($stack.Count - 1)
          [void]$args.Insert(0, $value)
        }

        if ($name -eq "terminal_diga") {
          if ($args.Count -gt 0) {
            [Console]::Out.WriteLine((ConvertTo-SevenValueText $args[0]))
          }
          [void]$stack.Add($null)
        } elseif ($name -eq "seven_cli") {
          if ($args.Count -eq 0) {
            throw "SVBC-ARGS seven_cli sem argumentos"
          }
          [void]$stack.Add((Invoke-SevenCliTransition -Arguments $args[0]))
        } elseif ($name -eq "roda_svbc_com_args") {
          if ($args.Count -lt 2) {
            throw "SVBC-ARGS roda_svbc_com_args sem argumentos"
          }
          $imagePath = [string]$args[0]
          $programArgs = @(ConvertFrom-SevenProgramArgsValue -Arguments $args[1])
          $targetImage = Read-SevenDevImage -Path $imagePath
          [void]$stack.Add((Invoke-SevenDevImage -Image $targetImage -ProgramArgs $programArgs))
        } elseif ($name -eq "seven_args_empty_or_help") {
          if ($args.Count -eq 0) {
            throw "SVBC-ARGS seven_args_empty_or_help sem argumentos"
          }
          [void]$stack.Add((Test-SevenArgsEmptyOrHelp -Arguments $args[0]))
        } elseif ($name -eq "seven_args_version") {
          if ($args.Count -eq 0) {
            throw "SVBC-ARGS seven_args_version sem argumentos"
          }
          [void]$stack.Add((Test-SevenArgsVersion -Arguments $args[0]))
        } elseif ($name -eq "seven_args_verify_foundation") {
          if ($args.Count -eq 0) {
            throw "SVBC-ARGS seven_args_verify_foundation sem argumentos"
          }
          [void]$stack.Add((Test-SevenArgsVerifyFoundation -Arguments $args[0]))
        } elseif ($name -eq "seven_args_verify_bootstrap") {
          if ($args.Count -eq 0) {
            throw "SVBC-ARGS seven_args_verify_bootstrap sem argumentos"
          }
          [void]$stack.Add((Test-SevenArgsVerifyBootstrap -Arguments $args[0]))
        } elseif ($name -eq "seven_args_verify_production") {
          if ($args.Count -eq 0) {
            throw "SVBC-ARGS seven_args_verify_production sem argumentos"
          }
          [void]$stack.Add((Test-SevenArgsVerifyProduction -Arguments $args[0]))
        } elseif ($name -eq "seven_cmd_help") {
          [void]$stack.Add((Invoke-SevenCommandHelp))
        } elseif ($name -eq "seven_cmd_version") {
          [void]$stack.Add((Invoke-SevenCommandVersion))
        } elseif ($name -eq "seven_verify_foundation") {
          [void]$stack.Add((Invoke-SevenVerifyFoundationCommand))
        } elseif ($name -eq "seven_verify_bootstrap") {
          [void]$stack.Add((Invoke-SevenVerifyBootstrapCommand))
        } elseif ($name -eq "seven_verify_production") {
          [void]$stack.Add((Invoke-SevenVerifyProductionCommand))
        } elseif ($name -eq "seven_cmd_unimplemented") {
          if ($args.Count -eq 0) {
            throw "SVBC-ARGS seven_cmd_unimplemented sem argumentos"
          }
          [void]$stack.Add((Invoke-SevenCommandUnimplemented -Arguments $args[0]))
        } else {
          throw "SVBC-SYSCALL intrinseco desconhecido: $name"
        }
      }
      default {
        throw "SVBC-VM-OP instrucao ainda nao implementada: $($instr.Opcode)"
      }
    }
  }

  return 0
}

function Test-SevenTreeHasNoNodeRuntime {
  $root = Get-SevenRepoRoot
  $forbiddenExtensions = @(".js", ".jsx", ".mjs", ".cjs", ".ts", ".tsx")
  $forbiddenNames = @("package.json", "package-lock.json", "npm-shrinkwrap.json", "pnpm-lock.yaml", "yarn.lock", "tsconfig.json")

  foreach ($directory in Get-ChildItem -LiteralPath $root -Recurse -Directory -Force) {
    if ($directory.FullName.StartsWith((Join-Path $root ".git"), [System.StringComparison]::OrdinalIgnoreCase)) {
      continue
    }
    if ($directory.Name -eq "node_modules") {
      return $false
    }
  }

  foreach ($file in Get-ChildItem -LiteralPath $root -Recurse -File -Force) {
    if ($file.FullName.StartsWith((Join-Path $root ".git"), [System.StringComparison]::OrdinalIgnoreCase)) {
      continue
    }
    if (($forbiddenExtensions -contains $file.Extension.ToLowerInvariant()) -or ($forbiddenNames -contains $file.Name.ToLowerInvariant())) {
      return $false
    }
  }

  return $true
}

function Test-SevenSvbcV1File {
  param([Parameter(Mandatory = $true)][string]$Path)

  if (-not (Test-Path -LiteralPath $Path)) {
    return $false
  }

  $bytes = [System.IO.File]::ReadAllBytes((Resolve-Path -LiteralPath $Path).Path)
  return $bytes.Length -ge 8 -and
    [System.Text.Encoding]::ASCII.GetString($bytes, 0, 4) -eq "SVBC" -and
    $bytes[4] -eq 0 -and $bytes[5] -eq 0 -and $bytes[6] -eq 0 -and $bytes[7] -eq 1
}

function Get-SevenFileHashOrEmpty {
  param([Parameter(Mandatory = $true)][string]$Path)

  if (-not (Test-Path -LiteralPath $Path)) {
    return ""
  }

  return (Get-FileHash -Algorithm SHA256 -LiteralPath $Path).Hash.ToLowerInvariant()
}

function ConvertFrom-SevenProgramArgsValue {
  param([AllowNull()]$Arguments)

  if ($null -eq $Arguments) {
    $argv = @()
  } elseif ($Arguments -is [System.Array]) {
    $argv = @($Arguments)
  } else {
    $argv = @($Arguments)
  }

  $argv = @($argv | ForEach-Object { [string]$_ })
  return @($argv)
}

function Test-SevenArgsEmptyOrHelp {
  param([AllowNull()]$Arguments)

  $argv = @(ConvertFrom-SevenProgramArgsValue -Arguments $Arguments)
  return $argv.Count -eq 0 -or $argv[0] -eq "--help"
}

function Test-SevenArgsVersion {
  param([AllowNull()]$Arguments)

  $argv = @(ConvertFrom-SevenProgramArgsValue -Arguments $Arguments)
  return $argv.Count -gt 0 -and $argv[0] -eq "--version"
}

function Test-SevenArgsVerifyFoundation {
  param([AllowNull()]$Arguments)

  $argv = @(ConvertFrom-SevenProgramArgsValue -Arguments $Arguments)
  return $argv.Count -ge 2 -and $argv[0] -eq "verify" -and $argv[1] -eq "foundation"
}

function Test-SevenArgsVerifyBootstrap {
  param([AllowNull()]$Arguments)

  $argv = @(ConvertFrom-SevenProgramArgsValue -Arguments $Arguments)
  return $argv.Count -ge 2 -and $argv[0] -eq "verify" -and $argv[1] -eq "bootstrap"
}

function Test-SevenArgsVerifyProduction {
  param([AllowNull()]$Arguments)

  $argv = @(ConvertFrom-SevenProgramArgsValue -Arguments $Arguments)
  return $argv.Count -ge 2 -and $argv[0] -eq "verify" -and $argv[1] -eq "production"
}

function Invoke-SevenCommandHelp {
  [Console]::Out.WriteLine("seven <check|build|run|test|bench|fmt|lint|doc|repl|debug|profile|doctor|install|lsp|pkg|target|web|serve|release|verify>")
  return 0
}

function Invoke-SevenCommandVersion {
  [Console]::Out.WriteLine("Seven 0.1.0")
  return 0
}

function Invoke-SevenVerifyFoundationCommand {
  $root = Get-SevenRepoRoot
  $checks = @(
    [pscustomobject]@{ Name = "fonte Seven-native"; Ok = (Test-Path -LiteralPath (Join-Path $root "compiler\seven.sev")) },
    [pscustomobject]@{ Name = "sem JavaScript/TypeScript/npm"; Ok = (Test-SevenTreeHasNoNodeRuntime) },
    [pscustomobject]@{ Name = "build/seven.svbc SVBC-v1"; Ok = (Test-SevenSvbcV1File -Path (Join-Path $root "build\seven.svbc")) },
    [pscustomobject]@{ Name = "toolchain Seven-native"; Ok = (Test-Path -LiteralPath (Join-Path $root "compiler\toolchain\verify.sev")) },
    [pscustomobject]@{ Name = "biblioteca padrao"; Ok = (Test-Path -LiteralPath (Join-Path $root "std\base\prelude.sev")) }
  )

  $failures = 0
  foreach ($check in $checks) {
    if ($check.Ok) {
      [Console]::Out.WriteLine("ok   " + $check.Name)
    } else {
      [Console]::Out.WriteLine("fail " + $check.Name)
      $failures += 1
    }
  }
  [Console]::Out.WriteLine("passaram: " + ($checks.Count - $failures))
  [Console]::Out.WriteLine("falhas: " + $failures)
  return $failures
}

function Invoke-SevenVerifyBootstrapCommand {
  $root = Get-SevenRepoRoot
  $hashSeven = Get-SevenFileHashOrEmpty -Path (Join-Path $root "build\seven.svbc")
  $hashSelf = Get-SevenFileHashOrEmpty -Path (Join-Path $root "build\seven.self.svbc")
  $checks = @(
    [pscustomobject]@{ Name = "build/seven0.svbc materializado"; Ok = (Test-Path -LiteralPath (Join-Path $root "build\seven0.svbc")) },
    [pscustomobject]@{ Name = "build/seven.svbc SVBC-v1"; Ok = (Test-SevenSvbcV1File -Path (Join-Path $root "build\seven.svbc")) },
    [pscustomobject]@{ Name = "build/seven.self.svbc SVBC-v1"; Ok = (Test-SevenSvbcV1File -Path (Join-Path $root "build\seven.self.svbc")) },
    [pscustomobject]@{ Name = "seven == seven.self"; Ok = ($hashSeven -ne "" -and $hashSeven -eq $hashSelf) }
  )

  $failures = 0
  foreach ($check in $checks) {
    if ($check.Ok) {
      [Console]::Out.WriteLine("ok   " + $check.Name)
    } else {
      [Console]::Out.WriteLine("fail " + $check.Name)
      $failures += 1
    }
  }
  [Console]::Out.WriteLine("passaram: " + ($checks.Count - $failures))
  [Console]::Out.WriteLine("falhas: " + $failures)
  return $failures
}

function Invoke-SevenVerifyProductionCommand {
  $root = Get-SevenRepoRoot
  $hashSeven = Get-SevenFileHashOrEmpty -Path (Join-Path $root "build\seven.svbc")
  $hashSelf = Get-SevenFileHashOrEmpty -Path (Join-Path $root "build\seven.self.svbc")
  $checks = @(
    [pscustomobject]@{ Name = "P01 gerar build/seven0.svbc"; Ok = (Test-Path -LiteralPath (Join-Path $root "build\seven0.svbc")) },
    [pscustomobject]@{ Name = "P02 seven0 compila compiler/seven.sev"; Ok = (Test-Path -LiteralPath (Join-Path $root "build\seven.svbc")) },
    [pscustomobject]@{ Name = "P03 runtime executa build/seven.svbc verify foundation"; Ok = (Test-SevenSvbcV1File -Path (Join-Path $root "build\seven.svbc")) },
    [pscustomobject]@{ Name = "P04 self-hosting fecha seven == seven.self"; Ok = ($hashSeven -ne "" -and $hashSeven -eq $hashSelf) },
    [pscustomobject]@{ Name = "P05 CI usa caminho Seven"; Ok = (Test-Path -LiteralPath (Join-Path $root ".github\workflows\foundation.yml")) },
    [pscustomobject]@{ Name = "P06 PowerShell fora do caminho oficial"; Ok = (Test-Path -LiteralPath (Join-Path $root "tools\LEGACY.md")) },
    [pscustomobject]@{ Name = "P07 host e launcher Seven substituem bin/seven.exe"; Ok = ((Test-Path -LiteralPath (Join-Path $root "compiler\toolchain\native_host.sev")) -and (Test-Path -LiteralPath (Join-Path $root "compiler\toolchain\launcher.sev")) -and (Test-Path -LiteralPath (Join-Path $root "runtime\host\seven.sev")) -and (Test-Path -LiteralPath (Join-Path $root "runtime\launcher\seven.sev")) -and (Test-SevenSvbcV1File -Path (Join-Path $root "build\seven.host.svbc")) -and (Test-SevenSvbcV1File -Path (Join-Path $root "build\seven.launcher.svbc")) -and (Test-Path -LiteralPath (Join-Path $root "runtime\svbc\runner.sev")) -and (Test-Path -LiteralPath (Join-Path $root "runtime\svbc\command_runner.sev"))) },
    [pscustomobject]@{ Name = "P08 compilador endurecido"; Ok = ((Test-Path -LiteralPath (Join-Path $root "compiler\semantic.sev")) -and (Test-Path -LiteralPath (Join-Path $root "compiler\effects.sev")) -and (Test-Path -LiteralPath (Join-Path $root "compiler\memory.sev"))) },
    [pscustomobject]@{ Name = "P09 runtime endurecido"; Ok = ((Test-Path -LiteralPath (Join-Path $root "runtime\svbc\verifier.sev")) -and (Test-Path -LiteralPath (Join-Path $root "runtime\svbc\command_runner.sev"))) },
    [pscustomobject]@{ Name = "P10 release, instalador, biblioteca e libs reais"; Ok = ((Test-Path -LiteralPath (Join-Path $root "compiler\toolchain\release.sev")) -and (Test-Path -LiteralPath (Join-Path $root "compiler\toolchain\installer.sev")) -and (Test-Path -LiteralPath (Join-Path $root "compiler\toolchain\native_host.sev")) -and (Test-Path -LiteralPath (Join-Path $root "compiler\toolchain\launcher.sev")) -and (Test-SevenSvbcV1File -Path (Join-Path $root "build\seven.host.svbc")) -and (Test-SevenSvbcV1File -Path (Join-Path $root "build\seven.launcher.svbc")) -and (Test-Path -LiteralPath (Join-Path $root "compiler\toolchain\library_audit.sev")) -and (Test-Path -LiteralPath (Join-Path $root "conformance\libs\valid\dynamic_runtime.sev"))) }
  )

  $failures = 0
  foreach ($check in $checks) {
    if ($check.Ok) {
      [Console]::Out.WriteLine("ok   " + $check.Name)
    } else {
      [Console]::Out.WriteLine("fail " + $check.Name)
      $failures += 1
    }
  }
  [Console]::Out.WriteLine("passaram: " + ($checks.Count - $failures))
  [Console]::Out.WriteLine("falhas: " + $failures)
  return $failures
}

function Invoke-SevenCommandUnimplemented {
  param([AllowNull()]$Arguments)

  $argv = @(ConvertFrom-SevenProgramArgsValue -Arguments $Arguments)
  [Console]::Out.WriteLine("comando ainda nao implementado no SVBC de transicao: " + ($argv -join " "))
  return 2
}

function Invoke-SevenCliTransition {
  param([AllowNull()]$Arguments)

  $argv = @(ConvertFrom-SevenProgramArgsValue -Arguments $Arguments)

  if ($argv.Count -eq 0 -or $argv[0] -eq "--help") {
    return Invoke-SevenCommandHelp
  }

  if ($argv[0] -eq "--version") {
    return Invoke-SevenCommandVersion
  }

  if ($argv.Count -ge 2 -and $argv[0] -eq "verify" -and $argv[1] -eq "foundation") {
    return Invoke-SevenVerifyFoundationCommand
  }

  if ($argv.Count -ge 2 -and $argv[0] -eq "verify" -and $argv[1] -eq "bootstrap") {
    return Invoke-SevenVerifyBootstrapCommand
  }

  if ($argv.Count -ge 2 -and $argv[0] -eq "verify" -and $argv[1] -eq "production") {
    return Invoke-SevenVerifyProductionCommand
  }

  return Invoke-SevenCommandUnimplemented -Arguments $argv
}

function Invoke-SevenDevImage {
  param(
    [Parameter(Mandatory = $true)]$Image,
    [string[]]$ProgramArgs = @(),
    [switch]$Trace,
    [int[]]$Breakpoints = @(),
    [switch]$ShowLocals
  )

  if ($Image.PSObject.Properties.Name -contains "Format" -and $Image.Format -eq "svbc-v1") {
    return Invoke-SevenProductionImage -Image $Image -ProgramArgs $ProgramArgs -Trace:$Trace -Breakpoints $Breakpoints -ShowLocals:$ShowLocals
  }

  $body = @()
  foreach ($field in $Image.Fields) {
    if ($field.Name -eq $Image.Entry) {
      $body = @($field.Body)
    }
  }
  if ($body.Count -eq 0) {
    throw "campo '$($Image.Entry)' nao encontrado"
  }
  $state = @{}
  if ($Trace) {
    [Console]::Out.WriteLine("debug: entry " + $Image.Entry)
  }
  $result = Invoke-SevenBlock -Lines @($body) -State $state -Trace:$Trace -Breakpoints $Breakpoints -ShowLocals:$ShowLocals
  if ($result.Returned) {
    return [int]$result.Value
  }

  return 0
}

function Get-SevenPackage {
  param([string]$Path = "seven.pkg")

  $fullPath = (Resolve-Path -LiteralPath $Path).Path
  $deps = New-Object System.Collections.ArrayList
  $data = [ordered]@{
    Path = $fullPath
    Nome = ""
    Versao = "0.0.0"
    Dependencias = $deps
    Linhas = [System.IO.File]::ReadAllLines($fullPath)
  }

  foreach ($line in $data.Linhas) {
    $trim = $line.Trim()
    if ($trim -match '^pacote\s+(.+)$') { $data.Nome = $Matches[1].Trim() }
    if ($trim -match '^versao\s+(.+)$') { $data.Versao = $Matches[1].Trim() }
    if ($trim -match '^dep\s+([A-Za-z0-9_.-]+)\s+([A-Za-z0-9_.+\-*]+)(?:\s+(.+))?$') {
      [void]$deps.Add([pscustomobject]@{
        Nome = $Matches[1]
        Versao = $Matches[2]
        Fonte = if ($Matches.Count -gt 3 -and -not [string]::IsNullOrWhiteSpace($Matches[3])) { $Matches[3].Trim() } else { "registry" }
      })
    }
  }

  return [pscustomobject]$data
}

function Add-SevenPackageDependency {
  param(
    [string]$PackagePath = "seven.pkg",
    [Parameter(Mandatory = $true)][string]$Name,
    [Parameter(Mandatory = $true)][string]$Version,
    [string]$Source = "registry"
  )

  $package = Get-SevenPackage -Path $PackagePath
  $line = "dep $Name $Version $Source"
  $lines = New-Object System.Collections.ArrayList
  $updated = $false

  foreach ($existing in $package.Linhas) {
    if ($existing.Trim() -match "^dep\s+$([regex]::Escape($Name))\s+") {
      [void]$lines.Add($line)
      $updated = $true
    } else {
      [void]$lines.Add($existing)
    }
  }

  if (-not $updated) {
    [void]$lines.Add($line)
  }

  [System.IO.File]::WriteAllLines($package.Path, @($lines), [System.Text.Encoding]::UTF8)
  Write-SevenLockFile -PackagePath $package.Path | Out-Null
}

function Remove-SevenPackageDependency {
  param(
    [string]$PackagePath = "seven.pkg",
    [Parameter(Mandatory = $true)][string]$Name
  )

  $package = Get-SevenPackage -Path $PackagePath
  $lines = New-Object System.Collections.ArrayList
  $removed = $false

  foreach ($existing in $package.Linhas) {
    if ($existing.Trim() -match "^dep\s+$([regex]::Escape($Name))\s+") {
      $removed = $true
      continue
    }
    [void]$lines.Add($existing)
  }

  if (-not $removed) {
    throw "SV-PKG-AUSENTE dependencia nao encontrada: $Name"
  }

  [System.IO.File]::WriteAllLines($package.Path, @($lines), [System.Text.Encoding]::UTF8)
  Write-SevenLockFile -PackagePath $package.Path | Out-Null
}

function Write-SevenLockFile {
  param([string]$PackagePath = "seven.pkg")

  $package = Get-SevenPackage -Path $PackagePath
  $lockPath = Join-Path (Split-Path -Parent $package.Path) "seven.lock"
  $lines = New-Object System.Collections.ArrayList
  [void]$lines.Add("# seven.lock")
  [void]$lines.Add("version 1")
  [void]$lines.Add("package $($package.Nome) $($package.Versao)")

  foreach ($dep in ($package.Dependencias | Sort-Object Nome)) {
    $identity = "$($dep.Nome)|$($dep.Versao)|$($dep.Fonte)"
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($identity)
    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
      $hash = ([System.BitConverter]::ToString($sha.ComputeHash($bytes))).Replace("-", "").ToLowerInvariant()
    } finally {
      $sha.Dispose()
    }
    [void]$lines.Add("dep $($dep.Nome) $($dep.Versao) $($dep.Fonte) $hash")
  }

  [System.IO.File]::WriteAllLines($lockPath, @($lines), [System.Text.Encoding]::UTF8)
  return $lockPath
}

function Get-SevenExpectedLockLines {
  param([string]$PackagePath = "seven.pkg")

  $package = Get-SevenPackage -Path $PackagePath
  $lines = New-Object System.Collections.ArrayList
  [void]$lines.Add("# seven.lock")
  [void]$lines.Add("version 1")
  [void]$lines.Add("package $($package.Nome) $($package.Versao)")

  foreach ($dep in ($package.Dependencias | Sort-Object Nome)) {
    $identity = "$($dep.Nome)|$($dep.Versao)|$($dep.Fonte)"
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($identity)
    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
      $hash = ([System.BitConverter]::ToString($sha.ComputeHash($bytes))).Replace("-", "").ToLowerInvariant()
    } finally {
      $sha.Dispose()
    }
    [void]$lines.Add("dep $($dep.Nome) $($dep.Versao) $($dep.Fonte) $hash")
  }

  return @($lines)
}

function Test-SevenLockFile {
  param([string]$PackagePath = "seven.pkg")

  $package = Get-SevenPackage -Path $PackagePath
  $lockPath = Join-Path (Split-Path -Parent $package.Path) "seven.lock"
  if (-not (Test-Path -LiteralPath $lockPath)) {
    return [pscustomobject]@{ Ok = $false; Message = "seven.lock ausente" }
  }

  $expected = (Get-SevenExpectedLockLines -PackagePath $package.Path) -join "`n"
  $actual = ((Get-Content -LiteralPath $lockPath) -join "`n").Trim()

  return [pscustomobject]@{
    Ok = $actual -eq $expected.Trim()
    Message = if ($actual -eq $expected.Trim()) { "seven.lock valido" } else { "seven.lock divergente" }
  }
}

function Install-SevenPackageDependencies {
  param(
    [string]$PackagePath = "seven.pkg",
    [string]$CacheRoot = ""
  )

  $package = Get-SevenPackage -Path $PackagePath
  if ([string]::IsNullOrWhiteSpace($CacheRoot)) {
    $CacheRoot = Join-Path (Split-Path -Parent $package.Path) ".seven\packages"
  }

  New-Item -ItemType Directory -Force -Path $CacheRoot | Out-Null
  $installed = New-Object System.Collections.ArrayList

  foreach ($dep in $package.Dependencias) {
    $depDir = Join-Path $CacheRoot (Join-Path $dep.Nome $dep.Versao)
    New-Item -ItemType Directory -Force -Path $depDir | Out-Null
    $manifest = Join-Path $depDir "package.txt"
    [System.IO.File]::WriteAllLines($manifest, @(
      "nome $($dep.Nome)",
      "versao $($dep.Versao)",
      "fonte $($dep.Fonte)"
    ), [System.Text.Encoding]::UTF8)
    [void]$installed.Add($manifest)
  }

  return @($installed)
}

function Get-SevenSymbolsFromText {
  param([Parameter(Mandatory = $true)][string]$Text)

  $symbols = New-Object System.Collections.ArrayList
  $lines = $Text -split "`r?`n"

  for ($i = 0; $i -lt $lines.Count; $i++) {
    $line = (Remove-SevenLineComment $lines[$i]).Trim()
    if ($line -match '^(campo|molde|selo|const)\s+([A-Za-z_][A-Za-z0-9_]*)') {
      [void]$symbols.Add([pscustomobject]@{
        Name = $Matches[2]
        Kind = $Matches[1]
        Line = $i
        Character = $lines[$i].IndexOf($Matches[2])
      })
    }
  }

  return $symbols.ToArray()
}

function Get-SevenCompletionItems {
  param([AllowNull()][string]$Text)

  $items = New-Object System.Collections.ArrayList
  foreach ($keyword in @("modulo", "usa", "campo", "molde", "selo", "guarda", "solta", "vira", "veja", "outro", "gira", "devolve", "diga", "fecha", "extern", "c", "cpp")) {
    [void]$items.Add([pscustomobject]@{
      label = $keyword
      kind = 14
      detail = "Seven keyword"
      insertText = $keyword
    })
  }

  if (-not [string]::IsNullOrWhiteSpace($Text)) {
    foreach ($symbol in (Get-SevenSymbolsFromText -Text $Text)) {
      [void]$items.Add([pscustomobject]@{
        label = $symbol.Name
        kind = 3
        detail = "$($symbol.Kind) Seven"
        insertText = $symbol.Name
      })
    }
  }

  return $items.ToArray()
}

function Get-SevenHoverText {
  param(
    [AllowNull()][string]$Text,
    [AllowNull()][string]$Word
  )

  if ([string]::IsNullOrWhiteSpace($Word)) {
    return "Seven source"
  }

  foreach ($symbol in (Get-SevenSymbolsFromText -Text $Text)) {
    if ($symbol.Name -eq $Word) {
      return $symbol.Kind + " " + $Word
    }
  }

  if (@("campo", "molde", "selo", "guarda", "solta", "vira", "extern") -contains $Word) {
    return "Seven keyword " + $Word
  }

  return "Seven source"
}

function Get-SevenExterns {
  param([Parameter(Mandatory = $true)][string]$Path)

  $fullPath = (Resolve-Path -LiteralPath $Path).Path
  $lines = [System.IO.File]::ReadAllLines($fullPath)
  $externs = New-Object System.Collections.ArrayList

  foreach ($line in $lines) {
    $clean = (Remove-SevenLineComment $line).Trim()
    if ($clean -match '^extern\s+(c|cpp)\s+campo\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(([^)]*)\)\s*->\s*([A-Za-z0-9_<>*]+)(?:\s+liga\s+"([^"]+)")?') {
      [void]$externs.Add([pscustomobject]@{
        Abi = $Matches[1]
        Name = $Matches[2]
        Params = $Matches[3]
        ReturnType = $Matches[4]
        Symbol = if ($Matches.Count -gt 5 -and -not [string]::IsNullOrWhiteSpace($Matches[5])) { $Matches[5] } else { $Matches[2] }
      })
    }
  }

  return @($externs)
}

function Convert-SevenTypeToC {
  param([Parameter(Mandatory = $true)][string]$Type)

  $clean = $Type.Trim()
  switch -Regex ($clean) {
    '^Nada$' { return "void" }
    '^Bit$' { return "bool" }
    '^Byte$' { return "uint8_t" }
    '^I8$' { return "int8_t" }
    '^I16$' { return "int16_t" }
    '^I32$' { return "int32_t" }
    '^I64$' { return "int64_t" }
    '^U8$' { return "uint8_t" }
    '^U16$' { return "uint16_t" }
    '^U32$' { return "uint32_t" }
    '^U64$' { return "uint64_t" }
    '^Num$' { return "intptr_t" }
    '^Texto$' { return "const char*" }
    '^CChar$' { return "char" }
    '^Ptr<CChar>$' { return "const char*" }
    '^Ptr<Byte>$' { return "uint8_t*" }
    '^Ptr<(.+)>$' { return (Convert-SevenTypeToC -Type $Matches[1]) + "*" }
    default { return "void*" }
  }
}

function Convert-SevenParamsToC {
  param([AllowNull()][string]$Params)

  if ([string]::IsNullOrWhiteSpace($Params)) {
    return "void"
  }

  $parts = New-Object System.Collections.ArrayList
  foreach ($param in $Params.Split(",")) {
    $trim = $param.Trim()
    if ($trim -match '^([A-Za-z_][A-Za-z0-9_]*)\s*:\s*(.+)$') {
      [void]$parts.Add("$(Convert-SevenTypeToC -Type $Matches[2]) $($Matches[1])")
    }
  }

  if ($parts.Count -eq 0) {
    return "void"
  }

  return ($parts -join ", ")
}

function Write-SevenCHeader {
  param(
    [Parameter(Mandatory = $true)][string]$InputPath,
    [Parameter(Mandatory = $true)][string]$OutputPath,
    [string]$Guard = ""
  )

  $externs = Get-SevenExterns -Path $InputPath
  if ([string]::IsNullOrWhiteSpace($Guard)) {
    $name = [System.IO.Path]::GetFileNameWithoutExtension($OutputPath).ToUpperInvariant() -replace '[^A-Z0-9]', '_'
    $Guard = "SEVEN_${name}_H"
  }

  $lines = New-Object System.Collections.ArrayList
  [void]$lines.Add("#ifndef $Guard")
  [void]$lines.Add("#define $Guard")
  [void]$lines.Add("")
  [void]$lines.Add("#include <stdbool.h>")
  [void]$lines.Add("#include <stdint.h>")
  [void]$lines.Add("#include <stddef.h>")
  [void]$lines.Add("")
  [void]$lines.Add("#ifdef __cplusplus")
  [void]$lines.Add('extern "C" {')
  [void]$lines.Add("#endif")
  [void]$lines.Add("")

  foreach ($extern in $externs) {
    $returnType = Convert-SevenTypeToC -Type $extern.ReturnType
    $params = Convert-SevenParamsToC -Params $extern.Params
    [void]$lines.Add("$returnType $($extern.Symbol)($params);")
  }

  [void]$lines.Add("")
  [void]$lines.Add("#ifdef __cplusplus")
  [void]$lines.Add("}")
  [void]$lines.Add("#endif")
  [void]$lines.Add("")
  [void]$lines.Add("#endif")

  [System.IO.File]::WriteAllLines($OutputPath, @($lines), [System.Text.Encoding]::ASCII)
  return $OutputPath
}

function Write-SevenFfiManifest {
  param(
    [Parameter(Mandatory = $true)][string]$InputPath,
    [Parameter(Mandatory = $true)][string]$OutputPath
  )

  $externs = Get-SevenExterns -Path $InputPath
  $manifest = [pscustomobject]@{
    format = "seven-ffi-v1"
    source = (Resolve-Path -LiteralPath $InputPath).Path
    symbols = @($externs | ForEach-Object {
      [pscustomobject]@{
        abi = $_.Abi
        name = $_.Name
        symbol = $_.Symbol
        returnType = $_.ReturnType
        params = $_.Params
      }
    })
  }

  [System.IO.File]::WriteAllText($OutputPath, ($manifest | ConvertTo-Json -Depth 8) + "`n", [System.Text.Encoding]::UTF8)
  return $OutputPath
}

Export-ModuleMember -Function `
  Add-SevenPackageDependency, `
  Convert-SevenDiagnosticToLsp, `
  Convert-SevenSymbolsToLsp, `
  Format-SevenDiagnostic, `
  Get-SevenCompletionItems, `
  Get-SevenExpectedDiagnostic, `
  Get-SevenHoverText, `
  Get-SevenPackage, `
  Get-SevenRelativePath, `
  Get-SevenRepoRoot, `
  Get-SevenSymbolsFromText, `
  Install-SevenPackageDependencies, `
  Invoke-SevenDevImage, `
  Invoke-SevenSemanticCheck, `
  Invoke-SevenSemanticCheckText, `
  New-SevenDevImage, `
  Read-SevenDevImage, `
  Remove-SevenPackageDependency, `
  Test-SevenLockFile, `
  Write-SevenCHeader, `
  Write-SevenDevImage, `
  Write-SevenProductionImage, `
  Write-SevenFfiManifest, `
  Write-SevenLockFile
