# Workflow Diagrams

## Email Summarization Workflow

```
┌─────────────────────────────────────────────────────────────┐
│                Email Summarization Workflow                 │
└─────────────────────────────────────────────────────────────┘

Input: { thread_id: 1 }
    │
    ▼
┌──────────────────────┐
│ fetch_email_thread   │ ← GET /api/v1/emails/{thread_id}
│ (Backend API Call)   │
└──────────┬───────────┘
           │
           ▼
    ┌──────────────┐
    │  Validate    │
    │  Response    │
    └──┬────────┬──┘
       │        │
   200 │        │ 404/500
       │        │
       ▼        ▼
┌──────────┐  ┌─────────────┐
│ Extract  │  │ Handle Error│
│ Messages │  └─────────────┘
└────┬─────┘
     │
     ▼
┌─────────────────────┐
│ summarize_with_     │ ← POST /api/v1/emails/{thread_id}/summarize
│ openai              │   (Azure OpenAI GPT-4o)
│ - Extract products  │
│ - Get urgency       │
│ - Find address      │
└────┬────────────────┘
     │
     ▼
┌──────────────┐
│ store_summary│
└──────┬───────┘
       │
       ▼
Output: {
  summary: { ... },
  products: [...],
  urgency: "high",
  status: "completed"
}
```

## Quote Generation Workflow

```
┌─────────────────────────────────────────────────────────────┐
│                Quote Generation Workflow                    │
└─────────────────────────────────────────────────────────────┘

Input: { thread_id: 1, discount_rate: 0.05 }
    │
    ▼
┌──────────────────────┐
│ fetch_email_thread   │ ← GET /api/v1/emails/{thread_id}
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│ summarize_email      │ ← Calls: email_summarization_workflow
│ (Sub-workflow)       │   (Reuses entire summarization flow)
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│ extract_products     │ ← Parse products from summary
│ - Product codes      │   ["WIDGET-A", "GADGET-B"]
│ - Quantities         │   [100, 50]
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│ fetch_pricing        │ ← Query PostgreSQL for pricing
│ (Database Query)     │   Based on purchase history
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│ calculate_totals     │ ← Apply tax & discount
│ - Subtotal           │   tax_rate: 0.08
│ - Tax (8%)           │   discount_rate: 0.05
│ - Discount (5%)      │
│ - Total              │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│ generate_quote       │ ← POST /api/v1/quotes/generate
│ (Backend API Call)   │   Create quote record
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│ generate_pdf         │ ← GET /api/v1/quotes/{number}/pdf
│ (PDF Generation)     │   Professional PDF document
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│ notify_completion    │ ← Send notification (email/webhook)
└──────────┬───────────┘
           │
           ▼
Output: {
  quote_number: "Q-20231215-001",
  quote: { ... },
  pdf_url: "/api/v1/quotes/Q-20231215-001/pdf",
  status: "completed"
}
```

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Docker Environment                       │
└─────────────────────────────────────────────────────────────┘

┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│ Conductor UI │    │   Backend    │    │   Frontend   │
│ Port: 5555   │    │  Port: 8000  │    │ Port: 3000   │
└──────┬───────┘    └──────┬───────┘    └──────────────┘
       │                   │
       │ Monitor           │ API Calls
       │ Workflows         │
       │                   │
       ▼                   ▼
┌──────────────────────────────────┐
│     Conductor Server             │
│         Port: 8080               │
│                                  │
│  - Workflow Engine               │
│  - Task Queue                    │
│  - Execution Management          │
└──────┬────────────────┬──────────┘
       │                │
       │ Store          │ Queue
       ▼                ▼
┌──────────────┐  ┌──────────────┐
│Elasticsearch │  │    Redis     │
│ Port: 9200   │  │  Port: 6379  │
│              │  │              │
│ - Indexing   │  │ - Queue      │
│ - Search     │  │ - Cache      │
└──────────────┘  └──────────────┘

       Backend connects to:
              │
              ▼
    ┌──────────────────┐
    │   PostgreSQL     │
    │   Port: 5432     │
    │                  │
    │ - Email data     │
    │ - Products       │
    │ - Pricing        │
    └──────────────────┘
              │
              ▼
    ┌──────────────────┐
    │  Azure OpenAI    │
    │    (External)    │
    │                  │
    │ - GPT-4o         │
    │ - Summarization  │
    └──────────────────┘
```

## Task Retry Logic

```
┌─────────────────────────────────────────────────────────────┐
│                  Task Execution Flow                        │
└─────────────────────────────────────────────────────────────┘

Task Start
    │
    ▼
Execute Task
    │
    ├─────────────────┐
    │                 │
  Success           Failure
    │                 │
    ▼                 ▼
 Continue      ┌──────────────┐
    │          │ Check Retry  │
    │          │ Count        │
    │          └──┬───────┬───┘
    │             │       │
    │         Retries  Max Retries
    │         Left     Reached
    │             │       │
    │             ▼       ▼
    │      ┌─────────┐  Task
    │      │  Wait   │  Failed
    │      │ Delay   │    │
    │      └────┬────┘    │
    │           │         │
    │           └─────────┘
    │                 │
    ▼                 ▼
  Next Task    Workflow Failed

Retry Strategies:
- FIXED: Wait same time (e.g., 10s)
- EXPONENTIAL_BACKOFF: Wait increases (10s, 20s, 40s)
```

## Workflow State Transitions

```
SCHEDULED → RUNNING → COMPLETED ✓
    │           │
    │           └─→ FAILED ✗
    │                  │
    │                  ▼
    │              (Retry possible)
    │
    └─→ TIMED_OUT ⏱
    │
    └─→ TERMINATED ⛔ (Manual)
```

## Data Flow Example

```
Email Thread #1
    │
    ├─ Subject: "Need 100 widgets urgent"
    ├─ From: john@company.com
    └─ Messages:
         ├─ "We need 100 Widget-A ASAP"
         └─ "Also 50 Gadget-B by Friday"
              │
              ▼
        Summarization
              │
              ├─ products: [
              │    {code: "WIDGET-A", qty: 100},
              │    {code: "GADGET-B", qty: 50}
              │  ]
              ├─ urgency: "high"
              └─ deadline: "Friday"
                    │
                    ▼
              Pricing Lookup
                    │
              ├─ WIDGET-A: $10.00
              └─ GADGET-B: $25.00
                    │
                    ▼
              Calculate Totals
                    │
              ├─ Subtotal: $2,250.00
              ├─ Tax (8%): $180.00
              ├─ Discount (5%): -$112.50
              └─ Total: $2,317.50
                    │
                    ▼
              Generate Quote
                    │
              Quote #Q-20231215-001
                    │
                    ├─ PDF Generated
                    └─ Notification Sent ✓
```

---

These diagrams illustrate how Conductor orchestrates the backend workflows for email summarization and quote generation.
