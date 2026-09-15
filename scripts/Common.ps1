Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-RepositoryRoot {
    return (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
}

function Get-VsWherePath {
    $path = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'
    if (-not (Test-Path $path)) {
        throw "Visual Studio Installer's vswhere.exe was not found."
    }
    return $path
}

function Get-MSBuildPath {
    $vswhere = Get-VsWherePath
    $installation = & $vswhere -latest -products * -requires Microsoft.Component.MSBuild -property installationPath
    if (-not $installation) {
        throw 'Visual Studio Build Tools with MSBuild were not found.'
    }

    $path = Join-Path $installation 'MSBuild\Current\Bin\MSBuild.exe'
    if (-not (Test-Path $path)) {
        throw "MSBuild was not found at $path."
    }
    return $path
}

function Get-LocalDataRoot {
    if (-not $env:LOCALAPPDATA) {
        throw 'LOCALAPPDATA is not defined.'
    }
    return (Join-Path $env:LOCALAPPDATA 'ContosoLegacyBank')
}
