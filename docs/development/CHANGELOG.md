## 2026-08-21 — Safe-track non-AI completion (single-tenant)

Chose **SAFE TRACK**: finish CRUD UIs and RBAC chrome on the existing single-organization backend. Multi-company / Company model deferred.

### Backend (non-breaking)
- Added `PATCH /api/v1/auth/me` for self-service `name` + `phone` only (no role/status changes).
- Swagger + route inventory updated.

### Flutter
- Executive Alabaster (light) + Bespoke Obsidian (dark) themes with shared tokens; theme toggle on profile/mobile shell.
- Role capabilities map `MD|ADMIN|MANAGER|EMPLOYEE` → nav/actions (MANAGER labeled Department Head in UI).
- Profile screen persists via `PATCH /auth/me`.
- Users admin (MD/ADMIN): list/search/create/activate/deactivate via `/api/v1/users`.
- Projects: create + status change via live APIs; UI labels for project types without renaming enums.
- Meetings: schedule + status change via live APIs.
- Sales: create lead via `POST /api/v1/leads`; conversion note clarified (Customer + Opportunity, not Project).
- Dashboard: business status chip + executive section labels; removed fake company name.
- GoRouter redirects employees away from finance/users/sales when capability missing.

### Explicitly not done
- Company tenant / companyId isolation
- SUPER_ADMIN / permission catalog modules
- Invoice collections, vendors, land, MD notes
- AI / WhatsApp

---

## 2026-08-21 — Final non-AI foundation audit

Audit-only except safe honesty/docs fixes. No schema, seed, JWT, CORS, or database changes.

- Documented remaining gaps: no Invoice/Vendor/Land/MD Note models; Task has no stored `BLOCKED` status (overdue is computed); Project types stay `RESIDENTIAL|COMMERCIAL|INFRASTRUCTURE|LAND_DEVELOPMENT|INTERNAL|OTHER`.
- Documented data-integrity gap: demo `Project.actualExpense` is populated while the finance ledger is empty, so assistant finance answers can disagree with the project screen.
- Collections UI no longer presents zero-invoice customers as amounts due today.
- Finance screen labels net (income − expense) instead of “available balance”.
- README / `.env.example` no longer say remaining screens default to mocks.

**Not executed (needs approval or is tomorrow’s work):** production JWT-default refusal, CORS changes, finance/invoice seed, Vendor/Land/Invoice/MD Note modules, adding `BLOCKED` to the task enum.

---

## 2026-08-21 — Architecture audit: relationships + live module wiring

### Backend (MD_EAO_BACKEND; Route → Service → Repository kept)
- Added optional `Project.customerId` (ref Customer) so Customer ↔ Project is a direct ID, not only via Opportunity.
- Added `Task.projectId` mongoose `ref: "Project"`, plus optional `Task.customerId` and `Task.meetingId`.
- Added optional `Meeting.customerId`.
- Hydrated compact `customer` / `project` summaries on list/detail. Create/update validate referenced IDs. Tasks and meetings inherit `customerId` from the linked project when omitted.
- Opportunity create/update copies `customerId` onto `Project.customerId` when that project has none.
- Assistant `PENDING_TASKS` / `OVERDUE_TASKS` honor `entities.projectId`. `PROJECT_TASKS` can filter pending/overdue.
- Demo seed: converted lead `LEAD-SEED-004` now stores `convertedCustomerId` / `convertedOpportunityId`; projects get `customerId` from opportunities; tasks inherit that customer; two meetings link CHN-RES / BLR-COM (one meeting linked to `TASK-SEED-002`).
- Swagger Project/Task/Meeting schemas and list query params updated. Enums unchanged. No Vendor/Land/Invoice/MD Note modules added.

### Flutter
- Remaining screens now use live APIs the same way as projects: meetings, sales, CRM, finance, collections, notifications, reports, assistant.
- Endpoints aligned to Swagger: `/api/v1/leads`, `/api/v1/customers`, `/api/v1/sales/follow-ups`, `/api/v1/dashboard/weekly-financial-requirement`, `/api/v1/dashboard/morning-report`. Invented `/collections`, `/md-notes`, `/reports/daily` paths removed.
- Collections maps customers + `Project.customerId` + finance income. It does not invent invoices.
- `ProjectSummary` / `Task` read hydrated `customer.name`. Meeting JSON uses `startTime` / `endTime` / `participants`.

---

## 2026-08-20 — Projects API integration

