# GitHub Copilot App Modernization Lab

## Goal

Assess and modernize a working .NET Framework 4.8 banking estate while preserving observable behavior. Start from clean, passing baseline evidence and modernize in dependency order.

Official references:

- [GitHub Copilot app modernization](https://learn.microsoft.com/en-us/azure/developer/github-copilot-app-modernization/)
- [GitHub Copilot modernization repository](https://github.com/microsoft/github-copilot-modernization)
- [Modernize .NET applications](https://dotnet.microsoft.com/en-us/platform/modernize)
- [Port from .NET Framework to modern .NET](https://learn.microsoft.com/en-us/dotnet/core/porting/framework-overview)
- [ASP.NET migration tooling](https://learn.microsoft.com/en-us/aspnet/core/migration/fx-to-core/tooling)

Product commands and supported scenarios change. Recheck the official documentation before running a workshop rather than copying an old command from this repository.

For enterprise application estates split across repositories, continue with
[Multi-repository modernization scenarios](multi-repository-modernization.md).
It covers VS Code multi-root context, GitHub.com planning and issues, and
capability specifications with GitHub Spec Kit.

For a greenfield cloud-native application that incrementally replaces the
legacy estate, continue with the
[Greenfield cloud-native replacement playbook](greenfield-cloud-native-replacement-playbook.md).

## Baseline evidence

Before asking an agent to change code:

1. Record the hub and submodule commit SHAs.
2. Run `scripts\Test-Prerequisites.ps1`.
3. Run `scripts\Build-All.ps1`.
4. Run every component test suite.
5. Execute customer lookup, account history, statement generation, and batch import.
6. Save screenshots, a generated PDF, batch reconciliation output, endpoint addresses, and database row counts.
7. Record expected error behavior for unavailable services, malformed CSV, duplicate imports, and failed document jobs.

Do not accept an assessment produced from a baseline that does not build or run.

## Suggested assessment scope

Ask the modernization tooling to assess:

- target frameworks and classic project formats;
- NuGet packages and unsupported APIs;
- WCF contracts, bindings, hosting, faults, configuration, and consumers;
- Web API 2 hosting and HTTP contracts;
- EF6 model, initialization, LocalDB assumptions, and transaction behavior;
- WinForms presentation logic and service coupling;
- file queue atomicity, replay, idempotency, and local storage assumptions;
- scheduled batch hosting;
- logging, diagnostics, configuration, tests, and CI.

Expected assessment findings are described in each repository's `docs\modernization-notes.md`. Those notes describe constraints and desired outcomes, not a line-by-line implementation recipe.

## Modernization waves

### Wave 1: Baseline and contract freeze

- Capture behavior evidence.
- Inventory public operations, DTOs, JSON schemas, CSV schemas, and failure semantics.
- Add characterization tests where evidence is weak.
- Decide the target .NET release and hosting model using current support policy.

### Wave 2: Account service

- Move business and data code to modern .NET.
- Replace WCF endpoints with versioned ASP.NET Core REST endpoints.
- Move EF6 to EF Core.
- Preserve duplicate import, balance, ownership, and date-range behavior.
- Keep a temporary adapter or compatibility path until all consumers migrate.

### Wave 3: Statement service

- Move Web API 2 to ASP.NET Core.
- Replace the WCF client with a typed HTTP client.
- Add explicit timeouts, cancellation, and bounded retries for safe reads.
- Preserve HTTP request, status, and failure behavior or version the contract.

### Wave 4: Documents and batch

- Move both executables to modern .NET workers.
- Replace the document file queue with managed messaging.
- Replace local PDF storage with object storage.
- Move scheduled imports to a managed job host.
- Preserve atomic claim, idempotency, poison-message/file, replay, and reconciliation semantics.

### Wave 5: Portal

- Rebuild WinForms screens as a Blazor application.
- Move service orchestration behind typed clients and UI services.
- Preserve validation, formatting, role behavior, error states, and accessibility.
- Use the baseline screenshots as behavior evidence, not as a pixel-perfect requirement.

### Wave 6: Data and cloud configuration

- Migrate LocalDB to Azure SQL.
- Replace machine paths and endpoint settings with environment-aware configuration.
- Introduce managed identity and secretless service connections where supported.
- Add health checks, telemetry, dashboards, alerts, and deployment-safe database migration.

### Wave 7: Parity and retirement decision

- Run the same baseline scenarios against the modernized estate.
- Compare API payloads, balances, transaction ordering, PDFs, reconciliation counts, and error behavior.
- Test rollback while legacy endpoints still exist.
- Retire legacy components only after consumers and operational evidence are complete.

## Example agent requests

Keep requests bounded to one repository and one wave. For example:

> Assess the account service for migration from .NET Framework 4.8, WCF, and EF6 to a supported modern .NET release, ASP.NET Core REST, and EF Core. Do not change code. Identify contracts, consumers, unsupported dependencies, data risks, test gaps, coexistence needs, and a dependency-ordered plan.

> Implement only the approved account-service contract adapter and characterization tests. Preserve current WCF behavior and do not migrate consumers in this change.

Avoid requests such as "modernize everything." They hide dependency decisions and make parity difficult to prove.

## MCP-assisted workflow

MCP tools can supplement, but do not replace, repository-local evidence:

- Use approved GitHub tools to inspect repositories, issues, pull requests, and code references.
- Use Microsoft/Azure documentation tools to verify current .NET, GitHub Copilot, and Azure guidance.
- Use Azure discovery and pricing tools only when an authenticated subscription and explicit cloud-planning scope are available.
- Treat tool output as external evidence: record the source URL, retrieval context, and assumptions.
- Never send repository secrets, credentials, production data, or customer information to an external tool.
- Keep the applications runnable without MCP servers.

## Evidence template

For each wave, record:

| Evidence | Baseline | Modernized | Result |
|---|---|---|---|
| Commit SHA | | | |
| Build command | | | |
| Test command/result | | | |
| Customer lookup | | | |
| Account balances | | | |
| Transaction ordering | | | |
| Statement request/status | | | |
| PDF totals/content | | | |
| Batch accepted/duplicate/rejected counts | | | |
| Failure behavior | | | |
| Screenshot or artifact link | | | |

Any intentional behavior change must be documented and approved rather than reported as parity.
