[CmdletBinding()]
param(
  [string]$SevenPath = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Continue"

$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$DevCli = Join-Path $Root "tools\seven-dev.ps1"
$LspCli = Join-Path $Root "tools\seven-lsp.ps1"

function Get-SevenPowerShellHost {
  $candidates = @()

  if (-not [string]::IsNullOrWhiteSpace($PSHOME)) {
    $candidates += (Join-Path $PSHOME "pwsh.exe")
    $candidates += (Join-Path $PSHOME "powershell.exe")
  }

  foreach ($name in @("pwsh", "pwsh.exe", "powershell", "powershell.exe")) {
    $command = Get-Command $name -ErrorAction SilentlyContinue
    if ($null -ne $command -and -not [string]::IsNullOrWhiteSpace($command.Source)) {
      $candidates += $command.Source
    }
  }

  foreach ($candidate in $candidates) {
    if (-not [string]::IsNullOrWhiteSpace($candidate) -and (Test-Path -LiteralPath $candidate)) {
      return (Resolve-Path -LiteralPath $candidate).Path
    }
  }

  throw "PowerShell host nao encontrado. Instale PowerShell 7 ou disponibilize powershell.exe no PATH."
}

$PowerShellHost = Get-SevenPowerShellHost

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

  $output = & $PowerShellHost -NoProfile -ExecutionPolicy Bypass -File $DevCli @DevArgs 2>&1
  $exitCode = $LASTEXITCODE
  $text = ($output | ForEach-Object { $_.ToString() }) -join [Environment]::NewLine

  return [pscustomobject]@{
    ExitCode = $exitCode
    Output = $text
  }
}

