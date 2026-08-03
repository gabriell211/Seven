[CmdletBinding()]
param(
  [string]$SevenPath = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$DevCli = Join-Path $Root "tools\seven-dev.ps1"
$LspCli = Join-Path $Root "tools\seven-lsp.ps1"

if ([string]::IsNullOrWhiteSpace($SevenPath)) {
  $SevenPath = Join-Path $Root "bin\seven.exe"
}

$SevenPath = (Resolve-Path -LiteralPath $SevenPath).Path

$script:Passed = 0
$script:Failures = New-Object System.Collections.Generic.List[string]
$script:KnownGaps = New-Object System.Collections.Generic.List[string]

function Write-Step {
  param([string]$Message)

  Write-Host ""
  Write-Host "== $Message =="
}

function Write-OutputBlock {
  param([string]$Output)

  if (-not [string]::IsNullOrWhiteSpace($Output)) {
    Write-Host $Output
  }
}

function Add-Pass {
  param([string]$Message)

  $script:Passed += 1
  Write-Host "ok   $Message"
}

function Add-Failure {
  param([string]$Message, [string]$Output = "")

  [void]$script:Failures.Add($Message)
  Write-Host "fail $Message"
  Write-OutputBlock $Output
}

function Add-KnownGap {
  param([string]$Message, [string]$Output = "")

  [void]$script:KnownGaps.Add($Message)
  Write-Host "gap  $Message"
  Write-OutputBlock $Output
}

function Get-RepoRelativePath {
  param([string]$Path)

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

function Invoke-Seven {
  param([Parameter(Mandatory = $true)][string[]]$SevenArgs)

  $output = & $SevenPath @SevenArgs 2>&1
  $exitCode = $LASTEXITCODE
  $text = ($output | ForEach-Object { $_.ToString() }) -join [Environment]::NewLine

  return [pscustomobject]@{
    ExitCode = $exitCode
    Output = $text
  }
}

function Invoke-SevenDev {
  param([Parameter(Mandatory = $true)][string[]]$DevArgs)

  $output = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $DevCli @DevArgs 2>&1
  $exitCode = $LASTEXITCODE
  $text = ($output | ForEach-Object { $_.ToString() }) -join [Environment]::NewLine

  return [pscustomobject]@{
    ExitCode = $exitCode
    Output = $text
  }
}

function Invoke-SevenLspSelfTest {
  param([Parameter(Mandatory = $true)][string]$File)

  $output = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $LspCli -SelfTest -File $File 2>&1
  $exitCode = $LASTEXITCODE
  $text = ($output | ForEach-Object { $_.ToString() }) -join [Environment]::NewLine

  return [pscustomobject]@{
    ExitCode = $exitCode
    Output = $text
  }
}

function Test-OutputContains {
  param(
    [Parameter(Mandatory = $true)]$Result,
    [Parameter(Mandatory = $true)][string]$Expected
  )

  return $Result.Output.Contains($Expected)
}

function Test-SvbcEnvelope {
  param([Parameter(Mandatory = $true)][string]$Path)

  if (-not (Test-Path -LiteralPath $Path)) {
    return $false
  }

  $bytes = [System.IO.File]::ReadAllBytes($Path)
  if ($bytes.Length -lt 4) {
    return $false
  }

  $magic = [System.Text.Encoding]::ASCII.GetString($bytes, 0, 4)
  return $magic -eq "SVBC"
}

function Get-ExpectedDiagnostic {
  param([Parameter(Mandatory = $true)][System.IO.FileInfo]$File)

  foreach ($line in [System.IO.File]::ReadLines($File.FullName)) {
    if ($line -match "espera:\s*([A-Z0-9]+(?:-[A-Z0-9]+)+)") {
      return $Matches[1]
    }
  }

  return ""
}

Write-Step "Bootstrap CLI"

$version = Invoke-Seven -SevenArgs @("--version")
if ($version.ExitCode -eq 0 -and (Test-OutputContains -Result $version -Expected "Seven 0.1.0")) {
  Add-Pass "seven --version"
} else {
  Add-Failure "seven --version nao retornou a versao esperada" $version.Output
}

$help = Invoke-Seven -SevenArgs @("--help")
if ($help.ExitCode -eq 0 -and (Test-OutputContains -Result $help -Expected "seven check <file.sv>")) {
  Add-Pass "seven --help"
} else {
  Add-Failure "seven --help nao publicou os comandos esperados" $help.Output
}

Write-Step "Conformidade valida"

$validFiles = Get-ChildItem -Path (Join-Path $Root "conformance") -Recurse -Filter "*.sv" |
  Where-Object { $_.FullName -match "[\\/]valid[\\/]" } |
  Sort-Object FullName

foreach ($file in $validFiles) {
  $relative = Get-RepoRelativePath $file.FullName
  $result = Invoke-SevenDev -DevArgs @("check", $file.FullName)

  if ($result.ExitCode -eq 0 -and $result.Output.StartsWith("ok:")) {
    Add-Pass "check $relative"
  } else {
    Add-Failure "check $relative deveria passar" $result.Output
  }
}

Write-Step "Build SVBC"

$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("seven-foundation-" + [System.Guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Force -Path $tempRoot | Out-Null

try {
  $buildInputs = @(
    (Join-Path $Root "examples\hello.sv"),
    (Join-Path $Root "conformance\valid\hello.sv")
  )

  foreach ($inputPath in $buildInputs) {
    $relative = Get-RepoRelativePath $inputPath
    $outputPath = Join-Path $tempRoot ((Split-Path -Leaf $inputPath) + ".svbc")
    $result = Invoke-SevenDev -DevArgs @("build", $inputPath, $outputPath)

    if ($result.ExitCode -ne 0) {
      Add-Failure "build $relative deveria passar" $result.Output
      continue
    }

    if (-not (Test-SvbcEnvelope -Path $outputPath)) {
      Add-Failure "build $relative nao gerou envelope SVBC valido" $result.Output
      continue
    }

    Add-Pass "build $relative -> SVBC"
  }
} finally {
  Remove-Item -LiteralPath $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Step "Run smoke"

$runInput = Join-Path $Root "examples\hello.sv"
$run = Invoke-SevenDev -DevArgs @("run", $runInput)
if ($run.ExitCode -ne 0) {
  Add-Failure "run examples/hello.sv deveria passar" $run.Output
} elseif (-not (Test-OutputContains -Result $run -Expected "Seven nasceu.")) {
  Add-Failure "run examples/hello.sv nao executou saida esperada" $run.Output
} else {
  Add-Pass "run examples/hello.sv executa na VM de desenvolvimento"
}

$runControl = Invoke-SevenDev -DevArgs @("run", (Join-Path $Root "examples\control.sv"))
if ($runControl.ExitCode -ne 0) {
  Add-Failure "run examples/control.sv deveria passar" $runControl.Output
} elseif (-not (Test-OutputContains -Result $runControl -Expected "ciclo completo")) {
  Add-Failure "run examples/control.sv nao executou controle de fluxo" $runControl.Output
} else {
  Add-Pass "run examples/control.sv executa controle de fluxo"
}

$debugControl = Invoke-SevenDev -DevArgs @("debug", (Join-Path $Root "examples\control.sv"), "--break", "8", "--locals")
if ($debugControl.ExitCode -ne 0) {
  Add-Failure "debug examples/control.sv deveria passar" $debugControl.Output
} elseif (-not (Test-OutputContains -Result $debugControl -Expected "breakpoint: line 8")) {
  Add-Failure "debug examples/control.sv nao parou no breakpoint" $debugControl.Output
} elseif (-not (Test-OutputContains -Result $debugControl -Expected "local: energia = 3")) {
  Add-Failure "debug examples/control.sv nao mostrou locals" $debugControl.Output
} else {
  Add-Pass "debug examples/control.sv emite breakpoint e locals"
}

Write-Step "Conformidade invalida"

$invalidFiles = Get-ChildItem -Path (Join-Path $Root "conformance") -Recurse -Filter "*.sv" |
  Where-Object { $_.FullName -match "[\\/]invalid[\\/]" } |
  Sort-Object FullName

foreach ($file in $invalidFiles) {
  $relative = Get-RepoRelativePath $file.FullName
  $expected = Get-ExpectedDiagnostic -File $file

  if ([string]::IsNullOrWhiteSpace($expected)) {
    Add-Failure "$relative nao declara comentario espera:"
    continue
  }

  $result = Invoke-SevenDev -DevArgs @("check", $file.FullName)

  if ($result.ExitCode -ne 0 -and $result.Output.Contains($expected)) {
    Add-Pass "check $relative falhou com $expected"
    continue
  }

  Add-Failure "check $relative deveria falhar com $expected" $result.Output
}

Write-Step "Pacotes, LSP e FFI"

$toolTemp = Join-Path ([System.IO.Path]::GetTempPath()) ("seven-tools-" + [System.Guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Force -Path $toolTemp | Out-Null

try {
  Copy-Item -LiteralPath (Join-Path $Root "seven.pkg") -Destination (Join-Path $toolTemp "seven.pkg") -Force

  Push-Location $toolTemp
  try {
    $pkgAdd = Invoke-SevenDev -DevArgs @("pkg", "add", "std.http", "1.0.0", "registry")
  } finally {
    Pop-Location
  }

  $lock = Join-Path $toolTemp "seven.lock"
  if ($pkgAdd.ExitCode -eq 0 -and (Test-Path -LiteralPath $lock) -and (Select-String -LiteralPath $lock -Pattern "dep std.http 1.0.0 registry" -Quiet)) {
    Add-Pass "pkg add gera seven.lock deterministico"
  } else {
    Add-Failure "pkg add deveria gerar seven.lock" $pkgAdd.Output
  }

  Push-Location $toolTemp
  try {
    $pkgVerify = Invoke-SevenDev -DevArgs @("pkg", "verify")
    $pkgInstall = Invoke-SevenDev -DevArgs @("pkg", "install")
    $pkgRemove = Invoke-SevenDev -DevArgs @("pkg", "remove", "std.http")
    $pkgVerifyAfterRemove = Invoke-SevenDev -DevArgs @("pkg", "verify")
  } finally {
    Pop-Location
  }

  $installedManifest = Join-Path $toolTemp ".seven\packages\std.http\1.0.0\package.txt"
  if ($pkgVerify.ExitCode -eq 0 -and (Test-OutputContains -Result $pkgVerify -Expected "ok: seven.lock valido")) {
    Add-Pass "pkg verify valida lockfile"
  } else {
    Add-Failure "pkg verify deveria validar seven.lock" $pkgVerify.Output
  }

  if ($pkgInstall.ExitCode -eq 0 -and (Test-Path -LiteralPath $installedManifest)) {
    Add-Pass "pkg install materializa cache local"
  } else {
    Add-Failure "pkg install deveria materializar cache local" $pkgInstall.Output
  }

  if ($pkgRemove.ExitCode -eq 0 -and $pkgVerifyAfterRemove.ExitCode -eq 0 -and -not (Select-String -LiteralPath (Join-Path $toolTemp "seven.pkg") -Pattern "dep std.http" -Quiet)) {
    Add-Pass "pkg remove atualiza manifesto e lock"
  } else {
    Add-Failure "pkg remove deveria remover dependencia" ($pkgRemove.Output + [Environment]::NewLine + $pkgVerifyAfterRemove.Output)
  }

  $lsp = Invoke-SevenLspSelfTest -File (Join-Path $Root "examples\hello.sv")
  if ($lsp.ExitCode -eq 0 -and (Test-OutputContains -Result $lsp -Expected '"label":  "inicio"') -and (Test-OutputContains -Result $lsp -Expected '"name":  "inicio"')) {
    Add-Pass "LSP self-test publica completions e symbols"
  } else {
    Add-Failure "LSP self-test deveria retornar completion e symbol inicio" $lsp.Output
  }

  $lspInvalid = Invoke-SevenLspSelfTest -File (Join-Path $Root "conformance\invalid\immutable_assign.sv")
  if ($lspInvalid.ExitCode -eq 0 -and (Test-OutputContains -Result $lspInvalid -Expected '"code":  "SV-TIPO-IMUTAVEL"')) {
    Add-Pass "LSP self-test publica diagnosticos"
  } else {
    Add-Failure "LSP self-test deveria publicar diagnostico semantico" $lspInvalid.Output
  }

  $headerPath = Join-Path $toolTemp "interop.h"
  $manifestPath = Join-Path $toolTemp "interop.json"
  $ffi = Invoke-SevenDev -DevArgs @("ffi", "header", (Join-Path $Root "examples\interop-c\main.sv"), $headerPath)
  $ffiManifest = Invoke-SevenDev -DevArgs @("ffi", "manifest", (Join-Path $Root "examples\interop-c\main.sv"), $manifestPath)
  if ($ffi.ExitCode -eq 0 -and (Test-Path -LiteralPath $headerPath)) {
    $header = Get-Content -LiteralPath $headerPath -Raw
    if ($header.Contains('extern "C"') -and $header.Contains("puts(") -and $header.Contains("seven_cpp_version(")) {
      Add-Pass "ffi header gera ponte C/C++"
    } else {
      Add-Failure "ffi header nao contem simbolos esperados" $header
    }
  } else {
    Add-Failure "ffi header deveria gerar arquivo .h" $ffi.Output
  }

  if ($ffiManifest.ExitCode -eq 0 -and (Test-Path -LiteralPath $manifestPath)) {
    $manifest = Get-Content -LiteralPath $manifestPath -Raw
    if ($manifest.Contains('"format":  "seven-ffi-v1"') -and $manifest.Contains('"symbol":  "puts"')) {
      Add-Pass "ffi manifest registra simbolos externos"
    } else {
      Add-Failure "ffi manifest nao contem simbolos esperados" $manifest
    }
  } else {
    Add-Failure "ffi manifest deveria gerar arquivo .json" $ffiManifest.Output
  }
} finally {
  Remove-Item -LiteralPath $toolTemp -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Step "Resumo"
Write-Host "passaram: $script:Passed"
Write-Host "lacunas conhecidas: $($script:KnownGaps.Count)"
Write-Host "falhas: $($script:Failures.Count)"

if ($script:KnownGaps.Count -gt 0) {
  Write-Host ""
  Write-Host "Lacunas conhecidas:"
  foreach ($gap in $script:KnownGaps) {
    Write-Host "- $gap"
  }
}

if ($script:Failures.Count -gt 0) {
  Write-Host ""
  Write-Host "Falhas:"
  foreach ($failure in $script:Failures) {
    Write-Host "- $failure"
  }
  exit 1
}

exit 0
