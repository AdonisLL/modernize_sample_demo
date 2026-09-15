. (Join-Path $PSScriptRoot 'Common.ps1')

$repoRoot = Get-RepositoryRoot
& git -C $repoRoot submodule update --init --recursive
if ($LASTEXITCODE -ne 0) {
    throw 'Failed to initialize Git submodules.'
}

& (Join-Path $PSScriptRoot 'Test-Prerequisites.ps1')

$dataRoot = Get-LocalDataRoot
$directories = @(
    'Documents\Pending',
    'Documents\Processing',
    'Documents\Completed',
    'Documents\Failed',
    'Documents\Output',
    'Batch\Input',
    'Batch\Archive',
    'Batch\Error',
    'Batch\Reports',
    'Run'
)

foreach ($directory in $directories) {
    New-Item -ItemType Directory -Force -Path (Join-Path $dataRoot $directory) | Out-Null
}

& SqlLocalDB.exe start MSSQLLocalDB | Out-Null

Write-Host "Initialized local integration folders at $dataRoot"
Write-Host 'Build the estate with scripts\Build-All.ps1. The account service initializes synthetic database data on first run.'
