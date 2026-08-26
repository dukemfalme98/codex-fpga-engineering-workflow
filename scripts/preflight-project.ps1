[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$ProjectRoot,
    [ValidateSet('Build', 'Simulation', 'Lint')][string]$Purpose,
    [ValidateSet('XILINX', 'PANGO', 'ANLOGIC')][string]$ExpectedVendor,
    [string[]]$PreparedLibraryNames = @()
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$root = [IO.Path]::GetFullPath((Resolve-Path -LiteralPath $ProjectRoot).Path)
$issues = [Collections.Generic.List[string]]::new()
$detection = & (Join-Path $PSScriptRoot 'detect-vendor.ps1') -ProjectRoot $root
if ($detection.status -ne 'DETECTED') { $issues.Add($detection.message) }
elseif (-not [string]::IsNullOrWhiteSpace($ExpectedVendor) -and $detection.vendor -ne $ExpectedVendor) {
    $issues.Add("Configured vendor $ExpectedVendor does not match detected vendor $($detection.vendor).")
}

$requiredLists = switch ($Purpose) {
    'Build' { @(@{ Path='project/script/src_list.txt'; NonEmpty=$true }, @{ Path='project/script/ip_list.txt'; NonEmpty=$false }, @{ Path='project/script/include_dirs.txt'; NonEmpty=$false }, @{ Path='project/script/defines.txt'; NonEmpty=$false }) }
    'Simulation' { @(@{ Path='simulation/script/product_list.txt'; NonEmpty=$true }, @{ Path='simulation/script/src_list.txt'; NonEmpty=$true }, @{ Path='simulation/script/model_list.txt'; NonEmpty=$false }, @{ Path='simulation/script/ip_list.txt'; NonEmpty=$false }, @{ Path='simulation/script/include_dirs.txt'; NonEmpty=$false }, @{ Path='simulation/script/defines.txt'; NonEmpty=$false }) }
    'Lint' { @(@{ Path='linter/script/lint_list.txt'; NonEmpty=$true }) }
}
foreach ($listSpec in $requiredLists) {
    $relativeList = [string]$listSpec.Path
    $listPath = Join-Path $root ($relativeList -replace '/', [IO.Path]::DirectorySeparatorChar)
    if (-not (Test-Path -LiteralPath $listPath -PathType Leaf)) { $issues.Add("Missing file list: $relativeList"); continue }
    $usableEntries = 0
    foreach ($line in Get-Content -LiteralPath $listPath -Encoding UTF8) {
        $trimmed = $line.Trim()
        if ([string]::IsNullOrWhiteSpace($trimmed) -or $trimmed.StartsWith('#')) { continue }
        $usableEntries++
        $candidate = [IO.Path]::GetFullPath((Join-Path $root ($trimmed -replace '/', [IO.Path]::DirectorySeparatorChar)))
        if (-not (Test-Path -LiteralPath $candidate -PathType Leaf)) { $issues.Add("File list entry does not exist: $trimmed") }
    }
    if ($listSpec.NonEmpty -and $usableEntries -eq 0) { $issues.Add("File list is empty: $relativeList") }
}

$settingsPath = Join-Path $root 'project\script\setting.psd1'
$localPath = Join-Path $root 'project\script\toolchain.local.psd1'
if (-not (Test-Path -LiteralPath $settingsPath -PathType Leaf)) { $issues.Add('Missing project/script/setting.psd1.') }
$settings = if (Test-Path -LiteralPath $settingsPath -PathType Leaf) { Import-PowerShellDataFile -LiteralPath $settingsPath } else { @{} }
$local = if (Test-Path -LiteralPath $localPath -PathType Leaf) { Import-PowerShellDataFile -LiteralPath $localPath } else { @{} }

$commandKey = switch ($Purpose) { 'Build' { 'BuildCommand' } 'Simulation' { 'SimulatorCommand' } 'Lint' { 'LintCommand' } }
$command = if ($local.ContainsKey($commandKey)) { [string]$local[$commandKey] } else { '' }
if ([string]::IsNullOrWhiteSpace($command)) {
    $issues.Add("$commandKey is not configured in ignored project/script/toolchain.local.psd1.")
} elseif (-not (Test-Path -LiteralPath $command -PathType Leaf) -and $null -eq (Get-Command $command -ErrorAction SilentlyContinue)) {
    $issues.Add("Configured command is unavailable: $command")
}

if ($Purpose -eq 'Simulation') {
    if (-not $settings.ContainsKey('SimulationTop') -or [string]::IsNullOrWhiteSpace([string]$settings.SimulationTop)) { $issues.Add('SimulationTop is not configured.') }
    $requiredLibraries = if ($settings.ContainsKey('RequiredSimulationLibraries')) { @($settings.RequiredSimulationLibraries) } else { @() }
    $libraryMap = if ($local.ContainsKey('SimulationLibraries')) { $local.SimulationLibraries } else { @{} }
    foreach ($library in $requiredLibraries) {
        if (-not $libraryMap.ContainsKey([string]$library) -and [string]$library -notin $PreparedLibraryNames) {
            $issues.Add("MISSING_VENDOR_LIBRARY: $library. Provide an official compiled library mapping or a validated recipe; do not fabricate a model.")
        }
    }
}

$status = if ($issues.Count -eq 0) { 'PASS' } elseif ($issues | Where-Object { $_ -match 'MISSING_VENDOR_LIBRARY' }) { 'MISSING_VENDOR_LIBRARY' } else { 'UNVERIFIED' }
[pscustomobject]@{
    schema_version = '1.0.0'
    purpose = $Purpose
    status = $status
    vendor = $detection.vendor
    command = $command
    issues = @($issues)
    preparation_checklist = @(
        'Install or select the exact vendor tool and simulator version required by the project.',
        'Copy toolchain.local.psd1.example to toolchain.local.psd1 and set verified executable paths.',
        'Map only official simulation libraries that match the vendor, family, tool, and simulator version.',
        'Re-run the one-click wrapper; do not substitute approximate primitive models.'
    )
}
