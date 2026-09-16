# Contoso Legacy Bank

Contoso Legacy Bank is a deliberately legacy, end-to-end .NET Framework 4.8 application estate for demonstrating assessment and modernization with GitHub Copilot app modernization tooling.

The applications are old by design, but they are expected to build, run, and handle failures correctly. They contain synthetic data only and do not intentionally include exploitable vulnerabilities.

## Application estate

| Component | Legacy technology | Responsibility | Modernization target |
|---|---|---|---|
| [Portal](apps/contoso-legacy-bank-portal) | WinForms, WCF client, synchronous orchestration | Customer search, accounts, transactions, statement requests | Blazor and async REST clients |
| [Accounts](apps/contoso-legacy-bank-accounts) | WCF, EF6, SQL LocalDB | Customers, accounts, balances, transactions | ASP.NET Core REST, EF Core, Azure SQL |
| [Statements](apps/contoso-legacy-bank-statements) | ASP.NET Web API 2 | Statement orchestration and status | ASP.NET Core API and resilient clients |
| [Documents](apps/contoso-legacy-bank-documents) | Console/Windows Service worker, file queue, PDFsharp | PDF statement generation | Modern .NET worker, managed queue, Blob Storage |
| [Batch](apps/contoso-legacy-bank-batch) | Scheduled console app, CSV files | Nightly transaction import and reconciliation | Azure Functions or Container Apps Jobs |

See [the architecture guide](docs/architecture.md) for component and data flows.

## Prerequisites

- Windows 10 or later
- Git with submodule support
- Visual Studio 2022 or Build Tools with:
  - .NET desktop build tools
  - .NET Framework 4.8 targeting pack
  - ASP.NET and web development build tools
- SQL Server Express LocalDB
- PowerShell 5.1 or later
- Access to all six private repositories

Check the machine:

```powershell
.\scripts\Test-Prerequisites.ps1
```

## Clone and initialize

```powershell
git clone --recurse-submodules https://github.com/AdonisLL/modernize_sample_demo.git
Set-Location modernize_sample_demo
.\scripts\Initialize-Demo.ps1
.\scripts\Build-All.ps1
```

For an existing clone:

```powershell
git submodule update --init --recursive
```

## Run the demo

The supported startup order is:

1. Accounts WCF host
2. Documents worker
3. Statements API
4. Portal
5. Batch importer on demand

After all component repositories have been built:

```powershell
.\scripts\Start-Demo.ps1
```

Use the seeded customer numbers shown by the initialization script. Request a statement from the portal, wait for the document worker to complete it, and open the resulting PDF. Run the batch sample separately:

```powershell
.\scripts\Invoke-BatchSample.ps1
```

Stop processes started by the hub:

```powershell
.\scripts\Stop-Demo.ps1
```

Reset generated data and local integration folders:

```powershell
.\scripts\Reset-Demo.ps1
```

## Modernization workshop

The [modernization lab](docs/modernization-lab.md) provides:

- baseline evidence and assessment steps;
- expected modernization findings without hiding the solution in prompts;
- modernization waves for WCF, Web API 2, workers, WinForms, and data;
- GitHub Copilot and MCP-assisted research guidance;
- behavior-parity and before/after evidence templates.

The [multi-repository modernization scenarios](docs/multi-repository-modernization.md)
show how to:

- open all five application repositories in one VS Code multi-root workspace;
- run an assessment-only multi-repository scan with the Modernize CLI;
- use Copilot Spaces on GitHub.com for shared cross-repository planning;
- publish an approved roadmap as a hub epic and repository-owned issues;
- extract legacy capabilities into evidence-backed specifications and apply
  GitHub Spec Kit to bounded modernization changes.

The proposed Azure destination is documented separately in [Azure target architecture](docs/azure-target-architecture.md). The legacy baseline does not require an Azure subscription and does not deploy cloud resources.

## Repository model

The five applications are independent Git repositories pinned here as submodules. Commit inside the relevant component repository first, then update the submodule pointer in this hub. Do not treat files under `apps\` as ordinary files owned by the hub.

Known-good component revisions and local ports are recorded in [`compatibility.json`](compatibility.json).

## Documentation

- [Architecture](docs/architecture.md)
- [Modernization lab](docs/modernization-lab.md)
- [Multi-repository modernization scenarios](docs/multi-repository-modernization.md)
- [Azure target architecture](docs/azure-target-architecture.md)
- [Troubleshooting](docs/troubleshooting.md)

## License

This hub is licensed under the [MIT License](LICENSE). Each component repository carries its own license and third-party notices.