### Change
Projects screen now loads from live Swagger `GET /api/v1/projects` (Bearer JWT). No new backend APIs.

Mapped fields from `Project`: `id`, `projectId`, `name`, `code`, `description`, `location`, `projectType`, `status`, `progress` (0–100), `budget`, `actualExpense`, `expectedEndDate`, hydrated `manager.name`.

Risk is derived (`AT_RISK` or overspent → high). Customer/contract fields are omitted when the list payload does not include them.

---

## 2026-08-20 — Auth API integration

### Change
Connected the Flutter frontend to the running Node.js backend auth APIs. Source of truth: Swagger at `http://localhost:5050/api-docs` (`http://localhost:5050/api-docs.json`).

Backend base URL: `http://localhost:5050` via `AppConfig.apiBaseUrl` / `--dart-define=API_BASE_URL=...`.

### Actual endpoints used
- `POST /api/v1/auth/register` — body: `name`, `email`, `phone`, `password`
- `POST /api/v1/auth/login` — body: `email`, `password`
- `POST /api/v1/auth/refresh` — body: `refreshToken` (Dio interceptor, access token ~15 minutes)
- `GET /api/v1/auth/me` — Bearer JWT; restores session
- `POST /api/v1/auth/logout` — Bearer JWT; optional `{ refreshToken }`

Token mechanism: `data.accessToken` (JWT) + `data.refreshToken`. Header: `Authorization: Bearer <accessToken>` (`BearerAuth` in Swagger).

Envelope: `{ success, message, data }`. User object fields taken from live responses: `id`, `name`, `email`, `phone`, `role`, `status`, `isActive`, `lastLoginAt`, `createdAt`, `updatedAt`.

### Implementation
- `ApiAuthRepository` is bound in production (no mock login, no hardcoded credentials)
- `AuthNotifier` / `authProvider` states: initial, loading, authenticated, unauthenticated, error
- Secure storage: `flutter_secure_storage` for access + refresh tokens only
- GoRouter redirects from `authProvider`; `/register` is a public auth route
- Logout calls the backend then always clears local tokens
- Friendly mapping for 400/401/403/404/409/422/429/500, timeout, and connection errors
- Other features remain mock-bound via `USE_MOCK_REPOSITORIES` (default true)

### Environment
- Default `API_BASE_URL=http://localhost:5050`
- Android emulator: `http://10.0.2.2:5050`
- Physical device: machine LAN IP
- `.env` is gitignored; `.env.example` documents dart-defines only

### Assumptions
- Register also returns `AuthTokens` and is treated as a signed-in session (confirmed live)
- Confirm-password is UI-only and is not sent to the API
- `role` is not sent on register (Swagger: public register always creates `EMPLOYEE`)

---

## 2026-08-19 — Day 2: Executive Dashboard

### Dashboard implementation
Refined the existing dashboard into the MD morning command center (no architecture rewrite).

UI hierarchy:
Header → Critical Actions → Business Overview → Projects → Today's Tasks → Today's Meetings → Financial / Collection Summary

### Models created/updated
- `CriticalAction` (+ priority)
- `TaskSummary` / `TaskOverview`
- `MeetingSummary` / `MeetingOverview`
- `DashboardSalesSummary`
- `DashboardCollectionSummary`
- `DashboardFinanceSummary`
- `DashboardProjectSummary` / `ProjectOverview`
- `DashboardSummary` composed of the above (legacy flat JSON still supported)

### Repository
- `MockDashboardRepository` updated with Day-2 realistic construction/real-estate numbers
- Supports `forceEmpty` / `forceError` for tests
- `ApiDashboardRepository` unchanged (still `GET /api/v1/dashboard`)
- UI remains bound only to `DashboardRepository` abstraction

### Riverpod
- Existing `dashboardProvider` / `DashboardNotifier` retained
- Loading / success / error / empty handled in `DashboardScreen`

### Mock data approach
Business numbers live only in `MockDashboardRepository` (not widgets):
- Tasks 18 / overdue 3
- Meetings today 5
- Sales pipeline ₹8.4 Cr
- Collections pending ₹42 L
- Weekly requirement ₹50 L / available ₹1.10 Cr
- Projects active 5 / at risk 1

### API boundary
Unchanged: `GET /api/v1/dashboard` via configurable `AppConfig.apiBaseUrl`.

### Testing
Expanded repository, provider (success + error), and widget tests for counts, pipeline, collections, project risk, critical actions, and retry.

### Architecture changes
None. Stack remains Screen → Riverpod → Repository → Dio → future Node.js API.

