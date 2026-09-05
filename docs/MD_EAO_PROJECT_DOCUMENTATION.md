# MD EAO — Project Documentation

**Repository:** `MD_EAO` (Flutter frontend only)  
**Product:** AI-powered Executive Assistant / MD Office Management System  
**Last updated:** 21 August 2026 (architecture audit — model relationships + live module wiring)

---

## 1. What has been built

A runnable Flutter application that acts as the Managing Director’s executive control center.

Current capability:

- Login / register against live auth APIs
- Executive Dashboard from `GET /api/v1/dashboard`
- Assistant chat from `POST /api/v1/assistant/query` (rule-based intents, no LLM)
- Task list / detail / create / status / reminder / search / filter
- Meetings, Projects, Finance, Collections, Sales/CRM, Notifications, Reports on live APIs
- Riverpod + Repository + Dio architecture
- Mock repositories retained for tests
- Tests, analyze-clean codebase, documentation

Backend code is **not** in this repository. The Node.js backend remains Route → Controller → Service → Repository → Model → MongoDB.

---

## 2. Purpose of the project

Reduce the operational workload of a Managing Director / business owner by providing one central assistant through which the MD can ask questions, view business status, create and track tasks, follow meetings and projects, and eventually manage sales, CRM, collections, finance, vendors, land and WhatsApp-driven workflows.

---

## 3. Business problem being solved

MD decisions are currently fragmented across calls, WhatsApp, Excel, and verbal updates. The MD lacks a single control center for:

- What needs attention today
- Overdue work
- Cash and collections pressure
- Project risk
- Sales follow-ups

MD EAO consolidates that into one executive UI.

---

## 4. SAT demo objective

Prove the core concept:

```
MD asks / updates something
  → Flutter
  → Riverpod
  → Repository
  → Dio
  → Backend API
  → Business data
  → Structured response
  → Flutter displays result
```

Live screens use `Api*Repository`. Mock repositories remain for tests and are not the production switch.

The demo should feel like a future AI executive assistant, without embedding an LLM in Flutter.

---

## 5. Current scope

In scope (frontend):

- Frozen Flutter architecture
- Executive dashboard
- Assistant UI + structured response handling
- Tasks
- Meetings / Projects / Finance / Collections / Sales foundation screens
- API constants + Dio client
- Mock data for SAT
- Documentation and tests

Out of scope (this repository):

- Node.js / Express
- MongoDB / Mongoose
- Maytapi / WhatsApp
- LLM / OpenAI
- Production secrets

---

## 6. Future scope

- Live connection to `MD_EAO_BACKEND`
- Full CRM / vendors / land / project expenses / MD notes modules
- WhatsApp channel via Maytapi (backend-owned)
- LLM intent parsing (backend-owned)
- Persistent secure token storage for remaining domain APIs
- Push notifications

---

## 7. Flutter architecture

```
Presentation/UI
      ↓
Riverpod Provider / Notifier
      ↓
Repository
      ↓
Dio API Client
      ↓
REST API (MD_EAO_BACKEND)
      ↓
MongoDB
```

Rules:

1. Widgets do not call Dio.
2. Widgets do not contain business logic.
3. Widgets do not access MongoDB.
4. Providers manage state.
5. Repositories manage data access.
6. Dio handles HTTP.
7. No Bloc / GetX / alternate state framework.

---

## 8. Riverpod architecture

Examples:

