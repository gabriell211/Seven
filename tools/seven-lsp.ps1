[CmdletBinding()]
param(
  [switch]$SelfTest,
  [string]$File = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Import-Module (Join-Path $PSScriptRoot "Seven.Foundation.psm1") -Force

if ($SelfTest) {
  $text = ""
  if (-not [string]::IsNullOrWhiteSpace($File)) {
    $text = [System.IO.File]::ReadAllText((Resolve-Path -LiteralPath $File).Path)
  }
  $check = Invoke-SevenSemanticCheckText -Text $text -VirtualPath $File
  $symbols = Get-SevenSymbolsFromText -Text $text
  [pscustomobject]@{
    completions = @(Get-SevenCompletionItems -Text $text)
    diagnostics = @($check.Diagnostics | ForEach-Object { Convert-SevenDiagnosticToLsp $_ })
    symbols = @(Convert-SevenSymbolsToLsp -Symbols $symbols)
  } | ConvertTo-Json -Depth 8
  exit 0
}

$documents = @{}
$reader = New-Object System.IO.StreamReader([Console]::OpenStandardInput(), [System.Text.Encoding]::UTF8)
$writer = New-Object System.IO.StreamWriter([Console]::OpenStandardOutput(), [System.Text.Encoding]::UTF8)
$writer.AutoFlush = $true

function Write-LspMessage {
  param([Parameter(Mandatory = $true)]$Payload)

  $json = $Payload | ConvertTo-Json -Depth 20 -Compress
  $bytes = [System.Text.Encoding]::UTF8.GetBytes($json)
  $writer.Write("Content-Length: $($bytes.Length)`r`n`r`n")
  $writer.Write($json)
  $writer.Flush()
}

function Read-LspMessage {
  $length = 0

  while ($true) {
    $line = $reader.ReadLine()
    if ($null -eq $line) {
      return $null
    }
    if ($line -eq "") {
      break
    }
    if ($line -match '^Content-Length:\s*([0-9]+)') {
      $length = [int]$Matches[1]
    }
  }

  if ($length -le 0) {
    return $null
  }

  $buffer = New-Object char[] $length
  $read = $reader.ReadBlock($buffer, 0, $length)
  if ($read -le 0) {
    return $null
  }

  return (-join $buffer[0..($read - 1)]) | ConvertFrom-Json
}

function Send-Response {
  param($Request, $Result)

  Write-LspMessage ([pscustomobject]@{
    jsonrpc = "2.0"
    id = $Request.id
    result = $Result
  })
}

function Get-DocumentText {
  param([Parameter(Mandatory = $true)][string]$Uri)

  if ($documents.ContainsKey($Uri)) {
    return [string]$documents[$Uri]
  }

  return ""
}

function Publish-Diagnostics {
  param([Parameter(Mandatory = $true)][string]$Uri)

  $text = Get-DocumentText -Uri $Uri
  $check = Invoke-SevenSemanticCheckText -Text $text -VirtualPath $Uri
  Write-LspMessage ([pscustomobject]@{
    jsonrpc = "2.0"
    method = "textDocument/publishDiagnostics"
    params = [pscustomobject]@{
      uri = $Uri
      diagnostics = @($check.Diagnostics | ForEach-Object { Convert-SevenDiagnosticToLsp $_ })
    }
  })
}

function Get-WordAtPosition {
  param(
    [Parameter(Mandatory = $true)][string]$Text,
    [int]$Line,
    [int]$Character
  )

  $lines = $Text -split "`r?`n"
  if ($Line -lt 0 -or $Line -ge $lines.Count) {
    return ""
  }

  $row = $lines[$Line]
  if ($Character -lt 0) {
    $Character = 0
  }
  if ($Character -gt $row.Length) {
    $Character = $row.Length
  }

  $left = $Character
  while ($left -gt 0 -and $row[$left - 1] -match '[A-Za-z0-9_]') {
    $left -= 1
  }

  $right = $Character
  while ($right -lt $row.Length -and $row[$right] -match '[A-Za-z0-9_]') {
    $right += 1
  }

  if ($right -le $left) {
    return ""
  }

  return $row.Substring($left, $right - $left)
}

while ($true) {
  $message = Read-LspMessage
  if ($null -eq $message) {
    break
  }

  switch ($message.method) {
    "initialize" {
      Send-Response $message ([pscustomobject]@{
        capabilities = [pscustomobject]@{
          textDocumentSync = 1
          completionProvider = [pscustomobject]@{ resolveProvider = $false; triggerCharacters = @(".", ":") }
          hoverProvider = $true
          documentSymbolProvider = $true
        }
        serverInfo = [pscustomobject]@{ name = "Seven LSP"; version = "0.1.0" }
      })
    }
    "initialized" {}
    "shutdown" {
      Send-Response $message $null
    }
    "exit" {
      break
    }
    "textDocument/didOpen" {
      $documents[$message.params.textDocument.uri] = $message.params.textDocument.text
      Publish-Diagnostics -Uri $message.params.textDocument.uri
    }
    "textDocument/didChange" {
      $uri = $message.params.textDocument.uri
      if ($message.params.contentChanges.Count -gt 0) {
        $documents[$uri] = $message.params.contentChanges[0].text
        Publish-Diagnostics -Uri $uri
      }
    }
    "textDocument/completion" {
      $uri = $message.params.textDocument.uri
      $text = Get-DocumentText -Uri $uri
      Send-Response $message (Get-SevenCompletionItems -Text $text)
    }
    "textDocument/documentSymbol" {
      $uri = $message.params.textDocument.uri
      $text = Get-DocumentText -Uri $uri
      Send-Response $message @(Convert-SevenSymbolsToLsp -Symbols (Get-SevenSymbolsFromText -Text $text))
    }
    "textDocument/hover" {
      $uri = $message.params.textDocument.uri
      $text = Get-DocumentText -Uri $uri
      $word = Get-WordAtPosition -Text $text -Line $message.params.position.line -Character $message.params.position.character
      Send-Response $message ([pscustomobject]@{
        contents = [pscustomobject]@{
          kind = "markdown"
          value = Get-SevenHoverText -Text $text -Word $word
        }
      })
    }
    default {
      if ($null -ne $message.id) {
        Send-Response $message $null
      }
    }
  }
}
