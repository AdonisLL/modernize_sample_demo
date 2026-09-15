. (Join-Path $PSScriptRoot 'Common.ps1')

$repoRoot = Get-RepositoryRoot
$manifest = Get-Content (Join-Path $repoRoot 'compatibility.json') -Raw | ConvertFrom-Json
$component = $manifest.components | Where-Object name -eq 'batch'

if (-not $component.startProject) {
    throw 'The batch startProject is not recorded in compatibility.json.'
}

$executable = Join-Path $repoRoot $component.startProject
if (-not (Test-Path $executable)) {
    throw "Batch executable not found: $executable"
}

$inputRoot = Join-Path (Get-LocalDataRoot) 'Batch\Input'
New-Item -ItemType Directory -Force -Path $inputRoot | Out-Null
if (-not (Get-ChildItem $inputRoot -Filter *.csv -File -ErrorAction SilentlyContinue)) {
    $sample = Join-Path $repoRoot 'apps\contoso-legacy-bank-batch\samples\valid.csv'
    if (-not (Test-Path $sample)) {
        throw "Batch sample not found: $sample"
    }
    Copy-Item $sample (Join-Path $inputRoot 'valid.csv')
}

& $executable
if ($LASTEXITCODE -ne 0) {
    throw "Batch sample failed with exit code $LASTEXITCODE."
}
