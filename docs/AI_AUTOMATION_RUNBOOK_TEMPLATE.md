# AI Automation Runbook Starter

> Documentation only. Do **not** connect an LLM, WhatsApp, or agentic automation until the non-AI product is stable.

Use this template for each future workflow.

---

## Workflow card

```
Workflow name:
Owner:
Trigger:
Required inputs:
AI task:
Safe-to-proceed rule:
Stop reasons:
Human review gates:
External side effects:
Retry-safe steps:
Do-not-retry steps:
Run log location:
How to pause or disable the workflow:
After-launch review date:
```

---

## Field guidance

| Field | Intent |
| --- | --- |
| Workflow name | Short unique name, e.g. `md-morning-brief` |
| Owner | Human accountable for the automation |
| Trigger | Schedule, webhook, user action, or event |
| Required inputs | Structured fields the AI must receive (IDs, dates, role) |
| AI task | Natural-language goal; must map to existing domain services |
| Safe-to-proceed rule | Preconditions that must be true before side effects |
| Stop reasons | Hard stops (auth failure, missing company scope, ambiguous entity) |
| Human review gates | Steps that require MD/admin confirmation |
| External side effects | WhatsApp, email, payments — none until approved |
| Retry-safe steps | Idempotent reads / status checks |
| Do-not-retry steps | Creates that would duplicate (task create, lead create) |
| Run log location | Where structured logs are stored |
| Pause / disable | Feature flag or config key |
| After-launch review date | First retrospective |

---

## Architecture rule for tomorrow

```
MD
 ↓
AI Assistant (intent + entities)
 ↓
Existing business services (Task, Project, CRM, Finance, Meeting, Dashboard)
 ↓
MongoDB
 ↓
Structured response
 ↓
AI natural-language wrapper
```

AI must **not** write MongoDB directly.  
AI must **not** bypass validation or RBAC.  
AI must reuse the same APIs Flutter uses.

---

## Example (not implemented)

```
Workflow name: overdue-task-digest
Owner: MD Office
Trigger: Daily 08:00 Asia/Kolkata
Required inputs: actorUserId, timezone
AI task: Summarize overdue tasks for the signed-in MD/MANAGER scope
Safe-to-proceed rule: JWT valid; role in MD|ADMIN|MANAGER
Stop reasons: 401/403; empty actor; finance intent without privilege
Human review gates: None for read-only digest
External side effects: None
Retry-safe steps: GET /api/v1/tasks?overdue=true
Do-not-retry steps: N/A
Run log location: AssistantQuery collection
How to pause or disable the workflow: DISABLE_OVERDUE_DIGEST=true
After-launch review date: TBD
```