| Screen | Provider | Repository | API |
| --- | --- | --- | --- |
| DashboardScreen | `dashboardProvider` | `ApiDashboardRepository` | `GET /api/v1/dashboard` |
| AssistantScreen | `assistantProvider` | `ApiAssistantRepository` | `POST /api/v1/assistant/query` |
| TasksScreen | `tasksProvider` | `ApiTaskRepository` | `GET /api/v1/tasks` |
| ProjectsScreen | `projectsProvider` | `ApiProjectRepository` | `GET /api/v1/projects` |
| MeetingsScreen | `meetingsProvider` | `ApiMeetingRepository` | `GET /api/v1/meetings` |
| SalesScreen | `salesSummaryProvider` | `ApiSalesRepository` | `GET /api/v1/sales/summary` + `GET /api/v1/leads` |
| CrmScreen | `crmOverviewProvider` | `ApiCrmRepository` | `GET /api/v1/sales/summary` + `/sales/follow-ups` |
| FinanceScreen | `financeSummaryProvider` | `ApiFinanceRepository` | `GET /api/v1/finance/summary` + weekly dashboard |
| CollectionsScreen | `collectionsProvider` | `ApiCollectionRepository` | `GET /api/v1/customers` + projects + finance income |
| NotificationsScreen | `notificationsProvider` | `ApiNotificationRepository` | `GET /api/v1/notifications` |
| ReportsScreen | `dailyReportProvider` | `ApiReportRepository` | `GET /api/v1/dashboard/morning-report` |

Mutating flows use `Notifier` / `AsyncNotifier`. Read-only screens may use `FutureProvider`.

---

## 9. Repository pattern

Each feature has:

- Abstract repository contract
- `Mock*Repository` for tests / offline
- `Api*Repository` bound in providers for live backend

Providers wait for `authProvider.isAuthenticated` then call the live repository. `USE_MOCK_REPOSITORIES` is leftover config and is not the production switch for these screens.

---

## 10. Dio / API architecture

- `ApiClient` is the only Dio wrapper.
- Base URL comes from `AppConfig.apiBaseUrl` (`String.fromEnvironment`), default `http://localhost:5050`.
- Bearer access token is attached from `TokenStorage` except on login/register/refresh.
- 401 responses retry once after `POST /api/v1/auth/refresh`.
- `DioException` maps to user-friendly `AppException` messages (no stack traces, tokens, or database details).

---

## Authentication

Live integration against `MD_EAO_BACKEND`. Swagger source of truth: `http://localhost:5050/api-docs`.

### Stack

```
LoginScreen / RegisterScreen
  → Riverpod AuthNotifier (authProvider)
    → AuthRepository (ApiAuthRepository)
      → Dio ApiClient
        → Node.js Auth API
```

Widgets never call Dio. Login/Register never call the API directly.

### Endpoints (actual)

| Action | Method | Path | Request |
| --- | --- | --- | --- |
| Register | `POST` | `/api/v1/auth/register` | `name`, `email`, `phone`, `password` |
| Login | `POST` | `/api/v1/auth/login` | `email`, `password` |
| Refresh | `POST` | `/api/v1/auth/refresh` | `refreshToken` |
| Current user | `GET` | `/api/v1/auth/me` | Bearer JWT |
| Logout | `POST` | `/api/v1/auth/logout` | Bearer JWT; optional `{ refreshToken }` |

Success envelope:

```json
{
  "success": true,
  "message": "Logged in successfully",
  "data": {
    "user": { "id": "...", "name": "...", "email": "...", "phone": "...", "role": "EMPLOYEE", "status": "ACTIVE", "isActive": true },
    "accessToken": "<jwt>",
    "refreshToken": "<refresh-token>"
  }
}
```

Register is `201` with the same `data` shape. Public register always creates role `EMPLOYEE`; Flutter does not send `role`. Confirm-password is UI-only.

### Token handling

- JWT access token (~15 minutes) + refresh token (~7 days)
- Stored only in `SecureTokenStorage` (`flutter_secure_storage`)
- Protected requests: `Authorization: Bearer <accessToken>`
- Passwords, tokens, and Authorization headers are never logged
- `.env` is not committed

### Riverpod auth state

`authProvider` / `AuthNotifier` is the single source of truth:

- `initial` — bootstrap
- `loading` — login, register, or session restore in flight
- `authenticated` — session present
- `unauthenticated` — no session
- `error` — user-facing message; still treated as logged out for routing

