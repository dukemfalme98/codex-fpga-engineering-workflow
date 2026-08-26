[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)][string]$Destination,
    [Parameter(Mandatory)][ValidatePattern('^[A-Za-z0-9_.-]+$')][string]$ProjectName,
    [Parameter(Mandatory)][ValidatePattern('^[A-Za-z_][A-Za-z0-9_$]*$')][string]$TopModule,
    [Parameter(Mandatory)][ValidateSet('XILINX', 'PANGO', 'ANLOGIC')][string]$Vendor,
    [string]$ToolVersion = 'UNVERIFIED',
    [string]$Device = 'UNVERIFIED',
    [string]$Package = 'UNVERIFIED',
    [string]$SimulationTop,
    [string]$DefaultSimulationCase = 'smoke',
    [switch]$WithIp,
    [switch]$WithLintBlackBox,
    [switch]$WithGolden
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$packageRoot = [IO.Path]::GetFullPath((Split-Path -Parent $PSScriptRoot))
$templateRoot = Join-Path $packageRoot 'templates\fpga-project'
$destinationFull = [IO.Path]::GetFullPath($Destination)
if (Test-Path -LiteralPath $destinationFull) {
    if (-not (Test-Path -LiteralPath $destinationFull -PathType Container)) { throw "Destination is not a directory: $destinationFull" }
    if (Get-ChildItem -LiteralPath $destinationFull -Force | Select-Object -First 1) { throw "Destination must be new or empty: $destinationFull" }
}
if ([string]::IsNullOrWhiteSpace($SimulationTop)) { $SimulationTop = "tb_$TopModule" }

$vendorSpec = switch ($Vendor) {
    'XILINX' { @{ Extension = '.xpr'; BuildAdapter = 'build_xilinx.ps1'; SimulationAdapter = 'sim_xilinx.ps1' } }
    'PANGO' { @{ Extension = '.pds'; BuildAdapter = 'build_pango.ps1'; SimulationAdapter = 'sim_pango.ps1' } }
    'ANLOGIC' { @{ Extension = '.al'; BuildAdapter = 'build_anlogic.ps1'; SimulationAdapter = 'sim_anlogic.ps1' } }
}
$tokens = [ordered]@{
    '__PROJECT_NAME__' = $ProjectName
    '__TOP_MODULE__' = $TopModule
    '__VENDOR__' = $Vendor
    '__TOOL_VERSION__' = $ToolVersion
    '__DEVICE__' = $Device
    '__PACKAGE__' = $Package
    '__SIMULATION_TOP__' = $SimulationTop
    '__DEFAULT_CASE__' = $DefaultSimulationCase
    '__BUILD_ADAPTER__' = $vendorSpec.BuildAdapter
    '__SIMULATION_ADAPTER__' = $vendorSpec.SimulationAdapter
    '__PROJECT_EXTENSION__' = $vendorSpec.Extension
}

