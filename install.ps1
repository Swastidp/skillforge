<#
  skillforge installer (Windows PowerShell) — no git, no full clone.
  Remote runs fetch a small CDN tarball (no api.github.com, no rate limits) and
  extract only the skill(s) you ask for into ~/.claude/skills.

  Install everything:
    irm https://raw.githubusercontent.com/Swastidp/skillforge/master/install.ps1 | iex

  Install selected skills only (single command):
    & ([scriptblock]::Create((irm https://raw.githubusercontent.com/Swastidp/skillforge/master/install.ps1))) find-context save-context

  From a local clone:
    .\install.ps1                       # everything
    .\install.ps1 find-context          # selected
#>
[CmdletBinding()]
param([Parameter(ValueFromRemainingArguments = $true)] [string[]] $Skills)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'                       # faster, quiet downloads
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$Owner = 'Swastidp'
$Repo = 'skillforge'
$Branch = 'master'
$Dest = Join-Path $HOME '.claude\skills'

New-Item -ItemType Directory -Force -Path $Dest | Out-Null

function Install-From([string] $srcSkillsDir) {
    if (-not $Skills -or $Skills.Count -eq 0) {
        $Skills = Get-ChildItem -Directory $srcSkillsDir | Select-Object -ExpandProperty Name
    }
    foreach ($s in $Skills) {
        $from = Join-Path $srcSkillsDir $s
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
}

# ---- Local mode: running from a checkout that has skills/ next to this script ----
if ($PSScriptRoot -and (Test-Path (Join-Path $PSScriptRoot 'skills'))) {
    Install-From (Join-Path $PSScriptRoot 'skills')
    Write-Host "Done -> $Dest"
    return
}

# ---- Remote mode: download the CDN tarball, extract, copy the wanted skills ----
if (-not (Get-Command tar -ErrorAction SilentlyContinue)) {
    throw "tar is required (ships with Windows 10/11). Update Windows, or clone the repo and run install.ps1 locally."
}

$tmp = Join-Path ([System.IO.Path]::GetTempPath()) ("skillforge_" + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Force -Path $tmp | Out-Null
try {
    Write-Host "Fetching skillforge..."
    $tgz = Join-Path $tmp 'repo.tgz'
    Invoke-WebRequest -Uri "https://codeload.github.com/$Owner/$Repo/tar.gz/refs/heads/$Branch" -OutFile $tgz
    tar -xzf $tgz -C $tmp
    $root = Get-ChildItem -Directory $tmp | Where-Object { $_.Name -like "$Repo-*" } | Select-Object -First 1
    if (-not $root) { throw "could not find extracted repo folder" }
    Install-From (Join-Path $root.FullName 'skills')
}
finally {
    Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue
}
Write-Host "Done -> $Dest"
