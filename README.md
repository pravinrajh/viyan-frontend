# AI MD Office (`MD_EAO`)

Flutter frontend for the **AI-powered Executive Assistant / MD Office Management System**.

This repository is **frontend only**. The Node.js backend lives in a separate repository: `MD_EAO_BACKEND` (maintained by Sathish).

## Purpose

Give a Managing Director one executive control center to:

- Ask business questions through an assistant
- See overall business status
- Create, assign and track tasks
- Track meetings, projects, sales/CRM, collections and finance
- Prepare for future WhatsApp + AI/LLM capabilities (backend-owned)

## SAT demo objective

Prove:

```
MD → Flutter → Riverpod → Repository → Dio → REST API → Business data → Flutter UI
```

Every feature screen (dashboard, assistant, tasks, meetings, projects, sales, CRM, finance, budgets, invoices, vendors, land parcels, MD notes, reminders, sales activities, notifications, reports, users, profile) calls the live Node.js API. Role-based nav maps `MD|ADMIN|MANAGER|EMPLOYEE`. Multi-company tenancy is deferred. Mock repositories remain for tests.

## Features (current)

- **Executive Dashboard** — morning command center with critical actions, overview cards, projects, today's tasks/meetings, finance/collections
- Assistant (live `/assistant` API, chat history and actions)
- Tasks (list, search, filter, detail, create, status, reminder)
- Meetings, Projects, Finance, Budgets
- Sales / CRM, Sales activities
- Invoices, Vendors, Land parcels, MD notes, Reminders
- Notifications, Reports
- Login / Register against the live Node.js auth API

## Technology stack

- Flutter
- Riverpod
- GoRouter
- Dio
- flutter_secure_storage

## Architecture

```
Flutter → Riverpod → Repository → Dio → REST API → MD_EAO_BACKEND → MongoDB
```

See:

- [Project documentation](docs/MD_EAO_PROJECT_DOCUMENTATION.md)
- [Architecture](docs/development/ARCHITECTURE.md)
- [Changelog](docs/development/CHANGELOG.md)

## Folder structure

```
lib/app          app shell, theme, router
lib/core         config, network, storage, errors, utils, mock seed
lib/shared       shared widgets
lib/features/*   feature modules (models/providers/repositories/presentation)
test/            unit + widget tests
docs/            product + architecture docs
```

## Installation

```bash
flutter pub get
```

## Run locally

Start the backend first — the app is useless without it. From the `MD_EAO_backend` checkout:

```bash
npm install       # first time only
npm run dev       # serves http://localhost:5050, needs MongoDB on 27017
```

Then run the app:

```bash
export PATH="$HOME/development/flutter/bin:$PATH"   # if Flutter is not on PATH
flutter run -d macos --dart-define=API_BASE_URL=http://localhost:5050
# or
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:5050
```

`API_BASE_URL` already defaults to `http://localhost:5050`, so the flag is only
needed when the backend is somewhere else.

Demo login (after `npm run seed:archnova` in the backend): `md@archnova.com` /
`ArchNovaDemo@2026`.

Register a new account (name, email, 10-digit phone, password) or sign in with an existing backend user.

## Connect to backend

```bash
flutter run \
  --dart-define=API_BASE_URL=http://localhost:5050 \
  --dart-define=USE_MOCK_REPOSITORIES=false
```

Android emulator: `--dart-define=API_BASE_URL=http://10.0.2.2:5050`.  
Physical device: use the development machine LAN IP.

See `.env.example` for variable documentation. Do not commit secrets.

## Testing

```bash
dart format .
flutter analyze
flutter test
```

## Git workflow

Suggested branches:

- `feature/flutter-foundation`
- `feature/flutter-dashboard`
- `feature/flutter-assistant`
- `feature/flutter-tasks`

Do not add backend code to this repository.

## Current status

SAT frontend is ready for review against the live backend. All modules — auth, dashboard, assistant, tasks, meetings, projects, sales, CRM, sales activities, finance, budgets, invoices, vendors, land parcels, MD notes, reminders, notifications, reports and users — run against live APIs.

## Future roadmap

1. Project expenses and deeper finance reporting
2. Multi-company tenancy
3. Backend WhatsApp + LLM (Flutter remains the client)
