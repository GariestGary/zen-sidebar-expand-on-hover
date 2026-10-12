[CmdletBinding()]
param(
  [Parameter(Mandatory)]
  [ValidateNotNullOrEmpty()]
  [string]$ProfilePath
)

$ErrorActionPreference = 'Stop'

$modId = 'sidebar-expand-on-hover-local'
$sourceRoot = Split-Path -Parent $PSScriptRoot
$profile = (Resolve-Path -LiteralPath $ProfilePath).Path
$themesFile = Join-Path $profile 'zen-themes.json'
$themesRoot = Join-Path $profile 'chrome\zen-themes'
$target = Join-Path $themesRoot $modId

foreach ($file in 'chrome.css', 'preferences.json') {
  if (-not (Test-Path -LiteralPath (Join-Path $sourceRoot $file) -PathType Leaf)) {
    throw "Required source file is missing: $file"
  }
}

if (-not (Test-Path -LiteralPath $themesFile -PathType Leaf)) {
  throw "Zen mod registry was not found: $themesFile"
}

$themes = Get-Content -LiteralPath $themesFile -Raw | ConvertFrom-Json -AsHashtable
$themes[$modId] = [ordered]@{
  id = $modId
  name = 'Sidebar Expand on Hover (Local)'
  description = 'Local development copy of Sidebar Expand on Hover'
  author = 'Local development'
  version = '1.0.0-local'
  style = 'local'
  readme = 'local'
  preferences = 'local'
  enabled = $true
}

New-Item -ItemType Directory -Force -Path $target | Out-Null
Copy-Item -LiteralPath (Join-Path $sourceRoot 'chrome.css') -Destination (Join-Path $target 'chrome.css') -Force
Copy-Item -LiteralPath (Join-Path $sourceRoot 'preferences.json') -Destination (Join-Path $target 'preferences.json') -Force

$backup = "$themesFile.backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
Copy-Item -LiteralPath $themesFile -Destination $backup -Force
$themes | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $themesFile -Encoding utf8

Write-Host "Installed '$modId' to $target"
Write-Host "Backed up zen-themes.json to $backup"
Write-Host 'Restart Zen, then enable Sidebar Expand on Hover (Local) in Settings > Zen Mods if needed.'