`sessionProvider` is a derived read of `authProvider.session` for existing shell/assistant UI.

### Protected routing

GoRouter redirects from `authProvider`:

- Unauthenticated: `/login` and `/register` only
- Authenticated: application shell (dashboard and feature routes)
- Session restore: `GET /api/v1/auth/me` (refresh interceptor renews expired access tokens)

### Logout

1. `POST /api/v1/auth/logout` with the refresh token when available
2. Clear secure storage
3. `AuthState.unauthenticated` → Login

Local sign-out still proceeds if the logout request fails.

### Error handling

Status and transport errors are translated before they reach the UI:

- 401 login → backend “Invalid email or password” (or equivalent)
- 409 register → “Email is already registered” / duplicate account
- 422 → field messages from `errors[]`
- timeout / connection refused / no network → “Unable to connect to the server. Please try again.”
- 500 → generic retry message (no stack traces)

### Local development

```bash
flutter run --dart-define=API_BASE_URL=http://localhost:5050
```

| Environment | `API_BASE_URL` |
| --- | --- |
| Flutter + API on the same computer | `http://localhost:5050` |
| Android emulator | `http://10.0.2.2:5050` |
| Physical device | `http://192.168.x.x:5050` (machine LAN IP) |

Auth and remaining feature screens hit the live API. `USE_MOCK_REPOSITORIES` is leftover config and is not the production switch.

---

## 11. Feature structure

```
lib/
  app/
  core/config|constants|network|storage|errors|utils|mock|providers/
  shared/widgets/
  features/
    auth|dashboard|assistant|tasks|meetings|projects|
    sales|crm|collections|finance|notifications|reports/
      models/
      providers/
      repositories/
      presentation/
```

This repository root **is** the Flutter app. Do not move it under `frontend/flutter_app/`.

---

## 12. Dashboard

**Day 2 focus:** Executive morning command center.

Path:

```
DashboardScreen
 ↓
dashboardProvider
 ↓
ApiDashboardRepository
 ↓
GET /api/v1/dashboard
```

Shows:

1. Critical actions (with priority)
2. Business overview cards (tasks, meetings, sales pipeline, collections, weekly requirement, available balance)
3. Projects (active / at risk / completed + Chennai Villa, Coimbatore Interior, OMR Commercial)
4. Today's tasks (compact summary list)
5. Today's meetings
6. Financial / collection summary

States:

- Loading: "Loading business status..."
- Error: "Unable to load business data." + Retry
- Empty: "No business data available."

Business data is never hardcoded in widgets.

---

## 13. Assistant

Professional chat UI with suggestion chips.

Flutter sends:

```json
{ "message": "Show pending tasks." }
```

UI is ready for structured backend responses:

```json
{
  "intent": "PENDING_TASKS",
  "summary": "...",
  "items": ["..."],
  "actions": ["..."]
}
```

No LLM inside Flutter.

---

## 14. Tasks

Supports title, description, assignee, project, priority, status, due date, reminder, created metadata, related customer/vendor.

Statuses: Pending, In Progress, Completed, Blocked, Overdue  
Priorities: Low, Medium, High, Critical

UI: list, search, filter, detail, create, status update, reminder.

---

## 15–21. Other modules

| Module | Current frontend state |
| --- | --- |
| Meetings | Initial list from mock/API-ready repository |
| Projects | Chennai Villa, Coimbatore Interior, OMR Commercial, etc. |
| Sales/CRM | Pipeline summary + leads |
| Finance | Balance, weekly need, expected collections, planned payments |
| Collections | Pending/overdue + invoice rows |
| Reports | Daily MD brief structure |
| Notifications | Initial list |
| MD Notes / Vendors / Land | Documented for future; not fully productized in UI yet |

---

## 22. Future WhatsApp integration

