. (Join-Path $PSScriptRoot 'Common.ps1')

$results = @()

function Add-Check([string]$Name, [bool]$Passed, [string]$Detail) {
    $script:results += [pscustomobject]@{
        Check = $Name
        Passed = $Passed
        Detail = $Detail
    }
}

try {
    $msbuild = Get-MSBuildPath
    Add-Check 'Visual Studio MSBuild' $true $msbuild
} catch {
    Add-Check 'Visual Studio MSBuild' $false $_.Exception.Message
}

$referenceRoot = Join-Path ${env:ProgramFiles(x86)} 'Reference Assemblies\Microsoft\Framework\.NETFramework\v4.8'
Add-Check '.NET Framework 4.8 targeting pack' (Test-Path $referenceRoot) $referenceRoot

$iisExpress = Join-Path $env:ProgramFiles 'IIS Express\iisexpress.exe'
Add-Check 'IIS Express' (Test-Path $iisExpress) $iisExpress

$localDb = Get-Command SqlLocalDB.exe -ErrorAction SilentlyContinue
if ($localDb) {
    $instances = & $localDb.Source info 2>$null
    Add-Check 'SQL LocalDB' ($instances -contains 'MSSQLLocalDB') ($instances -join ', ')
} else {
    Add-Check 'SQL LocalDB' $false 'SqlLocalDB.exe was not found.'
}

$git = Get-Command git.exe -ErrorAction SilentlyContinue
Add-Check 'Git' ($null -ne $git) $(if ($git) { $git.Source } else { 'git.exe was not found.' })

$repoRoot = Get-RepositoryRoot
$missingSubmodules = @(
    Get-ChildItem (Join-Path $repoRoot 'apps') -Directory -ErrorAction SilentlyContinue |
        Where-Object { -not (Test-Path (Join-Path $_.FullName '.git')) } |
        Select-Object -ExpandProperty Name
)
Add-Check 'Initialized submodules' ($missingSubmodules.Count -eq 0) $(if ($missingSubmodules) { $missingSubmodules -join ', ' } else { 'All present.' })

$results | Format-Table -AutoSize
if ($results.Where({ -not $_.Passed }).Count -gt 0) {
    throw 'One or more prerequisites are missing.'
}
