[CmdletBinding()]
param(
  [Parameter(Position = 0)][string]$Command = "help",
  [Parameter(ValueFromRemainingArguments = $true)][string[]]$Args
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Import-Module (Join-Path $PSScriptRoot "Seven.Foundation.psm1") -Force

function Show-Help {
  Write-Host "Seven development CLI"
  Write-Host ""
  Write-Host "usage:"
  Write-Host "  seven-dev check <file.sv>"
  Write-Host "  seven-dev build <file.sv> [out.svbc]"
  Write-Host "  seven-dev run <file.sv|file.svbc>"
  Write-Host "  seven-dev debug <file.sv|file.svbc> [--break <line>] [--locals]"
  Write-Host "  seven-dev pkg add <name> <version> [source]"
  Write-Host "  seven-dev pkg remove <name>"
  Write-Host "  seven-dev pkg list [seven.pkg]"
  Write-Host "  seven-dev pkg lock [seven.pkg]"
  Write-Host "  seven-dev pkg verify [seven.pkg]"
  Write-Host "  seven-dev pkg install [seven.pkg]"
  Write-Host "  seven-dev ffi header <file.sv> <out.h>"
  Write-Host "  seven-dev ffi manifest <file.sv> <out.json>"
  Write-Host "  seven-dev lsp"
}

function Invoke-BootstrapCheck {
  param([Parameter(Mandatory = $true)][string]$Path)

  $root = Get-SevenRepoRoot
  $seven = Join-Path $root "bin\seven.exe"
  if (-not (Test-Path -LiteralPath $seven)) {
    return [pscustomobject]@{ ExitCode = 0; Output = "" }
  }

  $output = & $seven check $Path 2>&1
  return [pscustomobject]@{
    ExitCode = $LASTEXITCODE
    Output = (($output | ForEach-Object { $_.ToString() }) -join [Environment]::NewLine)
  }
}

function Invoke-CheckCommand {
  param([Parameter(Mandatory = $true)][string]$Path)

  $fullPath = (Resolve-Path -LiteralPath $Path).Path
  $bootstrap = Invoke-BootstrapCheck -Path $fullPath
  if ($bootstrap.ExitCode -ne 0) {
    if (-not [string]::IsNullOrWhiteSpace($bootstrap.Output)) {
      Write-Host $bootstrap.Output
    }
    exit $bootstrap.ExitCode
  }

  $result = Invoke-SevenSemanticCheck -Path $fullPath
  if (-not $result.Ok) {
    foreach ($diagnostic in $result.Diagnostics) {
      Write-Host (Format-SevenDiagnostic $diagnostic)
    }
    exit 1
  }

  Write-Host "ok: $fullPath"
}

function Invoke-BuildCommand {
  param(
    [Parameter(Mandatory = $true)][string]$InputPath,
    [string]$OutputPath = ""
  )

  $fullPath = (Resolve-Path -LiteralPath $InputPath).Path
  $result = Invoke-SevenSemanticCheck -Path $fullPath
  if (-not $result.Ok) {
    foreach ($diagnostic in $result.Diagnostics) {
      Write-Host (Format-SevenDiagnostic $diagnostic)
    }
    exit 1
  }

  if ([string]::IsNullOrWhiteSpace($OutputPath)) {
    $OutputPath = $fullPath + ".svbc"
  }

  $outFull = [System.IO.Path]::GetFullPath($OutputPath)
  $outDir = Split-Path -Parent $outFull
  if (-not [string]::IsNullOrWhiteSpace($outDir)) {
    New-Item -ItemType Directory -Force -Path $outDir | Out-Null
  }

  $image = New-SevenDevImage -Path $fullPath
  Write-SevenDevImage -Image $image -OutputPath $outFull
  Write-Host "built: $outFull"
}

function Invoke-RunCommand {
  param(
    [Parameter(Mandatory = $true)][string]$InputPath,
    [switch]$Trace,
    [int[]]$Breakpoints = @(),
    [switch]$ShowLocals
  )

  $fullPath = (Resolve-Path -LiteralPath $InputPath).Path
  $temp = $null

  try {
    if ([System.IO.Path]::GetExtension($fullPath) -eq ".sv") {
      $temp = Join-Path ([System.IO.Path]::GetTempPath()) ("seven-run-" + [System.Guid]::NewGuid().ToString("N") + ".svbc")
      $image = New-SevenDevImage -Path $fullPath
      Write-SevenDevImage -Image $image -OutputPath $temp
      $fullPath = $temp
    }

    $loaded = Read-SevenDevImage -Path $fullPath
    $code = Invoke-SevenDevImage -Image $loaded -Trace:$Trace -Breakpoints $Breakpoints -ShowLocals:$ShowLocals
    exit $code
  } finally {
    if ($null -ne $temp) {
      Remove-Item -LiteralPath $temp -Force -ErrorAction SilentlyContinue
    }
  }
}

function Invoke-PackageCommand {
  param([string[]]$Remaining)

  if ($Remaining.Count -eq 0) {
    throw "use: seven-dev pkg add|list|lock"
  }

  switch ($Remaining[0]) {
    "add" {
      if ($Remaining.Count -lt 3) {
        throw "use: seven-dev pkg add <name> <version> [source]"
      }
      $source = if ($Remaining.Count -gt 3) { $Remaining[3] } else { "registry" }
      Add-SevenPackageDependency -Name $Remaining[1] -Version $Remaining[2] -Source $source
      Write-Host "added: $($Remaining[1]) $($Remaining[2]) $source"
      Write-Host "locked: seven.lock"
    }
    "remove" {
      if ($Remaining.Count -lt 2) {
        throw "use: seven-dev pkg remove <name>"
      }
      Remove-SevenPackageDependency -Name $Remaining[1]
      Write-Host "removed: $($Remaining[1])"
      Write-Host "locked: seven.lock"
    }
    "list" {
      $path = if ($Remaining.Count -gt 1) { $Remaining[1] } else { "seven.pkg" }
      $package = Get-SevenPackage -Path $path
      Write-Host "package: $($package.Nome) $($package.Versao)"
      foreach ($dep in $package.Dependencias) {
        Write-Host "dep: $($dep.Nome) $($dep.Versao) $($dep.Fonte)"
      }
    }
    "lock" {
      $path = if ($Remaining.Count -gt 1) { $Remaining[1] } else { "seven.pkg" }
      $lock = Write-SevenLockFile -PackagePath $path
      Write-Host "locked: $lock"
    }
    "verify" {
      $path = if ($Remaining.Count -gt 1) { $Remaining[1] } else { "seven.pkg" }
      $result = Test-SevenLockFile -PackagePath $path
      if ($result.Ok) {
        Write-Host "ok: $($result.Message)"
      } else {
        Write-Host "fail: $($result.Message)"
        exit 1
      }
    }
    "install" {
      $path = if ($Remaining.Count -gt 1) { $Remaining[1] } else { "seven.pkg" }
      $installed = @(Install-SevenPackageDependencies -PackagePath $path)
      foreach ($item in $installed) {
        Write-Host "installed: $item"
      }
      if ($installed.Count -eq 0) {
        Write-Host "installed: 0 dependencias"
      }
    }
    default {
      throw "subcomando de pacote desconhecido: $($Remaining[0])"
    }
  }
}

function Invoke-FfiCommand {
  param([string[]]$Remaining)

  if ($Remaining.Count -lt 3) {
    throw "use: seven-dev ffi header|manifest <file.sv> <out>"
  }

  switch ($Remaining[0]) {
    "header" {
      $out = Write-SevenCHeader -InputPath $Remaining[1] -OutputPath $Remaining[2]
      Write-Host "header: $out"
    }
    "manifest" {
      $out = Write-SevenFfiManifest -InputPath $Remaining[1] -OutputPath $Remaining[2]
      Write-Host "manifest: $out"
    }
    default {
      throw "use: seven-dev ffi header|manifest <file.sv> <out>"
    }
  }
}

function Get-DebugOptions {
  param([string[]]$Remaining)

  $breakpoints = New-Object System.Collections.ArrayList
  $locals = $false
  $file = ""
  $i = 0

  while ($i -lt $Remaining.Count) {
    $value = $Remaining[$i]
    if ($value -eq "--break") {
      if ($i + 1 -ge $Remaining.Count) {
        throw "use: --break <line>"
      }
      [void]$breakpoints.Add([int]$Remaining[$i + 1])
      $i += 2
      continue
    }
    if ($value -eq "--locals") {
      $locals = $true
      $i += 1
      continue
    }
    if ([string]::IsNullOrWhiteSpace($file)) {
      $file = $value
      $i += 1
      continue
    }
    throw "argumento de debug desconhecido: $value"
  }

  if ([string]::IsNullOrWhiteSpace($file)) {
    throw "use: seven-dev debug <file.sv|file.svbc> [--break <line>] [--locals]"
  }

  return [pscustomobject]@{
    File = $file
    Breakpoints = @($breakpoints)
    Locals = $locals
  }
}

switch ($Command) {
  "help" { Show-Help }
  "--help" { Show-Help }
  "-h" { Show-Help }
  "check" {
    if ($Args.Count -lt 1) { throw "use: seven-dev check <file.sv>" }
    Invoke-CheckCommand -Path $Args[0]
  }
  "build" {
    if ($Args.Count -lt 1) { throw "use: seven-dev build <file.sv> [out.svbc]" }
    $out = if ($Args.Count -gt 1) { $Args[1] } else { "" }
    Invoke-BuildCommand -InputPath $Args[0] -OutputPath $out
  }
  "run" {
    if ($Args.Count -lt 1) { throw "use: seven-dev run <file.sv|file.svbc>" }
    Invoke-RunCommand -InputPath $Args[0]
  }
  "debug" {
    $debug = Get-DebugOptions -Remaining $Args
    Invoke-RunCommand -InputPath $debug.File -Trace -Breakpoints $debug.Breakpoints -ShowLocals:$debug.Locals
  }
  "pkg" { Invoke-PackageCommand -Remaining $Args }
  "ffi" { Invoke-FfiCommand -Remaining $Args }
  "lsp" { & (Join-Path $PSScriptRoot "seven-lsp.ps1") }
  default {
    throw "comando desconhecido: $Command"
  }
}
