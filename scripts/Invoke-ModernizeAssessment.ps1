param(
    [string]$OutputPath = 'artifacts\modernize-assessment',
    [string]$IssueUrl
)

$ErrorActionPreference = 'Stop'

$modernize = Get-Command modernize -ErrorAction SilentlyContinue
if (-not $modernize) {
    throw @'
The Modernize CLI is not installed. On Windows, install it with:
  winget install GitHub.Copilot.modernization.agent
Open a new terminal after installation.
'@
}

$repositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$source = Join-Path $repositoryRoot '.github\modernize\repos.json'
$output = if ([System.IO.Path]::IsPathRooted($OutputPath)) {
    $OutputPath
} else {
    Join-Path $repositoryRoot $OutputPath
}

$arguments = @(
    'assess',
    '--source', $source,
    '--output-path', $output,
    '--format', 'markdown',
    '--delegate', 'local'
)

if ($IssueUrl) {
    $arguments += @('--issue-url', $IssueUrl)
}

Write-Host 'Running assessment-only multi-repository analysis.'
Write-Host "Repository configuration: $source"
Write-Host "Assessment output: $output"
Write-Host 'This script does not run plan create, plan execute, or upgrade.'

& $modernize.Source @arguments
if ($LASTEXITCODE -ne 0) {
    throw "Modernize assessment failed with exit code $LASTEXITCODE."
}
