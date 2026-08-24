[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$root = [IO.Path]::GetFullPath((Split-Path -Parent $PSScriptRoot))
$errors = [Collections.Generic.List[string]]::new()
function Add-CheckError([string]$Message) { $script:errors.Add($Message) }

$required = @(
    '.codex-plugin/plugin.json', 'skills/run-fpga-workflow/SKILL.md',
    'skills/run-fpga-workflow/agents/openai.yaml', 'skills/run-fpga-workflow/assets/icon.svg',
    'skills/run-fpga-workflow/references/task-profiles.md',
    'skills/run-fpga-workflow/references/improvement-policy.md',
    'skills/run-fpga-workflow/references/improvement-evidence.md',
    'templates/AGENTS.fpga.md', 'README.md', 'assets/hero.svg', 'LICENSE', 'SECURITY.md',
    'VERSION', 'CHANGELOG.md', 'COMPATIBILITY.md', 'docs/research.md',
    'docs/en/architecture.md', 'docs/en/roles.md', 'docs/en/installation.md',
    'docs/en/usage.md', 'docs/en/safety-and-evidence.md'
)
foreach ($rel in $required) {
    $path = Join-Path $root ($rel -replace '/', [IO.Path]::DirectorySeparatorChar)
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { Add-CheckError "Missing required file: $rel" }
}

$expectedNames = @('fpga_architect','fpga_engineer','verification_engineer','fpga_cdc_timing_reviewer','fpga_interface_architect','fpga_vendor_platform_reviewer','fpga_board_validation_engineer','fpga_reviewer','system_architect','embedded_engineer','hardware_datasheet','independent_reviewer')
$agentFiles = Get-ChildItem -LiteralPath (Join-Path $root '.codex\agents') -File -Filter '*.toml'
if ($agentFiles.Count -ne 12) { Add-CheckError "Expected 12 agent TOML files; found $($agentFiles.Count)." }
$seen = @{}
$readOnlyExpected = @('fpga_architect','fpga_cdc_timing_reviewer','fpga_interface_architect','fpga_vendor_platform_reviewer','fpga_board_validation_engineer','fpga_reviewer','system_architect','hardware_datasheet','independent_reviewer')
foreach ($file in $agentFiles) {
    $text = [IO.File]::ReadAllText($file.FullName, [Text.UTF8Encoding]::new($false, $true))
    $match = [regex]::Match($text, '(?m)^name\s*=\s*"([^"]+)"\s*$')
    if (-not $match.Success) { Add-CheckError "Missing name in $($file.Name)"; continue }
    $name = $match.Groups[1].Value
    if ($name -ne $file.BaseName) { Add-CheckError "Name/file mismatch: $($file.Name) -> $name" }
    if ($seen.ContainsKey($name)) { Add-CheckError "Duplicate agent name: $name" } else { $seen[$name] = $true }
    if ($name -in $readOnlyExpected -and $text -notmatch '(?m)^sandbox_mode\s*=\s*"read-only"\s*$') { Add-CheckError "Read-only sandbox missing: $name" }
    if ($name -notin $readOnlyExpected -and $text -match '(?m)^sandbox_mode\s*=\s*"read-only"\s*$') { Add-CheckError "Writer incorrectly read-only: $name" }
}
foreach ($name in $expectedNames) { if (-not $seen.ContainsKey($name)) { Add-CheckError "Missing agent: $name" } }

$expectedVersion = (Get-Content -LiteralPath (Join-Path $root 'VERSION') -Raw).Trim()
if ($expectedVersion -notmatch '^\d+\.\d+\.\d+$') { Add-CheckError "VERSION is not a semantic version: $expectedVersion" }
$plugin = Get-Content -LiteralPath (Join-Path $root '.codex-plugin\plugin.json') -Raw | ConvertFrom-Json
if ($plugin.name -ne 'codex-fpga-engineering-workflow' -or $plugin.version -ne $expectedVersion -or $plugin.license -ne 'MIT') { Add-CheckError 'Plugin identity/version/license mismatch.' }
if ($plugin.skills -ne './skills/') { Add-CheckError 'Plugin skills path mismatch.' }
foreach ($unsupported in @('apps','mcpServers','hooks')) { if ($plugin.PSObject.Properties.Name -contains $unsupported) { Add-CheckError "Unexpected manifest field: $unsupported" } }

$skillText = Get-Content -LiteralPath (Join-Path $root 'skills\run-fpga-workflow\SKILL.md') -Raw
foreach ($reference in @('references/task-profiles.md','references/improvement-policy.md','references/improvement-evidence.md')) { if ($skillText -notmatch [regex]::Escape($reference)) { Add-CheckError "Skill does not reference $reference" } }
if ($skillText -notmatch 'only `fpga_engineer` writes product') { Add-CheckError 'Single product-writer gate is missing from skill.' }

$allTextFiles = Get-ChildItem -LiteralPath $root -File -Recurse | Where-Object { ($_.Extension -in @('.md','.toml','.json','.yaml','.yml','.ps1','.svg','.txt') -or $_.Name -in @('LICENSE','VERSION','.gitignore','.gitattributes')) -and $_.FullName -ne $PSCommandPath }
$privatePattern = '(?i)(' + 'C:' + '\\Users\\' + '|/home/[^/]+/|' + '\.codex\\memories' + '|D:' + '\\PDS|' + 'customer[-_ ]?name\s*[:=])'
$printSpecificPattern = '(?i)(' + 'print' + 'ing head|' + 'print' + 'head|' + [char]0x55B7 + [char]0x5934 + '|' + [char]0x5DE5 + [char]0x4E1A + [char]0x6253 + [char]0x5370 + ')'
$cjkPattern = '[\u3400-\u4DBF\u4E00-\u9FFF\uF900-\uFAFF]'
$deletedReferencePattern = '(?i)(README\.en\.md|CONTRIBUTING\.zh-CN\.md|docs[/\\]zh-CN)'
foreach ($file in $allTextFiles) {
    try { $content = [IO.File]::ReadAllText($file.FullName, [Text.UTF8Encoding]::new($false, $true)) } catch { Add-CheckError "Invalid UTF-8: $($file.FullName)"; continue }
    if ($content -match '(?i)(ghp_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}|BEGIN (RSA|OPENSSH|EC) PRIVATE KEY|AKIA[0-9A-Z]{16})') { Add-CheckError "Possible secret: $($file.FullName)" }
    if ($content -match $privatePattern) { Add-CheckError "Possible private/absolute path or customer marker: $($file.FullName)" }
    if ($content -match $printSpecificPattern) { Add-CheckError "Industrial-print-specific wording remains: $($file.FullName)" }
    if ($content -match $cjkPattern) { Add-CheckError "CJK Unified Ideograph remains in public text: $($file.FullName)" }
    if ($content -match $deletedReferencePattern) { Add-CheckError "Reference to a removed localized document remains: $($file.FullName)" }
}

foreach ($removedPath in @('README.en.md', 'CONTRIBUTING.zh-CN.md')) {
    if (Test-Path -LiteralPath (Join-Path $root ($removedPath -replace '/', [IO.Path]::DirectorySeparatorChar))) {
        Add-CheckError "Removed localized path still exists: $removedPath"
    }
}
$removedDocsPath = Join-Path $root 'docs\zh-CN'
if ((Test-Path -LiteralPath $removedDocsPath) -and (Get-ChildItem -LiteralPath $removedDocsPath -Force | Select-Object -First 1)) {
    Add-CheckError 'Removed localized path still contains files: docs/zh-CN'
}

if ($errors.Count -gt 0) {
    $errors | ForEach-Object { Write-Host "ERROR: $_" -ForegroundColor Red }
    throw "Package validation failed with $($errors.Count) error(s)."
}
Write-Host "Package validation passed for version $expectedVersion`: 12 agents, role boundaries, plugin/skill references, UTF-8, English-only public text, and public-content scans."
