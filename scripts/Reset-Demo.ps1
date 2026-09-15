param(
    [switch]$IncludeDatabase
)

. (Join-Path $PSScriptRoot 'Common.ps1')

& (Join-Path $PSScriptRoot 'Stop-Demo.ps1')

$dataRoot = Get-LocalDataRoot
foreach ($relativePath in @('Documents', 'Batch')) {
    $path = Join-Path $dataRoot $relativePath
    if (Test-Path $path) {
        Remove-Item -LiteralPath $path -Recurse -Force
    }
}

if ($IncludeDatabase) {
    Write-Warning 'Database reset is owned by the accounts repository. Run its documented reset command before restarting.'
}

& (Join-Path $PSScriptRoot 'Initialize-Demo.ps1')
