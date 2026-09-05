# AI MD Office — Architecture

**Repository:** `MD_EAO` (Flutter frontend only)  
**Updated:** 21 August 2026 (safe-track single-tenant completion)

## Frozen stack

```
Flutter UI
  → Riverpod AuthProvider / feature providers
    → Repository
      → Dio API Client
        → REST API
          → Separate Node.js backend (MD_EAO_BACKEND)
            → MongoDB
```

Authentication specifically:

```
Flutter Login/Register
  → Riverpod AuthNotifier (authProvider)
    → AuthRepository (ApiAuthRepository)
      → Dio ApiClient
        → Node.js Auth API (`/api/v1/auth/*`)
```

**The backend is NOT part of this repository.** It keeps Route → Controller → Service → Repository → Model → MongoDB. Do not replace that stack.

Do not introduce Bloc, GetX, or another state-management framework.  
Do not connect Flutter to MongoDB.  
Do not call Dio from widgets.  
Do not use git submodules to pull in the backend.

## Two-repository model

| Repository | Contents |
| --- | --- |
| `MD_EAO` | Flutter, Riverpod, GoRouter, Dio, UI, frontend models/providers/repositories/tests/docs |
| `MD_EAO_BACKEND` | Node.js, Express, Mongoose, MongoDB, cron, Maytapi later, LLM later |

Communication is REST only. Envelope: `{ success, message, data, meta? }`. IDs are camelCase (`projectId`, `customerId`). Money is whole INR integers.

## Single-tenant (current) vs multi-company (deferred)

**Current:** One organization per deployment. Roles: `MD`, `ADMIN`, `MANAGER` (UI label: Department Head), `EMPLOYEE`. Backend enforces role scopes; Flutter `RoleCapabilities` only controls navigation/chrome.

**Deferred:** Company model, `companyId`, company registration, Super Admin, permission catalogs, cross-company isolation.

## Core business relationships (backend)

References are ObjectIds, not embedded documents.

```
User → Employee (userId)
Employee → Task (assignedTo) / Project (managerId, members)

Lead → Customer (sourceLeadId / convertedCustomerId)
Customer → Opportunity (customerId) → Project (projectId)
Project.customerId → Customer   // direct link; also filled when an opportunity attaches a project

Project → Task (projectId, customerId, meetingId)
Project → Meeting (projectId, customerId)
Project → FinanceTransaction (projectId)  // EXPENSE is project spend; INCOME is receipt
Customer → FinanceTransaction (customerId)
Meeting → Task (meetingId)  // action item after a meeting
Task.createdBy → User (MD/admin creator)
Task.reminderAt → Reminder/Notification (existing scheduler)
```

Assistant (no LLM yet): query → intent → entities (`projectId`, `employeeId`, …) → domain service → structured `{ intent, answer, data }`.

## Flutter application shape

```
lib/
  main.dart
  app/                 # MaterialApp, theme, go_router
  core/
    config/            # AppConfig (API_BASE_URL)
    constants/
    network/           # ApiClient, ApiEndpoints
    storage/
    errors/
    utils/
    mock/              # SAT seed data (not for widgets)
    providers/
  shared/widgets/
  features/<feature>/
    models/
    providers/
    repositories/      # abstract + mock + live Api*Repository
    presentation/
```

## Layer rules

1. Presentation consumes Riverpod and maps loading / data / error / empty via `AsyncBody`.
2. Providers/notifiers orchestrate use cases; they depend on repository abstractions only.
3. Repositories are the data-access boundary.
4. `ApiClient` is the only Dio wrapper; base URL from `AppConfig.apiBaseUrl`.
5. MongoDB, Maytapi, WhatsApp and LLM stay behind Node.js.

## Live API binding

Auth, dashboard, projects (create/status), tasks (CRUD), meetings (create/status), sales (create lead), CRM, finance, collections (honest customer mapping), notifications, reports, users (MD/ADMIN), profile (`PATCH /auth/me`), and assistant all use live `Api*Repository` implementations. Mock repositories remain for tests.

`USE_MOCK_REPOSITORIES` is no longer the production switch for these screens.

## Authentication

Swagger source: `http://localhost:5050/api-docs`.

| Method | Path | Notes |
| --- | --- | --- |
| `POST` | `/api/v1/auth/register` | `name`, `email`, `phone`, `password` → `{ success, message, data: AuthTokens }` |
| `POST` | `/api/v1/auth/login` | `email`, `password` → `AuthTokens` |
| `POST` | `/api/v1/auth/refresh` | `{ refreshToken }` → `AuthTokens` (interceptor) |
| `GET` | `/api/v1/auth/me` | Bearer JWT → `User` |
| `PATCH` | `/api/v1/auth/me` | Self-service `name` / `phone` only |
| `POST` | `/api/v1/auth/logout` | Bearer JWT; optional `{ refreshToken }` |

`AuthTokens`: `user`, `accessToken` (JWT, ~15 minutes), `refreshToken` (~7 days).  
Protected requests send `Authorization: Bearer <accessToken>`.

`AuthNotifier` states: `initial`, `loading`, `authenticated`, `unauthenticated`, `error`.  
GoRouter uses `authProvider` as the only auth source of truth.

## API boundary (selected)

| Flutter | Backend |
| --- | --- |
| Auth `/api/v1/auth/*` | Auth (live) |
| `GET/POST/PATCH /api/v1/users` | User admin (MD/ADMIN) |
| `GET /api/v1/dashboard` | Executive summary |
| `GET /api/v1/dashboard/morning-report` | Reports screen |
| `GET /api/v1/dashboard/weekly-financial-requirement` | Finance weekly need |
| `POST /api/v1/assistant/query` | Rule-based assistant |
| `GET /api/v1/tasks`, `POST`, `PATCH .../status` | Tasks |
| `GET/POST /api/v1/projects`, `PATCH .../status` | Projects |
| `GET/POST /api/v1/meetings`, `PATCH .../status` | Meetings |
| `GET /api/v1/sales/summary`, `GET/POST /api/v1/leads` | Sales + CRM |
| `GET /api/v1/customers` | Collections screen (no invoice API) |
| `GET /api/v1/finance/summary` | Finance totals (`income`, `expense`, `net`) |
| `GET /api/v1/notifications` | Notifications (`title`, `message`, `isRead`) |

There is **no** `/api/v1/collections`, `/api/v1/md-notes`, `/api/v1/reports/daily`, Vendor, Land, or Company API.

Themes: Executive Alabaster (light) + Bespoke Obsidian (dark) via `AppTheme` / `AppTokens`. See also `docs/AI_AUTOMATION_RUNBOOK_TEMPLATE.md` (docs only).

### Mapping honesty (do not invent modules)

| UI concept | Actual source |
| --- | --- |
| Project “contract value” | `budget` (no separate contract field) |
| Project risk | Derived from health / overdue / budget, not a stored enum |
| Task overdue / blocked | Overdue is a filter; stored statuses are `PENDING\|IN_PROGRESS\|COMPLETED\|CANCELLED` |
| Collections outstanding | Customers + `Project.customerId`; no invoice amounts |
| Finance “cash” on the finance screen | Ledger `net` (income − expense), not bank cash |
| Dashboard available balance | `finance.accountBalance` from cash/bank accounts (empty in demo seed) |
| Weekly requirement | Week-dated INCOME/EXPENSE rows, not payables/invoices |
| Land | `projectType: LAND_DEVELOPMENT` only; no parcel model |
| Interior / Real Estate labels | Map to `INTERNAL` / `RESIDENTIAL`; do not rename backend enums |

### Sample data integrity

Demo seed upserts; it does not drop the database. Connected graph exists for CHN-RES / BLR-COM (customer, tasks, meetings, converted lead). CBE-INT has no customer. Seed has **no** finance transactions, accounts, invoices, vendors, or land parcels. `Project.actualExpense` on seeded projects is therefore a snapshot that the finance APIs will not reproduce until ledger rows exist.

### Current limitations (AI-ready core, incomplete domains)

Assistant already calls existing domain services (not Mongoose). Tomorrow’s LLM should sit in front of those same services. Do not let AI write MongoDB directly.

Missing for MD questions about collections, vendors, land parcels, and MD notes: those collections do not exist. Do not invent them in Flutter.

### Security notes (backend repo)

Do not commit production secrets. Backend `env.ts` has development JWT defaults — production must override them. `scripts/cleanup-performance.ts` can drop a database but only with `CONFIRM_PERF_CLEANUP=YES` and a performance DB name; it must not be run against `md_ai_office`.

## State management

- Session: `AuthNotifier` (`authProvider`) + GoRouter redirect
- Dashboard / Tasks: `AsyncNotifier`
- Assistant chat: `Notifier`
- Read-only screens: `FutureProvider` (gated on `authProvider.isAuthenticated`)
- Task filter + search: Riverpod notifiers composed into `visibleTasksProvider`

## Storage

`SecureTokenStorage` (`flutter_secure_storage`) persists `accessToken` and `refreshToken` only. Tests use `InMemoryTokenStorage`. Passwords are never stored.

## Navigation

`ShellRoute` hosts `AppShell`. Task create/detail use root navigator.

## What this repository does not contain

- Node.js / Express routes
- Mongo schemas
- WhatsApp / Maytapi
- LLM client
- Nested backend folders or submodules
- Invoice / Vendor / Land / MD Note modules (not in the backend yet)
