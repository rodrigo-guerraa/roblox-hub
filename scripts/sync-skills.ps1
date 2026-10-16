$ErrorActionPreference = "Stop"

$skillsRoot = Join-Path $PSScriptRoot "..\skills"
$target = Join-Path $env:USERPROFILE ".claude\skills"
New-Item -ItemType Directory -Force -Path $target | Out-Null

# Claude Code reads skills from one flat folder, so original and vendored skills are installed side by side
$sources = @(Get-ChildItem -Directory $skillsRoot) + @(Get-ChildItem -Directory (Join-Path $skillsRoot "vendored"))

foreach ($skill in $sources) {
    if (-not (Test-Path (Join-Path $skill.FullName "SKILL.md"))) { continue }
    $dest = Join-Path $target $skill.Name
    if (Test-Path $dest) { Remove-Item -Recurse -Force $dest }
    Copy-Item -Recurse $skill.FullName $dest
    Write-Output "synced $($skill.Name)"
}