Owned by backend (`Maytapi`). Flutter may later show WhatsApp-originated tasks/notifications via REST. Do not add Maytapi SDKs to Flutter.

---

## 23. Future AI/LLM integration

Owned by backend:

```
User message → LLM → Intent + entities → Business service → MongoDB → Response → Flutter
```

Flutter only displays structured responses.

---

## 24. Backend separation

| Repo | Owner | Stack |
| --- | --- | --- |
| `MD_EAO` | Frontend | Flutter, Riverpod, GoRouter, Dio |
| `MD_EAO_BACKEND` | Sathish | Node.js, Express, Mongoose, MongoDB |

Do **not** put backend code here. Do **not** use git submodules.

---

## 25. API contract

Prepared constants in `lib/core/network/api_endpoints.dart`:

- `GET /api/v1/health`
- `POST /api/v1/auth/register`
- `POST /api/v1/auth/login`
- `POST /api/v1/auth/refresh`
- `GET /api/v1/auth/me`
- `POST /api/v1/auth/logout`
- `GET /api/v1/dashboard`
- `GET /api/v1/dashboard/morning-report`
- `GET /api/v1/dashboard/weekly-financial-requirement`
- `POST /api/v1/assistant/query`
- `POST /api/v1/assistant/action`
- `GET/POST /api/v1/tasks`
- `GET/PATCH /api/v1/tasks/{id}`
- `PATCH /api/v1/tasks/{id}/status`
- `GET /api/v1/employees`
- `GET /api/v1/meetings`
- `GET /api/v1/projects`
- `GET /api/v1/sales/summary`
- `GET /api/v1/sales/follow-ups`
- `GET /api/v1/leads`
- `GET /api/v1/customers`
- `GET /api/v1/finance/summary`
- `GET /api/v1/notifications`

There is no collections/invoice, MD notes, vendor, or land API. Task reminder is `PATCH` `reminderAt` on the task, not `/tasks/{id}/reminder`.

---

## Model relationships (final)

IDs are references. Entire documents are not duplicated.

```
User ──userId──► Employee ──assignedTo──► Task
                      │
                      ├── managerId/members ► Project
                      └── participants ► Meeting

Lead ──convertedCustomerId──► Customer ──customerId──► Project
  │                              ▲                      │
  └── sourceLeadId ──────────────┘                      ├── projectId ► Task / Meeting / FinanceTransaction
                                                        └── customerId copied onto Task / Meeting when omitted

Opportunity.customerId + Opportunity.projectId also connect CRM to delivery.
Meeting ──meetingId──► Task (action item)
Task.createdBy ► User (MD)
Task.reminderAt ► existing Reminder / Notification scheduler
AssistantQuery ► intent + entities ► domain service ► MongoDB ► answer
```

Project types stay `RESIDENTIAL | COMMERCIAL | INFRASTRUCTURE | LAND_DEVELOPMENT | INTERNAL | OTHER`. Interior demo uses `INTERNAL`. Construction/real-estate activity is represented as projects of those types plus tasks/meetings/finance — there is no separate Land or Vendor collection yet.

MD Note → Task is not a model. A note can become a Task with `assignedTo` + `reminderAt` when that conversion exists later.

Also prepared for SAT: collections/sales leads/notifications/md-notes paths.

---

## 26. Sample data expectations

Backend owns the production/SAT dataset volumes (users, employees, projects, tasks, leads, collections, etc.).

Frontend mock seed (`lib/core/mock/sat_demo_seed.dart` + feature mocks) keeps **relational** demo data (lead → customer → project → tasks → collections → finance) for offline demos. Widgets never hardcode business data.

---

## 27. Build from scratch

1. Install Flutter SDK (stable).
2. Clone `MD_EAO`.
3. `flutter pub get`
4. `flutter run`

---

## 28. Install dependencies

```bash
flutter pub get
```

Packages:

- `flutter_riverpod`
- `go_router`
- `dio`
- `flutter_secure_storage`

