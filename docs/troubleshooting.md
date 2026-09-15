# Troubleshooting

## Private submodules fail to clone

Confirm the active GitHub identity can read all component repositories:

```powershell
gh auth status
git submodule sync --recursive
git submodule update --init --recursive
```

## .NET Framework reference assemblies are missing

Install the .NET Framework 4.8 targeting pack through Visual Studio Installer. A modern `dotnet` SDK does not replace the classic targeting pack.

## MSBuild is not found

Run `scripts\Test-Prerequisites.ps1`. The scripts locate Visual Studio MSBuild with `vswhere.exe`; they do not assume `msbuild.exe` is on `PATH`.

## LocalDB is unavailable

```powershell
sqllocaldb info
sqllocaldb start MSSQLLocalDB
```

Install SQL Server Express LocalDB if the command is missing.

## A port is already in use

```powershell
Get-NetTCPConnection -LocalPort 8090,8091 -State Listen
```

Stop the specific owning process or update all producer and consumer configuration consistently. Do not terminate processes by name.

## Statement jobs remain pending

- Confirm the document worker is running.
- Confirm the statement service and worker resolve the same document root.
- Check `Pending`, `Processing`, `Completed`, and `Failed`.
- A failed job should have failure metadata; do not move it manually until diagnostics are captured.

## Batch file is moved to the error directory

Open the matching reconciliation report and check:

- exact CSV headers;
- valid invariant dates and decimal values;
- supported transaction type;
- known account number;
- duplicate `ExternalId`;
- account service availability.

## Windows ARM64

Classic .NET Framework tooling and dependencies may execute through x64 emulation. If a package, test adapter, IIS Express scenario, or designer is not compatible, use an x64 Windows machine or the Windows GitHub Actions workflow and document the limitation.
