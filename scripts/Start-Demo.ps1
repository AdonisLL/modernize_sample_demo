. (Join-Path $PSScriptRoot 'Common.ps1')

$repoRoot = Get-RepositoryRoot
$manifest = Get-Content (Join-Path $repoRoot 'compatibility.json') -Raw | ConvertFrom-Json
$runRoot = Join-Path (Get-LocalDataRoot) 'Run'
New-Item -ItemType Directory -Force -Path $runRoot | Out-Null

$started = @()
foreach ($name in @('accounts', 'documents', 'statements', 'portal')) {
    $component = $manifest.components | Where-Object name -eq $name
    if (-not $component.startProject) {
        Write-Warning "No startProject is recorded for $name. Build the component and update compatibility.json."
        continue
    }

    $startPath = Join-Path $repoRoot $component.startProject
    if (-not (Test-Path $startPath)) {
        throw "Start path not found for ${name}: $startPath"
    }

    if ($name -eq 'statements') {
        $iisExpress = Join-Path $env:ProgramFiles 'IIS Express\iisexpress.exe'
        if (-not (Test-Path $iisExpress)) {
            throw "IIS Express was not found at $iisExpress."
        }
        $process = Start-Process -FilePath $iisExpress -ArgumentList "/path:`"$startPath`"", '/port:8091' -WorkingDirectory $startPath -PassThru
        $executable = $iisExpress
    } elseif ($name -eq 'accounts') {
        $process = Start-Process -FilePath $startPath -ArgumentList '--noninteractive' -WorkingDirectory (Split-Path $startPath) -PassThru
        $executable = $startPath
    } else {
        $process = Start-Process -FilePath $startPath -WorkingDirectory (Split-Path $startPath) -PassThru
        $executable = $startPath
    }

    $started += [pscustomobject]@{ name = $name; id = $process.Id; executable = $executable }
    Start-Sleep -Seconds 1
}

$started | ConvertTo-Json | Set-Content (Join-Path $runRoot 'processes.json') -Encoding UTF8
$started | Format-Table -AutoSize

if (-not $started) {
    throw 'No processes were started. Complete compatibility.json after building the component repositories.'
}
