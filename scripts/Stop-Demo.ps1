. (Join-Path $PSScriptRoot 'Common.ps1')

$processFile = Join-Path (Join-Path (Get-LocalDataRoot) 'Run') 'processes.json'
if (-not (Test-Path $processFile)) {
    Write-Host 'No hub-managed process file exists.'
    return
}

$processes = @(Get-Content $processFile -Raw | ConvertFrom-Json)
foreach ($entry in $processes) {
    $process = Get-Process -Id $entry.id -ErrorAction SilentlyContinue
    if ($process) {
        Stop-Process -Id $process.Id
        Write-Host "Stopped $($entry.name) (PID $($entry.id))."
    }
}

Remove-Item $processFile
