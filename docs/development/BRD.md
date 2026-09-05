# MD EAO — Business Requirements (Frontend)

**Updated:** 19 August 2026  
**Repository:** `MD_EAO` (Flutter only)

## Objective

Deliver a SAT-ready Flutter executive assistant frontend that proves MD → Flutter → Riverpod → Repository → Dio → API → response → UI, using mock repositories until `MD_EAO_BACKEND` is available.

## Scope

In scope: dashboard, assistant, tasks, meetings, projects, finance, collections, sales/CRM foundation, notifications, reports, API client/constants, docs, tests.

Out of scope: Node.js, MongoDB, WhatsApp/Maytapi, LLM inside Flutter.

## Architecture

Frozen: Flutter → Riverpod → Repository → Dio → REST → separate Node backend → MongoDB.

## Acceptance criteria

- [x] Executive dashboard feels like a control center
- [x] Assistant supports structured responses
- [x] Tasks support list/detail/create/status/search/filter
- [x] Mock data is repository-based, not widget-hardcoded
- [x] Backend remains a separate repository
- [x] Configurable API base URL
- [x] `flutter analyze` / `flutter test` pass
