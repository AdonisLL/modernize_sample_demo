# Multi-repository modernization scenarios

Contoso Legacy Bank is intentionally split across repositories so an
enterprise modernization exercise can distinguish application-wide planning
from repository-scoped implementation.

This guide covers four scenarios:

1. analyze all five application repositories in Visual Studio Code;
2. run an assessment-only multi-repository scan with the Modernize CLI;
3. plan across repositories on GitHub.com and publish the plan as issues;
4. extract current behavior into evidence-backed capability specifications,
   then use GitHub Spec Kit for bounded modernization changes.

## Shared operating model

Use the hub as the system-of-record for application-wide decisions:

- `docs\architecture.md` describes the current system;
- `compatibility.json` pins the repository revisions used by the analysis;
- application-wide plans and dependency maps belong in the hub;
- implementation issues and pull requests belong in the repository that owns
  the changed code;
- every plan must identify evidence, assumptions, unknowns, dependencies,
  coexistence requirements, validation, and rollback.

Cross-repository context does not make a multi-repository change atomic. Each
repository has independent permissions, branches, CI, releases, and rollback.

When the goal is to replace the estate with a new application rather than
upgrade each component in place, use the
[Greenfield cloud-native replacement playbook](greenfield-cloud-native-replacement-playbook.md).

## Scenario 1: Visual Studio Code multi-repository assessment

### Goal

Give a modernization agent local read access to every application repository
so it can trace contracts and consumers before proposing a future state.

### Prepare the workspace

Clone and initialize the hub:

```powershell
git clone --recurse-submodules https://github.com/AdonisLL/modernize_sample_demo.git
Set-Location modernize_sample_demo
.\scripts\Initialize-Demo.ps1
code .\contoso-legacy-bank-multi-repo.code-workspace
```

The workspace opens each application as a named root. VS Code search and
workspace indexing can operate across all roots, while Source Control retains
the independent repository boundaries.

Before assessment:

1. confirm all repositories are at the revisions in `compatibility.json`;
2. run the baseline build and tests;
3. make sure repository trust and Copilot policies permit all five private
   repositories;
4. review each repository's `.github\copilot-instructions.md`;
5. start with read-only assessment rather than implementation.

### Build the agent context

There are two related but different VS Code workflows. Use **multi-root Chat**
for interactive questions across the whole workspace. Use the **Agents
window** when you want a longer-running agent session with one explicit
execution repository.

#### Option A: Ask cross-repository questions in Chat

1. Open `contoso-legacy-bank-multi-repo.code-workspace`.
2. Open the Chat view.
3. Start the prompt with `#codebase` when you want VS Code workspace indexing
   to locate relevant files across all five roots.
4. State that the repositories form one application and name the flow you want
   traced.
5. Add specific files or folders when they are required evidence.

Example:

> #codebase Analyze the statement-generation workflow across the Portal,
> Accounts, Statements, and Documents repositories. Trace the request from the
> WinForms event through WCF and Web API 2 to the JSON job and generated PDF.
> Remain read-only. Cite repository paths for every contract and consumer.

`#codebase` means "search the indexed workspace for relevant context." It does
not guarantee that every file in every repository is sent to the model. The
context window is finite, so VS Code selects files it considers relevant.

Use `#codebase` for:

- discovering where a capability is implemented;
- finding producers and consumers of a contract;
- comparing patterns across repositories;
- locating configuration, tests, and dependencies;
- answering questions when you do not already know the important files.

Do not rely on `#codebase` alone when a particular file must be considered.

#### Add required evidence explicitly

In the Chat view, select **Add Context**, then choose **Files & Folders**, or
drag files and folders from Explorer into Chat.

For an application-wide Contoso assessment, explicitly attach:

| Purpose | Context to attach |
|---|---|
| Current architecture | Hub `docs\architecture.md` |
| Verified repository revisions | Hub `compatibility.json` |
| Modernization rules | Hub `docs\modernization-lab.md` and `.github\copilot-instructions.md` |
| WCF producer contract | Accounts `src\Contoso.LegacyBank.Accounts.Contracts` |
| WCF consumers | Portal `src\...\Services`; Statements `src\...\Services`; Batch `src\...` |
| Statement file contract | Statements `docs\statement-job-schema.md`; Documents `Models` and `samples` |
| Runtime configuration | Component `App.config` and `Web.config` files |
| Behavior evidence | Component test projects and sample data |

If the hub file is not visible as a workspace root, use **Add Context →
Files & Folders** and browse to the hub path, or open the file first and attach
the active editor tab.