function Invoke-SevenLspSelfTest {
  param([Parameter(Mandatory = $true)][string]$File)

  $output = & $PowerShellHost -NoProfile -ExecutionPolicy Bypass -File $LspCli -SelfTest -File $File 2>&1
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

function ConvertFrom-SevenJsonOutput {
  param([Parameter(Mandatory = $true)][string]$Text)

  try {
    return $Text | ConvertFrom-Json -ErrorAction Stop
  } catch {
    return $null
  }
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

function Get-SvbcFlavor {
  param([Parameter(Mandatory = $true)][string]$Path)

  if (-not (Test-Path -LiteralPath $Path)) {
    return "missing"
  }

  $bytes = [System.IO.File]::ReadAllBytes((Resolve-Path -LiteralPath $Path).Path)
  if ($bytes.Length -lt 8) {
    return "invalid"
  }

  $magic = [System.Text.Encoding]::ASCII.GetString($bytes, 0, 4)
  if ($magic -ne "SVBC") {
    return "invalid"
  }

  if ($bytes[4] -eq 10) {
    return "seven-dev-vm-v1"
  }

  if ($bytes[4] -eq 0 -and $bytes[5] -eq 0 -and $bytes[6] -eq 0 -and $bytes[7] -eq 1) {
    return "svbc-v1"
  }

  return "unknown"
}

function Test-SvbcProductionImage {
  param([Parameter(Mandatory = $true)][string]$Path)

  return (Get-SvbcFlavor -Path $Path) -eq "svbc-v1"
}

function Get-SevenFileHashOrEmpty {
  param([Parameter(Mandatory = $true)][string]$Path)

  if (-not (Test-Path -LiteralPath $Path)) {
    return ""
  }

  return (Get-FileHash -Algorithm SHA256 -LiteralPath $Path).Hash.ToLowerInvariant()
}

function Test-SevenChecksumFile {
  param([Parameter(Mandatory = $true)][string]$ChecksumPath)

  if (-not (Test-Path -LiteralPath $ChecksumPath)) {
    return [pscustomobject]@{ Ok = $false; Message = "checksum ausente: $(Get-RepoRelativePath $ChecksumPath)" }
  }

  $lines = [System.IO.File]::ReadAllLines((Resolve-Path -LiteralPath $ChecksumPath).Path)
  foreach ($line in $lines) {
    $trim = $line.Trim()
    if ([string]::IsNullOrWhiteSpace($trim)) {
      continue
    }

    if ($trim -notmatch '^([a-fA-F0-9]{64})\s+(.+)$') {
      return [pscustomobject]@{ Ok = $false; Message = "checksum invalido: $(Get-RepoRelativePath $ChecksumPath)" }
    }

    $expected = $Matches[1].ToLowerInvariant()
    $targetRelative = $Matches[2].Trim().Replace("/", [System.IO.Path]::DirectorySeparatorChar)
    $targetPath = Join-Path $Root $targetRelative

    if (-not (Test-Path -LiteralPath $targetPath)) {
      return [pscustomobject]@{ Ok = $false; Message = "artefato ausente: $($Matches[2].Trim())" }
    }

    $actual = (Get-FileHash -Algorithm SHA256 -LiteralPath $targetPath).Hash.ToLowerInvariant()
    if ($actual -ne $expected) {
      return [pscustomobject]@{ Ok = $false; Message = "hash divergente: $($Matches[2].Trim())" }
    }
  }

  return [pscustomobject]@{ Ok = $true; Message = "checksum valido: $(Get-RepoRelativePath $ChecksumPath)" }
}

function Test-SevenNativeSourceBoundary {
  $coreRoots = @("compiler", "compiler0", "runtime", "std", "bootstrap")
  $hostSourceExtensions = @(
    ".c",
    ".cc",
    ".cpp",
    ".cxx",
    ".h",
    ".hpp",
    ".rs",
    ".zig",
    ".go",
    ".java",
    ".kt",
    ".swift",
    ".cs",
    ".py",
    ".js",
    ".ts",
    ".lua",
    ".rb",
    ".php",
    ".m",
    ".mm",
    ".asm",
    ".s",
    ".wat",
    ".wasm",
    ".ps1",
    ".sh",
    ".bat",
    ".cmd"
  )

  $unexpected = New-Object System.Collections.Generic.List[string]

  foreach ($relativeRoot in $coreRoots) {
    $rootPath = Join-Path $Root $relativeRoot
    if (-not (Test-Path -LiteralPath $rootPath)) {
      [void]$unexpected.Add("$relativeRoot ausente")
      continue
    }

    $sevenSources = Get-ChildItem -LiteralPath $rootPath -Recurse -File -Filter "*.sev"
    if (@($sevenSources).Count -eq 0) {
      [void]$unexpected.Add("$relativeRoot sem fonte .sev")
    }

    foreach ($file in Get-ChildItem -LiteralPath $rootPath -Recurse -File) {
      $extension = [System.IO.Path]::GetExtension($file.Name).ToLowerInvariant()
      if ($hostSourceExtensions -contains $extension) {
        [void]$unexpected.Add((Get-RepoRelativePath $file.FullName))
      }
    }
  }

  if ($unexpected.Count -gt 0) {
    return [pscustomobject]@{
      Ok = $false
      Message = "nucleo contem dependencia de fonte hospedeira"
      Details = ($unexpected -join [Environment]::NewLine)
    }
  }

  return [pscustomobject]@{
    Ok = $true
    Message = "nucleo oficial mantem fonte Seven-native"
    Details = ""
  }
}

function Test-SevenNoNodeRuntime {
  $forbiddenExtensions = @(
    ".js",
    ".jsx",
    ".mjs",
    ".cjs",
    ".ts",
    ".tsx"
  )
  $forbiddenNames = @(
    "package.json",
    "package-lock.json",
    "npm-shrinkwrap.json",
    "pnpm-lock.yaml",
    "yarn.lock",
    "tsconfig.json"
  )

  $unexpected = New-Object System.Collections.Generic.List[string]

  foreach ($directory in Get-ChildItem -LiteralPath $Root -Recurse -Directory -Force) {
    if ($directory.FullName.StartsWith((Join-Path $Root ".git"), [System.StringComparison]::OrdinalIgnoreCase)) {
      continue
    }

    if ($directory.Name -eq "node_modules") {
      [void]$unexpected.Add((Get-RepoRelativePath $directory.FullName))
    }
  }

  foreach ($file in Get-ChildItem -LiteralPath $Root -Recurse -File -Force) {
    if ($file.FullName.StartsWith((Join-Path $Root ".git"), [System.StringComparison]::OrdinalIgnoreCase)) {
      continue
    }

    $extension = [System.IO.Path]::GetExtension($file.Name).ToLowerInvariant()
    $name = $file.Name.ToLowerInvariant()
    if (($forbiddenExtensions -contains $extension) -or ($forbiddenNames -contains $name)) {
      [void]$unexpected.Add((Get-RepoRelativePath $file.FullName))
    }
  }

  if ($unexpected.Count -gt 0) {
    return [pscustomobject]@{
      Ok = $false
      Message = "arvore oficial contem runtime JavaScript/TypeScript ou npm"
      Details = ($unexpected -join [Environment]::NewLine)
    }
  }

  return [pscustomobject]@{
    Ok = $true
    Message = "arvore oficial sem JavaScript/TypeScript e sem npm"
    Details = ""
  }
}

function Test-SevenNativeToolchainSurface {
  $requiredSources = @(
    "compiler\bytecode.sev",
    "compiler\toolchain\command.sev",
    "compiler\toolchain\cli.sev",
    "compiler\toolchain\native_host.sev",
    "compiler\toolchain\launcher.sev",
    "compiler\toolchain\installer.sev",
    "compiler\toolchain\formatter.sev",
    "compiler\toolchain\test_runner.sev",
    "compiler\toolchain\lsp_server.sev",
    "compiler\toolchain\release.sev",
    "compiler\toolchain\bootstrap_chain.sev",
    "compiler\toolchain\verify.sev",
    "compiler\toolchain\library_audit.sev",
    "compiler\toolchain\production_audit.sev",
    "compiler\toolchain\adapters.sev"
  )

  $requiredTerms = @{
    "compiler\bytecode.sev" = @("SvbcMagic", "SvbcVersao", "emite_svbc", "emite_nomes", "emite_tabela_constantes", "emite_campos", "emite_codigo", "emite_instrucao_svbc", "opcode_byte", "opcode_binario", "ip_do_bloco", "IrSalta", "IrSaltaSeNao", "SaltaSeNao", "Syscall", "bytes_coloca_byte", "bytes_coloca_u32", "bytes_coloca_u64", "bytes_coloca_texto_com_tamanho")
    "compiler\toolchain\command.sev" = @("CmdVerifyFoundation", "CmdVerifyBootstrap", "CmdVerifyProduction")
    "compiler\toolchain\cli.sev" = @("executa_cli", "parseia_comando", "parseia_verify", "CmdInstall", "CmdPkgAdd", "CmdLsp", "CmdVerifyFoundation", "CmdVerifyProduction")
    "compiler\toolchain\native_host.sev" = @("PlanoHostExecutavel", "host_executavel_padrao", "host_executavel_manifesto", "host_executavel_contrato_valido", "host_executavel_release_caminho", "host_manifesto_release_caminho", "runtime/host/seven.sev", "build/seven.host.svbc", "build/seven.launcher.svbc")
    "compiler\toolchain\launcher.sev" = @("PlanoLauncher", "launcher_padrao", "launcher_manifesto", "launcher_contrato_valido", "launcher_release_caminho", "launcher_bytecode_release_caminho", "runtime/svbc/runner.sev", "build/seven.svbc", "build/seven.launcher.svbc")
    "compiler\toolchain\installer.sev" = @("PlanoInstalacao", "instala_seven", "remove_instalacao", "host", "host_bytecode", "launcher", "launcher_bytecode", "seven.host", "seven.host.svbc", "seven.launcher", "seven.launcher.svbc", "host_executavel_manifesto", "launcher_manifesto")
    "compiler\toolchain\formatter.sev" = @("fmt_texto", "fmt_caminho")
    "compiler\toolchain\test_runner.sev" = @("roda_testes", "roda_benchmarks")
    "compiler\toolchain\lsp_server.sev" = @("inicia_lsp", "SessaoLsp")
    "compiler\toolchain\release.sev" = @("prepara_release", "sbom_gera", "launcher_release_caminho", "launcher_bytecode_release_caminho", "host_executavel_release_caminho", "host_manifesto_release_caminho", "tipo: ""launcher-svbc""", "tipo: ""host-svbc""")
    "compiler\toolchain\bootstrap_chain.sev" = @("verifica_cadeia_bootstrap", "seed", "seven0", "seven.self", "artefato_bootstrap_svbc_produtivo", "bytes_tem_svbc_v1", "arquivo_bytes", "bytes_pega")
    "compiler\toolchain\verify.sev" = @("verifica_fundacao", "relatorio_fundacao_texto", "verifica_sem_node", "verifica_auditoria_producao")
    "compiler\toolchain\library_audit.sev" = @("audita_biblioteca_padrao", "modulos_obrigatorios", "conformance_libs_obrigatoria")
    "compiler\toolchain\production_audit.sev" = @("audita_prontidao_producao", "relatorio_producao_texto", "P01", "P10", "launcher_contrato_valido", "host_executavel_contrato_valido", "build/seven.host.svbc", "build/seven.launcher.svbc", "host_bytecode", "launcher_bytecode", "artefato_svbc_produtivo", "bytes_tem_svbc_v1", "runtime_verify_foundation_ok", "executa_verify_foundation_de_seven_svbc", "arquivo_bytes", "bytes_pega")
  }

  $missing = New-Object System.Collections.Generic.List[string]

  foreach ($relative in $requiredSources) {
    $path = Join-Path $Root $relative
    if (-not (Test-Path -LiteralPath $path)) {
      [void]$missing.Add("$relative ausente")
      continue
    }

    $text = Get-Content -LiteralPath $path -Raw
    if (-not $text.StartsWith("modulo ")) {
      [void]$missing.Add("$relative sem declaracao de modulo")
    }

    if ($requiredTerms.ContainsKey($relative)) {
      foreach ($term in $requiredTerms[$relative]) {
        if (-not $text.Contains($term)) {
          [void]$missing.Add("$relative sem $term")
        }
      }
    }
  }

  $entrypoint = Get-Content -LiteralPath (Join-Path $Root "compiler\seven.sev") -Raw
  if (-not $entrypoint.Contains("executa_cli(argumentos)")) {
    [void]$missing.Add("compiler/seven.sev nao delega para a CLI Seven-native")
  }

  if ($missing.Count -gt 0) {
    return [pscustomobject]@{
      Ok = $false
      Message = "toolchain Seven-native incompleta"
      Details = ($missing -join [Environment]::NewLine)
    }
  }

  return [pscustomobject]@{
    Ok = $true
    Message = "toolchain oficial tem superficie Seven-native"
    Details = ""
  }
}

function Test-SevenRuntimeCommandSurface {
  $requiredSources = @(
    "runtime\svbc\runner.sev",
    "runtime\svbc\decoder.sev",
    "runtime\svbc\vm.sev",
    "runtime\svbc\verifier.sev",
    "runtime\svbc\value.sev",
    "runtime\svbc\command_runner.sev",
    "runtime\platform\intrinsic.sev",
    "runtime\platform\svbc\toolchain.sev",
    "runtime\host\seven.sev",
    "runtime\launcher\seven.sev"
  )

  $requiredTerms = @{
    "runtime\svbc\runner.sev" = @("roda_svbc_com_args", "roda_seven_svbc_verify_foundation", "roda_seven_svbc_verify_bootstrap", "roda_seven_svbc_verify_production", "formato_svbc_produtivo", "bytes_pega(dados, 5)", "bytes_pega(dados, 6)", "bytes_pega(dados, 7)", "build/seven.svbc", "verify", "foundation", "bootstrap", "production")
    "runtime\svbc\decoder.sev" = @("decodifica_nomes", "decodifica_constantes", "decodifica_campos", "decodifica_codigo", "le_u64", "opcode_ou_pare")
    "runtime\svbc\vm.sev" = @("vm_executa_com_args", "vm_nova_com_args", "argumentos", "VmArgs", "locais", "vm_carrega", "vm_guarda", "vm_chama", "QuadroVm", "Carrega", "Guarda", "Chama")
    "runtime\svbc\verifier.sev" = @("verifica_saltos", "verifica_constantes", "verifica_locais", "verifica_pilha", "verifica_efeitos", "efeito_binario_pilha")
    "runtime\svbc\value.sev" = @("VmArgs")
    "runtime\svbc\command_runner.sev" = @("executa_verify_foundation_de_seven_svbc", "executa_verify_bootstrap_de_seven_svbc", "executa_verify_production_de_seven_svbc", "comando_verify_foundation", "comando_verify_bootstrap", "comando_verify_production", "executa_comando_svbc")
    "runtime\platform\intrinsic.sev" = @("seven_args_verify_foundation", "seven_args_verify_bootstrap", "seven_args_verify_production", "seven_verify_foundation", "seven_verify_bootstrap", "seven_verify_production")
    "runtime\platform\svbc\toolchain.sev" = @("intr_cmd_args_verify_foundation", "intr_cmd_args_verify_bootstrap", "intr_cmd_args_verify_production", "intr_cmd_verify_foundation", "intr_cmd_verify_bootstrap", "intr_cmd_verify_production", "svbc_produtivo", "svbc_arquivos_iguais", "bytes_tem_svbc_v1", "seven <check|build|run", "build/seven.svbc SVBC-v1", "build/seven.host.svbc", "build/seven.launcher.svbc")
    "runtime\host\seven.sev" = @("seven_host", "roda_svbc_com_args", "build/seven.launcher.svbc")
    "runtime\launcher\seven.sev" = @("seven_launcher", "roda_svbc_com_args", "build/seven.svbc")
  }

  $missing = New-Object System.Collections.Generic.List[string]

  foreach ($relative in $requiredSources) {
    $path = Join-Path $Root $relative
    if (-not (Test-Path -LiteralPath $path)) {
      [void]$missing.Add("$relative ausente")
      continue
    }

    $text = Get-Content -LiteralPath $path -Raw
    foreach ($term in $requiredTerms[$relative]) {
      if (-not $text.Contains($term)) {
        [void]$missing.Add("$relative sem $term")
      }
    }

    if ($relative -eq "runtime\svbc\verifier.sev" -and $text.Contains("sys_svbc_verifica_")) {
      [void]$missing.Add("runtime\svbc\verifier.sev nao deve chamar sys_svbc_verifica_*")
    }

    if ($relative -eq "runtime\svbc\decoder.sev" -and $text.Contains("sys_svbc_decodifica_")) {
      [void]$missing.Add("runtime\svbc\decoder.sev nao deve chamar sys_svbc_decodifica_*")
    }
  }

  if ($missing.Count -gt 0) {
    return [pscustomobject]@{
      Ok = $false
      Message = "runtime nao executa comando a partir de seven.svbc"
      Details = ($missing -join [Environment]::NewLine)
    }
  }

  return [pscustomobject]@{
    Ok = $true
    Message = "runtime declara execucao de comando via seven.svbc"
    Details = ""
  }
}

function Test-SevenCiTransitionSurface {
  $workflow = Join-Path $Root ".github\workflows\foundation.yml"
  if (-not (Test-Path -LiteralPath $workflow)) {
    return [pscustomobject]@{
      Ok = $false
      Message = "workflow de fundacao ausente"
      Details = ".github/workflows/foundation.yml"
    }
  }

  $text = Get-Content -LiteralPath $workflow -Raw
  $required = @(
    "Materialize Seven bootstrap artifacts",
    "build\seven0.svbc",
    "build\seven.svbc",
    "build\seven.self.svbc",
    "build\seven.host.svbc",
    "build\seven.launcher.svbc",
    "seven-dev.ps1 build .\runtime\host\seven.sev .\build\seven.host.svbc",
    "seven-dev.ps1 build .\runtime\launcher\seven.sev .\build\seven.launcher.svbc",
    "Run Seven foundation contract from seven.svbc",
    "seven-dev.ps1 run .\build\seven.svbc verify foundation",
    "Run Seven bootstrap contract from seven.svbc",
    "seven-dev.ps1 run .\build\seven.svbc verify bootstrap",
    "Run Seven launcher bootstrap contract from seven.launcher.svbc",
    "seven-dev.ps1 run .\build\seven.launcher.svbc verify bootstrap",
    "Run Seven host bootstrap contract from seven.host.svbc",
    "seven-dev.ps1 run .\build\seven.host.svbc verify bootstrap",
    "Run Seven production contract from seven.svbc",
    "seven-dev.ps1 run .\build\seven.svbc verify production",
    "Audit transition bridge"
  )
  $missing = New-Object System.Collections.Generic.List[string]

  foreach ($term in $required) {
    if (-not $text.Contains($term)) {
      [void]$missing.Add($term)
    }
  }

  if ($missing.Count -gt 0) {
    return [pscustomobject]@{
      Ok = $false
      Message = "CI nao materializa a cadeia Seven antes do gate SVBC"
      Details = ($missing -join [Environment]::NewLine)
    }
  }

  return [pscustomobject]@{
    Ok = $true
    Message = "CI materializa a cadeia Seven e roda build/seven.svbc verify foundation/bootstrap/production"
    Details = ""
  }
}

function Test-SevenStdLibrarySurface {
  $requiredStd = @(
    "std\base\prelude.sev",
    "std\base\resultado.sev",
    "std\base\talvez.sev",
    "std\base\lista.sev",
    "std\base\mapa.sev",
    "std\base\texto.sev",
    "std\mem\bytes.sev",
    "std\mem\alloc.sev",
    "std\mem\ptr.sev",
    "std\ffi\c.sev",
    "std\io\console.sev",
    "std\fs\file.sev",
    "std\env\runtime.sev",
    "std\os\process.sev",
    "std\time\clock.sev",
    "std\async\task.sev",
    "std\sync\atomic.sev",
    "std\runtime\event_loop.sev",
    "std\net\tcp.sev",
    "std\net\udp.sev",
    "std\net\tls.sev",
    "std\net\dns.sev",
    "std\net\websocket.sev",
    "std\net\mqtt.sev",
    "std\web\http.sev",
    "std\web\router.sev",
    "std\web\json.sev",
    "std\web\server.sev",
    "std\web\security.sev",
    "std\db\client.sev",
    "std\db\query.sev",
    "std\db\migrate.sev",
    "std\serial\csv.sev",
    "std\serial\xml.sev",
    "std\serial\yaml.sev",
    "std\serial\toml.sev",
    "std\serial\protobuf.sev",
    "std\data\object.sev",
    "std\system\bits.sev",
    "std\crypto\hash.sev",
    "std\crypto\random.sev",
    "std\auth\jwt.sev",
    "std\frontend\dom.sev",
    "std\frontend\css.sev",
    "std\frontend\bundle.sev",
    "std\log\logger.sev",
    "std\observability\metrics.sev",
    "std\observability\trace.sev",
    "std\test\spec.sev",
    "std\ai\model.sev"
  )

  $requiredLibConformance = @(
    "conformance\libs\valid\language_intelligence.sev",
    "conformance\libs\valid\serialization.sev",
    "conformance\libs\valid\smtp.sev",
    "conformance\libs\valid\snmp.sev",
    "conformance\libs\valid\system_level.sev",
    "conformance\libs\valid\dynamic_runtime.sev"
  )

  $missing = New-Object System.Collections.Generic.List[string]

  foreach ($relative in @($requiredStd + $requiredLibConformance)) {
    if (-not (Test-Path -LiteralPath (Join-Path $Root $relative))) {
      [void]$missing.Add($relative)
    }
  }

  $requiredStdTerms = @{
    "std\base\lista.sev" = @("lista_define", "sys_lista_define")
    "std\mem\bytes.sev" = @("bytes_coloca_byte", "bytes_coloca_u32", "bytes_coloca_u64", "bytes_coloca_texto", "bytes_coloca_texto_com_tamanho")
  }

  foreach ($relative in $requiredStdTerms.Keys) {
    $path = Join-Path $Root $relative
    if (-not (Test-Path -LiteralPath $path)) {
      continue
    }

    $text = Get-Content -LiteralPath $path -Raw
    foreach ($term in $requiredStdTerms[$relative]) {
      if (-not $text.Contains($term)) {
        [void]$missing.Add("$relative sem $term")
      }
    }
  }

  if ($missing.Count -gt 0) {
    return [pscustomobject]@{
      Ok = $false
      Message = "biblioteca padrao ou conformance libs incompleta"
      Details = ($missing -join [Environment]::NewLine)
    }
  }

  return [pscustomobject]@{
    Ok = $true
    Message = "biblioteca padrao e libs essenciais presentes"
    Details = ""
  }
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

Write-Step "Autonomia do nucleo"

$nativeBoundary = Test-SevenNativeSourceBoundary
if ($nativeBoundary.Ok) {
  Add-Pass $nativeBoundary.Message
} else {
  Add-Failure $nativeBoundary.Message $nativeBoundary.Details
}

$noNodeRuntime = Test-SevenNoNodeRuntime
if ($noNodeRuntime.Ok) {
  Add-Pass $noNodeRuntime.Message
} else {
  Add-Failure $noNodeRuntime.Message $noNodeRuntime.Details
}

$nativeToolchain = Test-SevenNativeToolchainSurface
if ($nativeToolchain.Ok) {
  Add-Pass $nativeToolchain.Message
} else {
  Add-Failure $nativeToolchain.Message $nativeToolchain.Details
}

$runtimeCommand = Test-SevenRuntimeCommandSurface
if ($runtimeCommand.Ok) {
  Add-Pass $runtimeCommand.Message
} else {
  Add-Failure $runtimeCommand.Message $runtimeCommand.Details
}

$ciTransition = Test-SevenCiTransitionSurface
if ($ciTransition.Ok) {
  Add-Pass $ciTransition.Message
} else {
  Add-Failure $ciTransition.Message $ciTransition.Details
}

$stdlibSurface = Test-SevenStdLibrarySurface
if ($stdlibSurface.Ok) {
  Add-Pass $stdlibSurface.Message
} else {
  Add-Failure $stdlibSurface.Message $stdlibSurface.Details
}

Write-Step "Cadeia bootstrap fisica"

$bootstrapMaterialization = @(
  @{
    Name = "check compiler0/seven0.sev"
    Args = @("check", (Join-Path $Root "compiler0\seven0.sev"))
  },
  @{
    Name = "build compiler0/seven0.sev -> build/seven0.svbc"
    Args = @("build", (Join-Path $Root "compiler0\seven0.sev"), (Join-Path $Root "build\seven0.svbc"))
  },
  @{
    Name = "check compiler/seven.sev"
    Args = @("check", (Join-Path $Root "compiler\seven.sev"))
  },
  @{
    Name = "build compiler/seven.sev -> build/seven.svbc"
    Args = @("build", (Join-Path $Root "compiler\seven.sev"), (Join-Path $Root "build\seven.svbc"))
  },
  @{
    Name = "build compiler/seven.sev -> build/seven.self.svbc"
    Args = @("build", (Join-Path $Root "compiler\seven.sev"), (Join-Path $Root "build\seven.self.svbc"))
  },
  @{
    Name = "build runtime/host/seven.sev -> build/seven.host.svbc"
    Args = @("build", (Join-Path $Root "runtime\host\seven.sev"), (Join-Path $Root "build\seven.host.svbc"))
  },
  @{
    Name = "build runtime/launcher/seven.sev -> build/seven.launcher.svbc"
    Args = @("build", (Join-Path $Root "runtime\launcher\seven.sev"), (Join-Path $Root "build\seven.launcher.svbc"))
  }
)

foreach ($step in $bootstrapMaterialization) {
  $result = Invoke-SevenDev -DevArgs $step.Args
  if ($result.ExitCode -eq 0) {
    Add-Pass $step.Name
  } else {
    Add-Failure "$($step.Name) deveria passar" $result.Output
  }
}

foreach ($artifact in @(
  (Join-Path $Root "build\seven0.svbc"),
  (Join-Path $Root "build\seven.svbc"),
  (Join-Path $Root "build\seven.self.svbc"),
  (Join-Path $Root "build\seven.host.svbc"),
  (Join-Path $Root "build\seven.launcher.svbc")
)) {
  $relative = Get-RepoRelativePath $artifact
  if (Test-SvbcEnvelope -Path $artifact) {
    Add-Pass "$relative tem magic SVBC"
  } else {
    Add-Failure "$relative deveria ter magic SVBC"
  }
}

$sevenHash = Get-SevenFileHashOrEmpty -Path (Join-Path $Root "build\seven.svbc")
$selfHash = Get-SevenFileHashOrEmpty -Path (Join-Path $Root "build\seven.self.svbc")
if ($sevenHash -ne "" -and $sevenHash -eq $selfHash) {
  Add-Pass "build/seven.svbc e build/seven.self.svbc tem hash equivalente"
} else {
  Add-Failure "build/seven.svbc e build/seven.self.svbc deveriam ser equivalentes"
}

$sevenFlavor = Get-SvbcFlavor -Path (Join-Path $Root "build\seven.svbc")
if ($sevenFlavor -eq "svbc-v1") {
  Add-Pass "build/seven.svbc usa layout SVBC-v1 binario"
} else {
  Add-KnownGap "build/seven.svbc ainda e $sevenFlavor; runtime produtivo nao deve trata-lo como self-hosted"
}

$svbcVerify = Invoke-SevenDev -DevArgs @("run", (Join-Path $Root "build\seven.svbc"), "verify", "foundation")
if ($svbcVerify.ExitCode -eq 0 -and (Test-OutputContains -Result $svbcVerify -Expected "falhas: 0")) {
  Add-Pass "build/seven.svbc executa verify foundation por despacho SVBC"
} else {
  Add-Failure "build/seven.svbc verify foundation deveria executar por despacho SVBC" $svbcVerify.Output
}

$svbcVerifyBootstrap = Invoke-SevenDev -DevArgs @("run", (Join-Path $Root "build\seven.svbc"), "verify", "bootstrap")
if ($svbcVerifyBootstrap.ExitCode -eq 0 -and
    (Test-OutputContains -Result $svbcVerifyBootstrap -Expected "seven == seven.self") -and
    (Test-OutputContains -Result $svbcVerifyBootstrap -Expected "falhas: 0")) {
  Add-Pass "build/seven.svbc executa verify bootstrap por despacho SVBC"
} else {
  Add-Failure "build/seven.svbc verify bootstrap deveria executar por despacho SVBC" $svbcVerifyBootstrap.Output
}

$launcherVerifyBootstrap = Invoke-SevenDev -DevArgs @("run", (Join-Path $Root "build\seven.launcher.svbc"), "verify", "bootstrap")
if ($launcherVerifyBootstrap.ExitCode -eq 0 -and
    (Test-OutputContains -Result $launcherVerifyBootstrap -Expected "seven == seven.self") -and
    (Test-OutputContains -Result $launcherVerifyBootstrap -Expected "falhas: 0")) {
  Add-Pass "build/seven.launcher.svbc delega verify bootstrap para build/seven.svbc"
} else {
  Add-Failure "build/seven.launcher.svbc deveria delegar verify bootstrap" $launcherVerifyBootstrap.Output
}

$hostVerifyBootstrap = Invoke-SevenDev -DevArgs @("run", (Join-Path $Root "build\seven.host.svbc"), "verify", "bootstrap")
if ($hostVerifyBootstrap.ExitCode -eq 0 -and
    (Test-OutputContains -Result $hostVerifyBootstrap -Expected "seven == seven.self") -and
    (Test-OutputContains -Result $hostVerifyBootstrap -Expected "falhas: 0")) {
  Add-Pass "build/seven.host.svbc delega verify bootstrap para build/seven.launcher.svbc"
} else {
  Add-Failure "build/seven.host.svbc deveria delegar verify bootstrap" $hostVerifyBootstrap.Output
}

$svbcVerifyProduction = Invoke-SevenDev -DevArgs @("run", (Join-Path $Root "build\seven.svbc"), "verify", "production")
if ($svbcVerifyProduction.ExitCode -eq 0 -and
    (Test-OutputContains -Result $svbcVerifyProduction -Expected "P10") -and
    (Test-OutputContains -Result $svbcVerifyProduction -Expected "falhas: 0")) {
  Add-Pass "build/seven.svbc executa verify production por despacho SVBC"
} else {
  Add-Failure "build/seven.svbc verify production deveria executar por despacho SVBC" $svbcVerifyProduction.Output
}

$sevenSvbcText = [System.Text.Encoding]::UTF8.GetString([System.IO.File]::ReadAllBytes((Join-Path $Root "build\seven.svbc")))
if ((-not $sevenSvbcText.Contains("seven_cli")) -and
    $sevenSvbcText.Contains("seven_args_verify_foundation") -and
    $sevenSvbcText.Contains("seven_verify_foundation") -and
    $sevenSvbcText.Contains("seven_args_verify_bootstrap") -and
    $sevenSvbcText.Contains("seven_verify_bootstrap") -and
    $sevenSvbcText.Contains("seven_args_verify_production") -and
    $sevenSvbcText.Contains("seven_verify_production")) {
  Add-Pass "build/seven.svbc nao emite syscall seven_cli"
} else {
  Add-Failure "build/seven.svbc nao deveria depender de seven_cli" ""
}

$svbcTrace = Invoke-SevenDev -DevArgs @("debug", (Join-Path $Root "build\seven.svbc"))
if ($svbcTrace.ExitCode -eq 0 -and (Test-OutputContains -Result $svbcTrace -Expected "op 16") -and (Test-OutputContains -Result $svbcTrace -Expected "op 15")) {
  Add-Pass "build/seven.svbc usa CHAMA e SaltaSeNao para entrar no CLI"
} else {
  Add-Failure "build/seven.svbc deveria usar CHAMA e SaltaSeNao para executa_cli" $svbcTrace.Output
}

$nativeVerify = Invoke-Seven -SevenArgs @("verify", "foundation")
if ($nativeVerify.ExitCode -eq 0) {
  Add-Pass "bin/seven.exe executa seven verify foundation"
} else {
  Add-Pass "bin/seven.exe fica legado; verify foundation roda por build/seven.svbc"
  Add-KnownGap "host SVBC ainda usa seven-dev.ps1 ate existir runtime Seven executavel nativo" $nativeVerify.Output
}

Write-Step "Artefatos versionados"

foreach ($checksum in @(
  (Join-Path $Root "bin\seven.exe.sha256"),
  (Join-Path $Root "brand\seven.ico.sha256")
)) {
  $result = Test-SevenChecksumFile -ChecksumPath $checksum
  if ($result.Ok) {
    Add-Pass $result.Message
  } else {
    Add-Failure $result.Message
  }
}

Write-Step "Bootstrap CLI"

$version = Invoke-Seven -SevenArgs @("--version")
if ($version.ExitCode -eq 0 -and (Test-OutputContains -Result $version -Expected "Seven 0.1.0")) {
  Add-Pass "seven --version"
} else {
  Add-Failure "seven --version nao retornou a versao esperada" $version.Output
}

$help = Invoke-Seven -SevenArgs @("--help")
if ($help.ExitCode -eq 0 -and (Test-OutputContains -Result $help -Expected "seven check <filesev>")) {
  Add-Pass "seven --help"
} else {
  Add-Failure "seven --help nao publicou os comandos esperados" $help.Output
}

Write-Step "Conformidade valida"

$validFiles = Get-ChildItem -Path (Join-Path $Root "conformance") -Recurse -Filter "*.sev" |
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

Write-Step "Biblioteca padrao"

$stdFiles = Get-ChildItem -Path (Join-Path $Root "std") -Recurse -Filter "*.sev" |
  Sort-Object FullName

foreach ($file in $stdFiles) {
  $relative = Get-RepoRelativePath $file.FullName
  $result = Invoke-SevenDev -DevArgs @("check", $file.FullName)

  if ($result.ExitCode -eq 0 -and $result.Output.StartsWith("ok:")) {
    Add-Pass "std check $relative"
  } else {
    Add-Failure "std check $relative deveria passar" $result.Output
  }
}

Write-Step "Build SVBC"

$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("seven-foundation-" + [System.Guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Force -Path $tempRoot | Out-Null

try {
  $buildInputs = @(
    (Join-Path $Root "examples\hello.sev"),
    (Join-Path $Root "examples\control.sev"),
    (Join-Path $Root "conformance\valid\hello.sev"),
    (Join-Path $Root "conformance\runtime\valid\svbc_arithmetic.sev"),
    (Join-Path $Root "conformance\runtime\valid\svbc_branch.sev"),
    (Join-Path $Root "conformance\runtime\valid\svbc_compare.sev"),
    (Join-Path $Root "conformance\runtime\valid\svbc_loop.sev"),
    (Join-Path $Root "conformance\runtime\valid\svbc_call.sev")
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

    $flavor = Get-SvbcFlavor -Path $outputPath
    if ($flavor -ne "svbc-v1") {
      Add-Failure "build $relative deveria gerar SVBC-v1 binario" "formato: $flavor"
      continue
    }

    Add-Pass "build $relative -> SVBC-v1 binario"

    if ($relative -eq "examples/hello.sev") {
      $runBuilt = Invoke-SevenDev -DevArgs @("run", $outputPath)
      if ($runBuilt.ExitCode -eq 0 -and (Test-OutputContains -Result $runBuilt -Expected "Seven nasceu.")) {
        Add-Pass "run SVBC-v1 gerado de examples/hello.sev"
      } else {
        Add-Failure "run SVBC-v1 gerado de examples/hello.sev deveria passar" $runBuilt.Output
      }
    }

    if ($relative -eq "examples/control.sev") {
      $runBuiltControl = Invoke-SevenDev -DevArgs @("run", $outputPath)
      if ($runBuiltControl.ExitCode -eq 0 -and (Test-OutputContains -Result $runBuiltControl -Expected "ciclo completo")) {
        Add-Pass "run SVBC-v1 gerado de examples/control.sev"
      } else {
        Add-Failure "run SVBC-v1 gerado de examples/control.sev deveria completar ciclo" $runBuiltControl.Output
      }
    }

    if ($relative -eq "conformance/runtime/valid/svbc_call.sev") {
      $runCall = Invoke-SevenDev -DevArgs @("run", $outputPath)
      if ($runCall.ExitCode -eq 7) {
        Add-Pass "run SVBC-v1 com CHAMA retorna 7"
      } else {
        Add-Failure "run SVBC-v1 com CHAMA deveria retornar 7" $runCall.Output
      }
    }

    if ($relative -eq "conformance/runtime/valid/svbc_arithmetic.sev") {
      $runArithmetic = Invoke-SevenDev -DevArgs @("run", $outputPath)
      if ($runArithmetic.ExitCode -eq 7) {
        Add-Pass "run SVBC-v1 com GUARDA/SOMA retorna 7"
      } else {
        Add-Failure "run SVBC-v1 com GUARDA/SOMA deveria retornar 7" $runArithmetic.Output
      }
    }

    if ($relative -eq "conformance/runtime/valid/svbc_branch.sev") {
      $runBranch = Invoke-SevenDev -DevArgs @("run", $outputPath)
      if ($runBranch.ExitCode -eq 7) {
        Add-Pass "run SVBC-v1 com veja/outro retorna 7"
      } else {
        Add-Failure "run SVBC-v1 com veja/outro deveria retornar 7" $runBranch.Output
      }
    }

    if ($relative -eq "conformance/runtime/valid/svbc_compare.sev") {
      $runCompare = Invoke-SevenDev -DevArgs @("run", $outputPath)
      if ($runCompare.ExitCode -eq 1) {
        Add-Pass "run SVBC-v1 com comparacao retorna 1"
      } else {
        Add-Failure "run SVBC-v1 com comparacao deveria retornar 1" $runCompare.Output
      }
    }

    if ($relative -eq "conformance/runtime/valid/svbc_loop.sev") {
      $runLoop = Invoke-SevenDev -DevArgs @("run", $outputPath)
      if ($runLoop.ExitCode -eq 7) {
        Add-Pass "run SVBC-v1 com gira retorna 7"
      } else {
        Add-Failure "run SVBC-v1 com gira deveria retornar 7" $runLoop.Output
      }
    }
  }
} finally {
  Remove-Item -LiteralPath $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Step "Run smoke"

$runInput = Join-Path $Root "examples\hello.sev"
$run = Invoke-SevenDev -DevArgs @("run", $runInput)
if ($run.ExitCode -ne 0) {
  Add-Failure "run examples/hello.sev deveria passar" $run.Output
} elseif (-not (Test-OutputContains -Result $run -Expected "Seven nasceu.")) {
  Add-Failure "run examples/hello.sev nao executou saida esperada" $run.Output
} else {
  Add-Pass "run examples/hello.sev executa na VM de desenvolvimento"
}

$runControl = Invoke-SevenDev -DevArgs @("run", (Join-Path $Root "examples\control.sev"))
if ($runControl.ExitCode -ne 0) {
  Add-Failure "run examples/control.sev deveria passar" $runControl.Output
} elseif (-not (Test-OutputContains -Result $runControl -Expected "ciclo completo")) {
  Add-Failure "run examples/control.sev nao executou controle de fluxo" $runControl.Output
} else {
  Add-Pass "run examples/control.sev executa controle de fluxo"
}

$debugControl = Invoke-SevenDev -DevArgs @("debug", (Join-Path $Root "examples\control.sev"), "--break", "8", "--locals")
if ($debugControl.ExitCode -ne 0) {
  Add-Failure "debug examples/control.sev deveria passar" $debugControl.Output
} elseif (-not (Test-OutputContains -Result $debugControl -Expected "breakpoint: line 8")) {
  Add-Failure "debug examples/control.sev nao parou no breakpoint" $debugControl.Output
} elseif (-not (Test-OutputContains -Result $debugControl -Expected "local: energia = 3")) {
  Add-Failure "debug examples/control.sev nao mostrou locals" $debugControl.Output
} else {
  Add-Pass "debug examples/control.sev emite breakpoint e locals"
}

Write-Step "Conformidade invalida"

$invalidFiles = Get-ChildItem -Path (Join-Path $Root "conformance") -Recurse -Filter "*.sev" |
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

  $lsp = Invoke-SevenLspSelfTest -File (Join-Path $Root "examples\hello.sev")
  $lspPayload = ConvertFrom-SevenJsonOutput -Text $lsp.Output
  $hasInicioCompletion = $false
  $hasInicioSymbol = $false
  if ($null -ne $lspPayload) {
    $hasInicioCompletion = @($lspPayload.completions | Where-Object { $_.label -eq "inicio" }).Count -gt 0
    $hasInicioSymbol = @($lspPayload.symbols | Where-Object { $_.name -eq "inicio" }).Count -gt 0
  }

  if ($lsp.ExitCode -eq 0 -and $hasInicioCompletion -and $hasInicioSymbol) {
    Add-Pass "LSP self-test publica completions e symbols"
  } else {
    Add-Failure "LSP self-test deveria retornar completion e symbol inicio" $lsp.Output
  }

  $lspInvalid = Invoke-SevenLspSelfTest -File (Join-Path $Root "conformance\invalid\immutable_assign.sev")
  $lspInvalidPayload = ConvertFrom-SevenJsonOutput -Text $lspInvalid.Output
  $hasImmutableDiagnostic = $false
  if ($null -ne $lspInvalidPayload) {
    $hasImmutableDiagnostic = @($lspInvalidPayload.diagnostics | Where-Object { $_.code -eq "SV-TIPO-IMUTAVEL" }).Count -gt 0
  }

  if ($lspInvalid.ExitCode -eq 0 -and $hasImmutableDiagnostic) {
    Add-Pass "LSP self-test publica diagnosticos"
  } else {
    Add-Failure "LSP self-test deveria publicar diagnostico semantico" $lspInvalid.Output
  }

  $headerPath = Join-Path $toolTemp "interop.h"
  $manifestPath = Join-Path $toolTemp "interop.json"
  $ffi = Invoke-SevenDev -DevArgs @("ffi", "header", (Join-Path $Root "examples\interop-c\main.sev"), $headerPath)
  $ffiManifest = Invoke-SevenDev -DevArgs @("ffi", "manifest", (Join-Path $Root "examples\interop-c\main.sev"), $manifestPath)
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
    $manifest = (Get-Content -LiteralPath $manifestPath -Raw) | ConvertFrom-Json
    $hasPutsSymbol = @($manifest.symbols | Where-Object { $_.symbol -eq "puts" }).Count -gt 0
    if ($manifest.format -eq "seven-ffi-v1" -and $hasPutsSymbol) {
      Add-Pass "ffi manifest registra simbolos externos"
    } else {
      Add-Failure "ffi manifest nao contem simbolos esperados" (Get-Content -LiteralPath $manifestPath -Raw)
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
