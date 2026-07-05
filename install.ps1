<#
  skillforge installer (Windows PowerShell)

  Install everything:
    irm https://raw.githubusercontent.com/Swastidp/skillforge/main/install.ps1 | iex

  Install selected skills only (from a local clone, so you can pass names):
    git clone https://github.com/Swastidp/skillforge.git
    .\skillforge\install.ps1 find-context save-context

  From a local clone with everything:
    .\install.ps1
#>
[CmdletBinding()]
param([Parameter(ValueFromRemainingArguments = $true)] [string[]] $Skills)

$ErrorActionPreference = 'Stop'
$RepoUrl = 'https://github.com/Swastidp/skillforge.git'
$Dest = Join-Path $HOME '.claude\skills'

# Find the skills source: a local checkout if we're running from one, else clone.
$Src = $null
if ($PSScriptRoot -and (Test-Path (Join-Path $PSScriptRoot 'skills'))) {
    $Src = Join-Path $PSScriptRoot 'skills'
}
$tmp = $null
if (-not $Src) {
    $tmp = Join-Path ([System.IO.Path]::GetTempPath()) ("skillforge_" + [guid]::NewGuid().ToString('N'))
    Write-Host "Fetching skillforge..."
    git clone --depth 1 $RepoUrl (Join-Path $tmp 'skillforge') 2>&1 | Out-Null
    $Src = Join-Path $tmp 'skillforge\skills'
}

New-Item -ItemType Directory -Force -Path $Dest | Out-Null

# Which skills? Positional args, or all folders under skills/.
if (-not $Skills -or $Skills.Count -eq 0) {
    $Skills = Get-ChildItem -Directory $Src | Select-Object -ExpandProperty Name
}

foreach ($s in $Skills) {
    $from = Join-Path $Src $s
    if (Test-Path $from) {
        $to = Join-Path $Dest $s
        if (Test-Path $to) { Remove-Item -Recurse -Force $to }
        Copy-Item -Recurse $from $to
        Write-Host "  installed  $s"
    }
    else {
        Write-Warning "  skipped    $s (not found in collection)"
    }
}

if ($tmp) { Remove-Item -Recurse -Force $tmp }
Write-Host "Done -> $Dest"
