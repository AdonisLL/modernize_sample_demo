# Contoso Legacy Bank repository instructions

This repository is the orchestration and workshop hub for five independent
private Git submodules. Product code belongs in the relevant component
repository under `apps\`; commit and push there before updating the hub's
submodule pointer.

The baseline intentionally targets .NET Framework 4.8 and demonstrates
WinForms, WCF, ASP.NET Web API 2, EF6, LocalDB, file queues, PDF generation,
and scheduled CSV processing. Do not silently modernize baseline technology
unless a modernization task explicitly requests it.

Preserve these observable behaviors:

- customer `CUST-1001` owns `CHK-10010001` and `SAV-10010002`;
- account and transaction reads use the WCF service on port 8090;
- statement requests use the HTTP API on port 8091 and produce a real PDF;
- batch imports are idempotent by external transaction ID;
- failures remain explicit and diagnostic without exposing secrets.

Use the Visual Studio MSBuild installation for classic projects. Before
cross-repository changes, run the component tests and the live workflows
documented in `docs\modernization-lab.md`. Keep synthetic data, endpoint
contracts, file schemas, documentation, and `compatibility.json` synchronized.