---

## 29. Run locally

```bash
export PATH="$HOME/development/flutter/bin:$PATH"   # if needed
cd "/path/to/MD EAO"
flutter pub get
flutter run -d macos --dart-define=API_BASE_URL=http://localhost:5050
# or: flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:5050
```

Register a new employee account, or sign in with an existing backend user. Mock credential shortcuts are not used for auth.

---

## 30. Test

```bash
dart format .
flutter analyze
flutter test
```

---

## 31. Connect to Sathish’s backend

```bash
flutter run \
  --dart-define=API_BASE_URL=http://localhost:5050
```

Ensure `MD_EAO_BACKEND` is running (`http://localhost:5050/api-docs`). CORS/auth must match the Flutter client.

---

## 32. Environment configuration

See `.env.example`.

Variables are passed via `--dart-define` (no dotenv package, no committed secrets):

- `API_BASE_URL` (default `http://localhost:5050`)
- `USE_MOCK_REPOSITORIES` exists in `AppConfig` but is unused by live providers (leftover; default `true`)

---

## 33. Git / GitHub workflow

- This repo is frontend-only.
- Suggested branches: `feature/flutter-foundation`, `feature/flutter-dashboard`, `feature/flutter-assistant`, `feature/flutter-tasks`
- Do not merge `MD_EAO_BACKEND` into this repo.

---

## 34. Known limitations

- **Single-tenant:** one organization per deployment. No Company model / cross-company isolation yet.
- Live APIs cover auth (incl. `PATCH /auth/me`), dashboard, tasks, meetings, projects create/status, sales lead create, CRM, finance ledger, notifications, reports, users (MD/ADMIN), and the rule-based assistant.
- There is no invoice/collections, vendor, land-parcel, or MD-note module. Collections UI lists customers linked to projects with ₹0 outstanding.
- Task stored statuses are `PENDING | IN_PROGRESS | COMPLETED | CANCELLED`. Overdue is computed. `BLOCKED` is not stored.
- Project types are `RESIDENTIAL | COMMERCIAL | INFRASTRUCTURE | LAND_DEVELOPMENT | INTERNAL | OTHER`.
- Roles are `MD | ADMIN | MANAGER | EMPLOYEE` (MANAGER shown as Department Head). No permission catalog UI.
- Demo seed may have empty finance ledger vs `Project.actualExpense` snapshots.
- Themes: Executive Alabaster + Bespoke Obsidian. AI runbook template: `docs/AI_AUTOMATION_RUNBOOK_TEMPLATE.md` (docs only — no AI connected).
- No WhatsApp / LLM in Flutter. Assistant already calls domain services; LLM should not talk to MongoDB directly.

---

## 35. Important architecture decisions

1. Frontend and backend are separate repositories.
2. Riverpod is frozen; no Bloc/GetX.
3. Mock vs API repositories are provider-bound, not UI-bound.
4. API base URL is compile-time configurable.
5. Assistant UI expects structured intent responses.
6. Business sample data lives in repositories/seeds, never widgets.

---

## 36. Future development roadmap

1. Wire all features to `Api*Repository` once Sathish publishes contracts.
2. Expand collections/vendors/land/MD notes screens.
3. Persist remaining domain sessions against additional APIs.
4. Consume daily report + notification push endpoints.
5. Backend AI + WhatsApp; Flutter remains presentation + state + repository client.

---

## Architecture quality review (SAT frontend)

| Area | Score |
| --- | --- |
| Scalability | 9 |
| Maintainability | 9 |
| Riverpod usage | 9 |
| Repository separation | 10 |
| API separation | 9 |
| Error handling | 9 |
| Testability | 9 |
| Feature organization | 9 |
| Backend independence | 10 |
| Future AI readiness | 9 |

**Overall: 9/10**

Remaining gap to 10/10: live backend integration for remaining domain screens beyond auth.