---

## 2026-08-19 — SAT demo executive foundation

### Change
Backend confirmed as an independent repository (`MD_EAO_BACKEND`). Flutter repository remains frontend-only.

### Decision
Flutter communicates only through REST. No backend code, no git submodules, no MongoDB access from Flutter.

### Impact
- Documented two-repo model in `ARCHITECTURE.md` and `MD_EAO_PROJECT_DOCUMENTATION.md`
- Added `AppConfig` (`API_BASE_URL`, `USE_MOCK_REPOSITORIES`) via `--dart-define`
- Added `.env.example` (documentation only; no dotenv package)
- Added `ApiDashboardRepository`, `ApiTaskRepository`, `ApiAssistantRepository`
- Providers switch mock/API using `AppConfig.useMockRepositories` (default mock for SAT)

### Feature / model upgrades
- Executive Dashboard rebuilt as control center (tasks/meetings/sales/collections/finance/projects + critical actions)
- Assistant returns structured intent/summary/items/actions (mock + API-ready)
- Tasks expanded: critical priority, overdue status, project/customer/vendor, search
- Projects: Chennai Villa, Coimbatore Interior, OMR Commercial (+ related demo projects)
- Sales pipeline leads + metrics
- Collections feature added (summary + list screen + navigation)
- Finance: available balance, expected collections, planned payments
- Shared `SatDemoSeed` for relational mock tasks/meetings
- Daily report mock expanded to 11-point executive brief

### Packages added
None (still `flutter_riverpod`, `go_router`, `dio` only).

### Architecture changes
None to the frozen stack. Clarified backend independence and mock/API provider binding.

---

## 2026-08-18 — Flutter frontend foundation

### Packages added

- `flutter_riverpod` `3.4.2` — frozen state-management layer
- `go_router` `17.5.0` — routing
- `dio` `5.11.0` — HTTP client behind `ApiClient`
- Flutter create defaults kept: `cupertino_icons`, `flutter_lints`

No other application packages were added (no Bloc, GetX, `shared_preferences`, `intl`, `riverpod_generator`, or LLM SDKs).

### Folders created

- `lib/app/`
- `lib/core/constants/`
- `lib/core/network/`
- `lib/core/storage/`
- `lib/core/errors/`
- `lib/core/utils/`
- `lib/core/providers/`
- `lib/shared/widgets/`
- `lib/features/{auth,dashboard,assistant,tasks,meetings,projects,sales,crm,finance,notifications,reports}/` each with `models/`, `providers/`, `repositories/`, `presentation/`
- `docs/development/`
- `test/models/`, `test/core/`, `test/providers/`, `test/widgets/`

### Major implementation decisions

- **Mock repositories are the current data source.** Each feature exposes an abstract repository and a `Mock*Repository`. Riverpod `*RepositoryProvider`s bind the mock. UI and notifiers depend only on the abstraction so Node.js API repositories can replace mocks without changing screens.
- **`ApiClient` is prepared but unused by features.** Dio is confined to `lib/core/network/api_client.dart`. Feature code does not call HTTP today.
- **API path constants only.** `ApiEndpoints` documents the future Express contract. No Node.js was implemented.
- **In-memory token storage.** Avoided extra persistence packages. Documented as a reversible provider binding.
- **Login is a UI shell with a mock session.** Non-empty credentials call `MockAuthRepository.login` so the Screen → Riverpod → Repository path is preserved. No credential verification against a server.
- **Sales and CRM are placeholders.** Folder contract and initial/coming-later screens exist; full modules were not built.
- **Read-only screens use `FutureProvider`; mutating screens use `Notifier` / `AsyncNotifier`.** Still Riverpod-only. Recorded so the mix is not mistaken for an architecture change.
- **Task create/detail use the root navigator** so they are full-screen routes above `AppShell`.
- **No `intl`.** Date and INR formatting live in `lib/core/utils/` to keep dependencies minimal.

### Architecture changes

None. The frozen stack remains:

`Flutter UI → Riverpod Provider/Notifier → Repository → Dio API Client → Future Node.js + Express API`

The only temporary deviation from the *future* runtime path is that repositories currently return mock data instead of calling `ApiClient`. That is an increment scope decision, not a stack change, and is documented in `ARCHITECTURE.md`.

### Environment note (not an architecture change)

Flutter was not on `PATH` on this machine. The stable SDK was cloned to `~/development/flutter` so `flutter analyze` and `flutter test` could run. The application does not depend on that install location.