function Expand-Template([string]$Source, [string]$Target) {
    $text = [IO.File]::ReadAllText($Source, [Text.UTF8Encoding]::new($false, $true))
    foreach ($entry in $tokens.GetEnumerator()) { $text = $text.Replace([string]$entry.Key, [string]$entry.Value) }
    $parent = Split-Path -Parent $Target
    if (-not (Test-Path -LiteralPath $parent -PathType Container)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
    [IO.File]::WriteAllText($Target, $text, [Text.UTF8Encoding]::new($false))
}

if (-not $PSCmdlet.ShouldProcess($destinationFull, "Create $Vendor FPGA project scaffold")) { return }
New-Item -ItemType Directory -Path $destinationFull -Force | Out-Null
$directories = @(
    'document', 'project/rtl', 'project/sdc', 'project/par', 'project/script', 'project/script/ai_run',
    'simulation/tb/case', 'simulation/script', 'simulation/script/ai_run',
    'linter/script', 'linter/script/ai_run', 'release/output'
)
if ($WithIp) { $directories += @('project/ip/synth','project/ip/sim') }
if ($WithLintBlackBox) { $directories += 'linter/lint_bb' }
if ($WithGolden) { $directories += 'release/golden' }
foreach ($relative in $directories) { New-Item -ItemType Directory -Path (Join-Path $destinationFull ($relative -replace '/', [IO.Path]::DirectorySeparatorChar)) -Force | Out-Null }

Expand-Template (Join-Path $templateRoot 'common\README.md.template') (Join-Path $destinationFull 'README.md')
Expand-Template (Join-Path $templateRoot 'common\AGENTS.md') (Join-Path $destinationFull 'AGENTS.md')
Expand-Template (Join-Path $templateRoot 'common\.gitignore.template') (Join-Path $destinationFull '.gitignore')
Expand-Template (Join-Path $templateRoot 'common\setting.psd1.template') (Join-Path $destinationFull 'project\script\setting.psd1')
Expand-Template (Join-Path $templateRoot 'common\toolchain.local.psd1.example') (Join-Path $destinationFull 'project\script\toolchain.local.psd1.example')

foreach ($scriptDir in @('project\script','simulation\script','linter\script')) {
    Expand-Template (Join-Path $templateRoot 'common\run.bat.template') (Join-Path $destinationFull "$scriptDir\run.bat")
}
Expand-Template (Join-Path $templateRoot 'common\build-run.ps1.template') (Join-Path $destinationFull 'project\script\ai_run\run.ps1')
Expand-Template (Join-Path $templateRoot 'common\simulation-run.ps1.template') (Join-Path $destinationFull 'simulation\script\ai_run\run.ps1')
Expand-Template (Join-Path $templateRoot 'common\lint-run.ps1.template') (Join-Path $destinationFull 'linter\script\ai_run\run.ps1')
Expand-Template (Join-Path $templateRoot 'adapters\build-adapter.ps1.template') (Join-Path $destinationFull "project\script\ai_run\$($vendorSpec.BuildAdapter)")
Expand-Template (Join-Path $templateRoot 'adapters\simulation-adapter.ps1.template') (Join-Path $destinationFull "simulation\script\ai_run\$($vendorSpec.SimulationAdapter)")

Copy-Item -LiteralPath (Join-Path $packageRoot 'scripts\detect-vendor.ps1') -Destination (Join-Path $destinationFull 'project\script\ai_run\detect-vendor.ps1')
Copy-Item -LiteralPath (Join-Path $packageRoot 'scripts\update-filelists.ps1') -Destination (Join-Path $destinationFull 'project\script\ai_run\update_filelist.ps1')
Copy-Item -LiteralPath (Join-Path $packageRoot 'scripts\preflight-project.ps1') -Destination (Join-Path $destinationFull 'project\script\ai_run\preflight.ps1')
Copy-Item -LiteralPath (Join-Path $packageRoot 'scripts\prepare-vendor-libraries.ps1') -Destination (Join-Path $destinationFull 'project\script\ai_run\prepare_vendor_libraries.ps1')

foreach ($relative in @('project\script\src_list.txt','project\script\ip_list.txt','project\script\include_dirs.txt','project\script\defines.txt','project\script\compile_order.txt','simulation\script\product_list.txt','simulation\script\src_list.txt','simulation\script\model_list.txt','simulation\script\ip_list.txt','simulation\script\include_dirs.txt','simulation\script\defines.txt','simulation\script\compile_order.txt','linter\script\lint_list.txt')) {
    [IO.File]::WriteAllText((Join-Path $destinationFull $relative), '', [Text.UTF8Encoding]::new($false))
}
[IO.File]::WriteAllText((Join-Path $destinationFull 'simulation\script\cases.txt'), $DefaultSimulationCase + [Environment]::NewLine, [Text.UTF8Encoding]::new($false))

$target = [ordered]@{
    schema_version = '1.0.0'
    target_id = "$ProjectName-$($Vendor.ToLowerInvariant())"
    vendor = $Vendor
    tool = @{ version = $ToolVersion; project_file = $null }
    top = $TopModule
    device = $Device
    package = $Package
    simulation = @{ top = $SimulationTop; default_case = $DefaultSimulationCase; required_libraries = @() }
    selected_adapter = @{ build = $vendorSpec.BuildAdapter; simulation = $vendorSpec.SimulationAdapter }
    status = 'UNVERIFIED'
}
[IO.File]::WriteAllText((Join-Path $destinationFull 'project\target.fpga.json'), (($target | ConvertTo-Json -Depth 8) + [Environment]::NewLine), [Text.UTF8Encoding]::new($false))

[pscustomobject]@{
    status = 'SCAFFOLDED_UNVERIFIED'
    project_root = $destinationFull
    vendor = $Vendor
    build_adapter = $vendorSpec.BuildAdapter
    simulation_adapter = $vendorSpec.SimulationAdapter
    next_step = "Add exactly one $($vendorSpec.Extension) project file under project/par, configure toolchain.local.psd1, then double-click run.bat."
}
