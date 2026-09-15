param(
    [ValidateSet('Debug', 'Release')]
    [string]$Configuration = 'Release'
)

. (Join-Path $PSScriptRoot 'Common.ps1')

$repoRoot = Get-RepositoryRoot
$msbuild = Get-MSBuildPath
$solutions = Get-ChildItem (Join-Path $repoRoot 'apps') -Filter *.sln -Recurse |
    Sort-Object FullName

if (-not $solutions) {
    throw 'No component solutions were found. Initialize the submodules first.'
}

foreach ($solution in $solutions) {
    Write-Host "Building $($solution.FullName)"
    & $msbuild $solution.FullName /restore /m /nologo /verbosity:minimal /p:Configuration=$Configuration
    if ($LASTEXITCODE -ne 0) {
        throw "Build failed: $($solution.FullName)"
    }
}

Write-Host "Built $($solutions.Count) solutions."