Explicit attachment means "this evidence must be considered." It is useful
for contracts, configuration, tests, and architecture decisions that a
relevance search might otherwise omit.

Example:

> Using the attached WCF contract, all three attached consumer implementations,
> architecture.md, and compatibility.json, build a producer/consumer matrix.
> Identify operation, DTO, fault, endpoint, versioning, coexistence, and
> migration-order requirements. Treat attached files as authoritative for the
> recorded baseline revision.

#### Option B: Start a session in the Agents window

When starting an agent session, VS Code asks you to choose a folder or
repository. The first selection is the **primary execution workspace**.

Choose the primary workspace based on the intended output:

| Session goal | Recommended primary workspace |
|---|---|
| Read-only application assessment or hub documentation | `modernize_sample_demo` hub |
| WCF-to-REST implementation | `contoso-legacy-bank-accounts` |
| Statement API migration | `contoso-legacy-bank-statements` |
| WinForms-to-Blazor implementation | `contoso-legacy-bank-portal` |
| PDF worker modernization | `contoso-legacy-bank-documents` |
| Batch modernization | `contoso-legacy-bank-batch` |

For an analysis-only session:

1. Open the Agents window and start a new session.
2. Select the `modernize_sample_demo` hub as the primary workspace.
3. Attach each component repository with **Folder** or **Repository**.
4. Attach `docs\architecture.md`, `compatibility.json`, and the modernization
   lab.
5. State: "Remain read-only; write the approved assessment only to the hub."

For a repository implementation session:

1. Select the repository that will own the code change as primary.
2. Attach the hub architecture, approved work package, and relevant producer
   or consumer repositories.
3. State which attached repositories are context only.
4. Require the agent to stop if the change needs an unapproved edit in another
   repository.

Example:

> The Accounts repository is the primary execution workspace. The Portal,
> Statements, and Batch repositories are attached as read-only consumer
> context. Implement only the approved REST compatibility endpoint in
> Accounts. Do not edit consumers. If contract evidence shows the approved
> design is incompatible, stop and report the conflict.

#### What "primary" and "attached" mean

| Term | Meaning |
|---|---|
| Primary execution workspace | Where the agent runs commands, creates branches, edits files, and produces commits for the session |
| Attached repository | Additional source context the agent can inspect for the request |
| Explicit file/folder context | Evidence intentionally included in the prompt |
| `#codebase` | A request for workspace indexing to find likely relevant code |

Attached repositories should not be treated as additional writable execution
roots. Even if an environment technically exposes their files, the safe
enterprise pattern is one owning repository per implementation session.

#### Recommended analysis-only prompt

> The hub is the primary workspace. The five component repositories are
> attached as read-only context. Analyze the complete Contoso Legacy Bank
> application. Use #codebase to discover relevant implementation, but treat
> the attached architecture, compatibility manifest, contracts, configuration,
> and tests as required evidence. Do not modify product code. Produce a
> current-state inventory, contract/consumer matrix, business workflow map,
> target architecture, decisions and unknowns, dependency-ordered waves, and
> one repository-owned work package per independently reviewable change.

### Recommended assessment sequence

Run one application-wide assessment before repository plans:

1. **Inventory boundaries**: repositories, projects, frameworks, runtime
   processes, data stores, file stores, endpoints, startup order, and owners.
2. **Trace contracts**: WCF operations and DTOs, HTTP endpoints, statement job
   JSON, batch CSV, database entities, and error semantics.
3. **Trace consumers**: identify every producer and consumer of each contract.
4. **Find shared constraints**: .NET Framework 4.8, Windows hosting, LocalDB,
   synchronous calls, identity, observability, release order, and rollback.
5. **Propose the future state**: target runtime, APIs, data, messaging,
   storage, UI, hosting, identity, telemetry, and coexistence.
6. **Create dependency waves**: contract adapters before consumer migrations;
   characterization tests before replacement; retirement last.
7. **Split implementation ownership**: produce one work package per repository
   and mark cross-repository dependencies explicitly.

### Example assessment prompt

> Analyze all five Contoso Legacy Bank repositories as one application.
> Remain read-only. Trace every runtime dependency and contract from producer
> to consumer, including WCF, HTTP, JSON files, CSV files, LocalDB, and PDF
> output. Propose a dependency-ordered future state using supported modern
> .NET and Azure services. Separate observed facts from assumptions and
> unknowns. Produce an application-level roadmap followed by independently
> implementable repository work packages. Do not assume a cross-repository
> change can be committed or rolled back atomically.

### Expected output

The assessment should contain:

- current-state component and sequence diagrams;
- contract and consumer matrix;
- compatibility and unsupported-technology findings;
- target architecture and decisions still requiring approval;
- modernization waves;
- per-repository work packages;
- end-to-end parity tests;
- coexistence, deployment-order, and rollback guidance.

Save approved application-wide artifacts in the hub. Keep implementation plans
next to the repository that owns the code.

For repeatable assessment across a larger portfolio, evaluate the
[GitHub Copilot modernization agent](https://learn.microsoft.com/en-us/azure/developer/github-copilot-app-modernization/modernization-agent/overview).
Its documented Assess, Plan, Execute model includes multi-repository
assessment, reusable modernization skills, structured plans, and batch
operations. Use the VS Code scenario for interactive investigation and the
Modernize CLI when the enterprise requirement is governed portfolio-scale
repeatability.

## Scenario 2: Modernize CLI assessment only

### Goal

Assess all five repositories as one logical application and generate
per-repository plus aggregated reports without creating a plan, changing code,
or executing an upgrade.

The Modernize CLI supports an **Assess, Plan, Execute** lifecycle. In this
scenario, stop after **Assess**.

### Install and authenticate

On Windows:

```powershell
winget install GitHub.Copilot.modernization.agent
```

Open a new terminal, then verify and authenticate:

```powershell
modernize --version
gh auth login
gh auth status
```

The GitHub identity must be able to clone all five private repositories.

### Repository configuration

The hub includes `.github\modernize\repos.json`. It:

- lists the five component repositories and their `main` branches;
- groups them as the logical application `contoso-legacy-bank`;
- uses GitHub URLs so the same configuration can support either local
  execution or cloud delegation;
- excludes the hub itself from code assessment because it contains
  orchestration and documentation rather than an application project.

Record the exact assessed commit SHAs in the final report. A branch name can
move after assessment, while `compatibility.json` records the verified
baseline revisions.

### Run the assessment locally

The repository wrapper runs only `modernize assess`:

```powershell
.\scripts\Invoke-ModernizeAssessment.ps1
```

It is equivalent to:

```powershell
modernize assess `
  --source .github\modernize\repos.json `
  --output-path artifacts\modernize-assessment `
  --format markdown `
  --delegate local
```

The script intentionally does not call:

- `modernize plan create`;
- `modernize plan execute`;
- `modernize upgrade`.

Generated reports are placed beneath `artifacts\modernize-assessment`, which
is ignored by Git. Review and redact reports before copying selected results
into a repository or issue.

### Use interactive mode for full codebase insights

The interactive workflow is useful when you want to select analysis domains
and coverage:

1. Run `modernize`.
2. Select **Assess**.
3. Select **From a config file**.
4. Accept `.github\modernize\repos.json`.
5. Keep all five repositories selected.
6. Select the .NET **Upgrade** and **Cloud Readiness** domains.
7. Select **Full analysis** to request codebase insights for architecture,
   API contracts, configuration, business workflows, dependencies, and data
   models.
8. Select **Assess locally**.
9. Choose an output directory.
10. When assessment completes, review the aggregated and per-repository
    reports, then return to the main menu instead of creating or executing a
    plan.

The documented .NET security domain coverage may differ from Java coverage.
Do not treat absence of security findings as a security review.

### Publish a summary to the hub epic

The CLI can update a GitHub issue with an assessment summary:

```powershell
.\scripts\Invoke-ModernizeAssessment.ps1 `
  -IssueUrl 'https://github.com/AdonisLL/modernize_sample_demo/issues/123'
```

Use the hub modernization epic rather than a component implementation issue
for the aggregated summary. The detailed reports can contain file paths,
dependency versions, configuration names, and architectural findings, so
review them before wider distribution.

### Optional cloud delegation

For a larger portfolio, the CLI can delegate repository assessments to
Copilot cloud agents in parallel:

```powershell
modernize assess `
  --source .github\modernize\repos.json `
  --output-path artifacts\modernize-assessment `
  --format markdown `
  --delegate cloud `
  --wait
```

For these .NET Framework repositories, cloud delegation requires each
repository to provide an appropriate Windows Copilot setup workflow and the
necessary repository policy configuration. Local paths and non-GitHub
repositories cannot be used for cloud delegation.

Start with local execution for this demo. Move to cloud delegation only after
the local assessment output and organization policies are understood.

### Review checklist

- [ ] All five repositories were assessed successfully.
- [ ] Assessed commit SHAs were recorded.
- [ ] Per-repository reports were generated.
- [ ] The aggregated report treats the repositories as one application.
- [ ] WCF producers and consumers were correlated.
- [ ] File job and CSV contracts were identified.
- [ ] LocalDB and Windows-only dependencies were identified.
- [ ] Facts, recommendations, and unsupported assumptions were separated.
- [ ] No plan or execution command was run.
- [ ] Reports were reviewed before issue publication.

### Expected handoff

The assessment-only output should feed, but not automatically approve:

- the GitHub.com planning scenario;
- capability specifications;
- architecture decisions;
- dependency-ordered repository work packages;
- later `modernize plan create` runs after human review.

## Scenario 3: GitHub.com planning with Copilot Spaces and issues

### Goal

Plan the same modernization without requiring one local workspace, while
keeping decisions reviewable and turning the approved roadmap into an
enterprise backlog.

### Create the shared context

Create a private Copilot Space on GitHub.com and add:

- all six repositories;
- the hub architecture and modernization lab;
- the five component READMEs and modernization notes;
- relevant issues and pull requests;
- organization standards, target-platform decisions, and workshop notes;
- approved Microsoft and GitHub documentation links.

Copilot Spaces can include repositories, code, issues, pull requests, notes,
images, and uploaded files. GitHub-backed sources stay synchronized, but users
can only see sources they already have permission to access.

Suggested Space instructions:

> Treat the hub as the application-level source of truth. Cite repository and
> file evidence for every current-state claim. Separate facts, assumptions,
> and unresolved decisions. Do not propose implementation until contracts,
> consumers, sequencing, coexistence, parity, and rollback are documented.

### Produce and review the plan

Ask Copilot Chat in the Space to produce:

1. a current-state inventory;
2. a contract/consumer matrix;
3. an approved-decision and open-decision log;
4. a target architecture;
5. dependency-ordered modernization waves;
6. one work package for each independently reviewable repository change.

Review the result with application owners before creating issues. A Space is
shared planning context, not approval authority.

### Publish the backlog

Use one hub issue as the application modernization epic. Use
`.github\ISSUE_TEMPLATE\cross-repository-modernization.yml` when creating it.

Then create implementation issues in the owning repositories. Each issue
should include:

- stable work-package ID;
- owning repository and affected projects;
- current-state evidence;
- required outcome and non-goals;
- contract or schema changes;
- dependencies by fully qualified issue URL;
- acceptance and parity criteria;
- coexistence and rollback requirements;
- documentation and test updates.

Example:

```powershell
gh issue create `
  --repo AdonisLL/contoso-legacy-bank-accounts `
  --title "[MOD-001] Add REST compatibility API beside WCF" `
  --body-file .\docs\templates\modernization-work-package.md
```

Create issues in dependency order, but do not assign them to an implementation
agent until their architectural decisions and dependencies are approved.

### Use Copilot cloud agent safely

Copilot cloud agent can research a repository, create an implementation plan,
make changes on a branch, and optionally open a pull request. Treat each
session as repository scoped:

- attach or link the hub epic and upstream contract issues;
- include the exact dependency revisions or released contract versions;
- ask for a plan before code on high-risk changes;
- use one repository-owned issue per session;
- require normal pull-request review, CI, and branch protection;
- do not merge downstream consumers before compatible producers are available.

For a cross-repository wave, coordinate several repository-scoped sessions
through the hub epic rather than asking one session to make an atomic change
across every repository.

## Scenario 4: Capability extraction and GitHub Spec Kit

### Goal

Turn observed legacy behavior into reviewable specifications so future
modernization is driven by business capabilities and compatibility contracts,
not only by technology replacement.

### Important limitation

Spec Kit does not initialize an existing repository and automatically infer a
complete specification of current behavior. Official existing-project guidance
recommends initializing in place, recording real guardrails, and applying the
workflow to the next bounded change.

Use a separate evidence-driven discovery pass to abstract current behavior
before treating it as a specification.

### Step 1: Build a capability inventory

Start with `docs\templates\capability-specification.md`. For each capability:

1. identify users, triggers, outcomes, and business rules;
2. trace UI, service, data, batch, and document implementations;
3. record input/output contracts and failure behavior;
4. cite repository, file, symbol, and test evidence;
5. distinguish observed behavior from inferred intent;
6. record unknowns that require a domain-owner decision;
7. define measurable characterization tests.

Suggested capability slices:

- find a customer and view their accounts;
- view transactions for a date range;
- request and retrieve a statement;
- calculate statement opening and closing balances;
- import transactions from CSV;
- reject malformed imports;
- detect duplicate external transaction IDs;
- generate and retain a PDF statement.

Do not create one giant specification for the whole system. A capability should
be reviewable by a business owner and traceable across repositories.

### Step 2: Create an application constitution

Agree on system-wide principles before repository plans, for example:

- preserve externally observable financial behavior;
- never change monetary precision or sign conventions implicitly;
- version changed contracts and support coexistence during migration;
- require idempotency for imports and document jobs;
- cite evidence for current-state claims;
- require rollback for database and contract changes;
- retire WCF or file contracts only after every consumer migrates;
- keep synthetic data and avoid secrets.

The hub can hold the application constitution. Each repository can extend it
with local build, test, framework, and ownership rules.

### Step 3: Initialize Spec Kit in a reviewable branch

Follow the current official installation and integration guidance. For an
existing repository, the documented shape is:

```text
specify init --here --force --integration <key>
```

Run it only after committing or stashing work and creating a reviewable branch.
The `--force` option permits initialization in a non-empty directory and can
replace conflicting managed files, so review the generated diff.

Initialize the hub for application-level architecture decisions or initialize
an individual component repository for a bounded implementation. Do not assume
one Spec Kit feature directory can commit changes to six repositories.

### Step 4: Run the bounded Spec Kit workflow

For an approved capability or modernization slice:

1. `/speckit.constitution` records real, agreed guardrails.
2. `/speckit.specify` defines the desired behavior and compatibility boundary.
3. `/speckit.clarify` resolves ambiguous business and migration decisions.
4. `/speckit.plan` maps the change onto the current architecture.
5. `/speckit.tasks` creates dependency-ordered implementation tasks.
6. `/speckit.analyze` checks consistency across the artifacts.
7. `/speckit.implement` performs the repository-scoped change.
8. `/speckit.converge` identifies remaining gaps between specification and
   implementation.

Example bounded specification request:

> Replace the account lookup consumer path with a versioned REST API while
> preserving customer ownership rules, monetary values, transaction ordering,
> current WCF behavior, and the WinForms user experience. WCF must remain
> available until the portal, statement service, and batch importer have moved
> to the new contract.

### Step 5: Connect specs to the cross-repository backlog

Use this traceability chain:

```text
Capability specification
  -> application decision
  -> repository work package
  -> GitHub issue
  -> Spec Kit feature directory
  -> pull request
  -> parity evidence
```

The hub epic links all repository issues. Each repository issue links its Spec
Kit artifacts and pull request. The final application-level validation links
evidence from every repository before a legacy contract is retired.

## Governance checklist

- [ ] Every source repository and revision is recorded.
- [ ] Private-repository permissions are consistent for participants.
- [ ] Current-state claims cite code or runtime evidence.
- [ ] Business intent is not inferred from code without review.
- [ ] Contract owners and consumers are identified.
- [ ] Work packages have one owning repository.
- [ ] Cross-repository dependencies use stable issue links.
- [ ] Modernization waves include coexistence and rollback.
- [ ] Agent sessions cannot merge their own work.
- [ ] End-to-end parity is tested before retirement.

## Official references

- [VS Code multi-root workspaces](https://code.visualstudio.com/docs/editing/workspaces/multi-root-workspaces)
- [Add context to VS Code Chat](https://code.visualstudio.com/docs/chat/copilot-chat-context)
- [GitHub Copilot Spaces](https://docs.github.com/en/copilot/concepts/context/spaces)
- [GitHub Copilot cloud agent](https://docs.github.com/en/copilot/concepts/agents/cloud-agent/about-cloud-agent)
- [GitHub Copilot app modernization](https://learn.microsoft.com/en-us/azure/developer/github-copilot-app-modernization/)
- [GitHub Copilot modernization agent](https://learn.microsoft.com/en-us/azure/developer/github-copilot-app-modernization/modernization-agent/overview)
- [Modernize CLI quickstart](https://learn.microsoft.com/en-us/azure/developer/github-copilot-app-modernization/modernization-agent/quickstart)
- [Modernize CLI commands](https://learn.microsoft.com/en-us/azure/developer/github-copilot-app-modernization/modernization-agent/cli-commands)
- [Modernize CLI batch assessment](https://learn.microsoft.com/en-us/azure/developer/github-copilot-app-modernization/modernization-agent/batch-assess)
- [GitHub Spec Kit](https://github.github.io/spec-kit/)
- [Adopting Spec Kit in an existing project](https://github.github.io/spec-kit/guides/existing-projects.html)

Recheck these references before a workshop because product names, availability,
policies, commands, and preview limitations can change.
