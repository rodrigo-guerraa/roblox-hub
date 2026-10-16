$ErrorActionPreference = "Stop"

$hubSkills = Join-Path $PSScriptRoot "..\skills"
$target = Join-Path $env:USERPROFILE ".claude\skills"
New-Item -ItemType Directory -Force -Path $target | Out-Null

foreach ($skill in Get-ChildItem -Directory $hubSkills) {
    if (-not (Test-Path (Join-Path $skill.FullName "SKILL.md"))) { continue }
    $dest = Join-Path $target $skill.Name
    if (Test-Path $dest) { Remove-Item -Recurse -Force $dest }
    Copy-Item -Recurse $skill.FullName $dest
    Write-Output "synced $($skill.Name)"
}
