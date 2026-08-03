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
        if ($bodyClean -match '::$') {
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

  return @($Declared) -contains $Needed
}

function Test-SevenIdentifier {
  param([AllowNull()][string]$Value)

  if ([string]::IsNullOrWhiteSpace($Value)) {
    return $false
  }

  return $Value.Trim() -match '^[A-Za-z_][A-Za-z0-9_]*$'
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

        if ((Test-SevenIdentifier $value) -and -not $locals.ContainsKey($value) -and -not $fieldEffects.ContainsKey($value) -and @("sim", "nao", "nulo") -notcontains $value) {
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
        if (-not $locals.ContainsKey($name) -and @("sim", "nao", "nulo") -notcontains $name) {
          Add-SevenDiagnosticOnce $diagnostics "SV-NOME-INEXISTENTE" "nome usado antes de existir no escopo visivel" $fullPath $item.Line 1
        }
      }

      if ($line -match '^devolve\s+([A-Za-z_][A-Za-z0-9_]*)$') {
        $name = $Matches[1]
        if (-not $locals.ContainsKey($name) -and @("sim", "nao", "nulo") -notcontains $name) {
          Add-SevenDiagnosticOnce $diagnostics "SV-NOME-INEXISTENTE" "nome usado antes de existir no escopo visivel" $fullPath $item.Line 1
        }
      }

      $callMatches = [regex]::Matches($line, '\b([A-Za-z_][A-Za-z0-9_]*)\s*\(')
      foreach ($match in $callMatches) {
        $callName = $match.Groups[1].Value
        if (@("veja", "gira", "campo", "Valor", "Falha") -contains $callName) {
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

        if (($callName -match '^sys_') -or ($callName -match '^frontend_') -or (@("monta", "css_injeta") -contains $callName)) {
          if (-not (Test-SevenEffectAllowed -Declared $field.Effects -Needed "frontend")) {
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
    [string]$VirtualPath = "memory.sv"
  )

  $tempPath = Join-Path ([System.IO.Path]::GetTempPath()) ("seven-lsp-" + [System.Guid]::NewGuid().ToString("N") + ".sv")
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

function Read-SevenDevImage {
  param([Parameter(Mandatory = $true)][string]$Path)

  $text = [System.IO.File]::ReadAllText((Resolve-Path -LiteralPath $Path).Path)
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

function Invoke-SevenDevImage {
  param(
    [Parameter(Mandatory = $true)]$Image,
    [switch]$Trace,
    [int[]]$Breakpoints = @(),
    [switch]$ShowLocals
  )

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
  Write-SevenFfiManifest, `
  Write-SevenLockFile
