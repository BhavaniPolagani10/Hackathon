# Running Backend on Conductor - Complete Guide

This document provides the JSON configurations and step-by-step instructions to run your Hackathon backend on top of Netflix Conductor in Docker.

## What You Get

✅ **Complete Docker setup** with Conductor, Backend, Database, and UI  
✅ **2 Pre-configured workflows**: Email Summarization & Quote Generation  
✅ **11 Task definitions** with retry logic and error handling  
✅ **One-command setup** to register everything  
✅ **Web UI** for monitoring and managing workflows  

## JSON Agent Configurations

### 1. Email Summarization Workflow

**File**: `conductor/workflows/email_summarization_workflow.json`

This workflow orchestrates email analysis using Azure OpenAI:

```json
{
  "name": "email_summarization_workflow",
  "description": "Workflow to summarize email conversations using Azure OpenAI GPT-4o",
  "version": 1,
  "tasks": [
    {
      "name": "fetch_email_thread",
      "taskReferenceName": "fetch_email_thread_ref",
      "type": "SIMPLE",
      "inputParameters": {
        "thread_id": "${workflow.input.thread_id}",
        "http_request": {
          "uri": "http://backend:8000/api/v1/emails/${workflow.input.thread_id}",
          "method": "GET"
        }
      }
    },
    {
      "name": "summarize_with_openai",
      "taskReferenceName": "summarize_with_openai_ref",
      "type": "SIMPLE",
      "inputParameters": {
        "thread_id": "${workflow.input.thread_id}",
        "http_request": {
          "uri": "http://backend:8000/api/v1/emails/${workflow.input.thread_id}/summarize",
          "method": "POST"
        }
      }
    }
  ],
  "outputParameters": {
    "summary": "${summarize_with_openai_ref.output.response.body}",
    "status": "completed"
  }
}
```

### 2. Quote Generation Workflow

**File**: `conductor/workflows/quote_generation_workflow.json`

This workflow handles end-to-end quote generation:

```json
{
  "name": "quote_generation_workflow",
  "description": "End-to-end workflow for generating quotes from email conversations",
  "version": 1,
  "tasks": [
    {
      "name": "summarize_email",
      "taskReferenceName": "summarize_email_ref",
      "type": "SUB_WORKFLOW",
      "subWorkflowParam": {
        "name": "email_summarization_workflow",
        "version": 1
      }
    },
    {
      "name": "generate_quote",
      "taskReferenceName": "generate_quote_ref",
      "type": "SIMPLE",
      "inputParameters": {
        "http_request": {
          "uri": "http://backend:8000/api/v1/quotes/generate?thread_id=${workflow.input.thread_id}",
          "method": "POST"
        }
      }
    },
    {
      "name": "generate_pdf",
      "taskReferenceName": "generate_pdf_ref",
      "type": "SIMPLE",
      "inputParameters": {
        "http_request": {
          "uri": "http://backend:8000/api/v1/quotes/${generate_quote_ref.output.response.body.quote_number}/pdf",
          "method": "GET"
        }
      }
    }
  ]
}
```

### Task Definitions

All task definitions are in `conductor/tasks/` directory:

- **fetch_email_thread.json** - Fetch email from backend
- **summarize_with_openai.json** - Call Azure OpenAI
- **extract_products.json** - Parse product requirements
- **fetch_pricing.json** - Get pricing from database
- **calculate_totals.json** - Calculate totals with tax
- **generate_quote.json** - Create quote document
- **generate_pdf.json** - Generate PDF
- And more...

## Steps to Run in Conductor

### Step 1: Set Up Environment

```bash
# Navigate to project directory
cd /path/to/Hackathon

# Create .env file with your Azure OpenAI credentials
cp .env.example .env
nano .env
```

Add your credentials:
```bash
AZURE_OPENAI_ENDPOINT=https://your-resource.openai.azure.com/
AZURE_OPENAI_API_KEY=your-api-key-here
AZURE_OPENAI_DEPLOYMENT_NAME=gpt-4o
```

### Step 2: Start Docker Services

```bash
# Start all services (Conductor, Backend, Database, UI)
docker-compose up -d

# This starts:
# - Conductor Server (port 8080)
# - Conductor UI (port 5555)
# - Backend API (port 8000)
# - PostgreSQL Database (port 5432)
# - Elasticsearch (port 9200)
# - Redis (port 6379)
```

### Step 3: Wait for Services

```bash
# Wait about 1-2 minutes for all services to be ready

# Check Conductor is ready
curl http://localhost:8080/health

# Check Backend is ready
curl http://localhost:8000/health
```

### Step 4: Register Workflows and Tasks

```bash
# Run the automated setup script
./conductor/setup.sh

# This will:
# ✓ Register all 11 task definitions
# ✓ Register email_summarization_workflow
# ✓ Register quote_generation_workflow
```

**OR** manually register:

```bash
# Register task definitions
for task in conductor/tasks/*.json; do
  curl -X POST http://localhost:8080/api/metadata/taskdefs \
    -H "Content-Type: application/json" \
    -d @"$task"
done

# Register workflows
curl -X POST http://localhost:8080/api/metadata/workflow \
  -H "Content-Type: application/json" \
  -d @conductor/workflows/email_summarization_workflow.json

curl -X POST http://localhost:8080/api/metadata/workflow \
  -H "Content-Type: application/json" \
  -d @conductor/workflows/quote_generation_workflow.json
```

### Step 5: Execute Workflows

#### Option A: Using curl

**Run Email Summarization:**
```bash
curl -X POST http://localhost:8080/api/workflow/email_summarization_workflow \
  -H "Content-Type: application/json" \
  -d '{"thread_id": 1}'
```

**Run Quote Generation:**
```bash
curl -X POST http://localhost:8080/api/workflow/quote_generation_workflow \
  -H "Content-Type: application/json" \
  -d '{"thread_id": 1, "discount_rate": 0.05}'
```

#### Option B: Using Example Scripts

```bash
# Run email summarization for thread 1
./conductor/examples/run_email_summarization.sh 1

# Run quote generation for thread 1 with 10% discount
./conductor/examples/run_quote_generation.sh 1 0.10
```

#### Option C: Using Conductor UI

1. Open browser: http://localhost:5555
2. Go to "Workbench" → "Workflow Definitions"
3. Click on "email_summarization_workflow"
4. Click "Execute"
5. Enter input:
   ```json
   {
     "thread_id": 1
   }
   ```
6. Click "Execute Workflow"
7. Go to "Executions" to see progress

### Step 6: Monitor Workflows

**Check workflow status:**
```bash
# List all executions
curl http://localhost:8080/api/workflow/search

# Get specific execution
curl http://localhost:8080/api/workflow/<workflow-id>
```

**Use the UI:**
- Open http://localhost:5555
- Go to "Executions"
- Click on a workflow to see:
  - Task execution status
  - Input/output of each task
  - Timeline
  - Error logs (if any)

## Complete Architecture

```
┌─────────────────┐
│   Your Request  │
└────────┬────────┘
         │
         ▼
┌─────────────────────────────┐
│    Conductor Server         │  (Orchestrates everything)
│    http://localhost:8080    │
└──────┬──────────────────────┘
       │
       ├─→ Task 1: Fetch Email ──→ Backend API (http://backend:8000)
       │                                │
       │                                ▼
       │                           PostgreSQL
       │
       ├─→ Task 2: Summarize ────→ Backend API
       │                                │
       │                                ▼
       │                           Azure OpenAI
       │
       └─→ Task 3: Generate Quote ──→ Backend API
                                        │
                                        ▼
                                   PDF Generation

Monitor everything in real-time:
http://localhost:5555 (Conductor UI)
```

## What Each Service Does

| Service | Port | Purpose |
|---------|------|---------|
| Conductor UI | 5555 | Web interface to monitor and manage workflows |
| Conductor Server | 8080 | Workflow orchestration engine |
| Backend API | 8000 | Your FastAPI application |
| Elasticsearch | 9200 | Indexes workflow data for search |
| Redis | 6379 | Task queue and caching |
| PostgreSQL | 5432 | Application database |

## Testing the Setup

```bash
# 1. Check all services are running
docker-compose ps

# 2. Check backend health
curl http://localhost:8000/health

# 3. List registered workflows
curl http://localhost:8080/api/metadata/workflow

# 4. Run a test workflow
curl -X POST http://localhost:8080/api/workflow/email_summarization_workflow \
  -H "Content-Type: application/json" \
  -d '{"thread_id": 1}'

# 5. Get the workflow ID from response, then check status
curl http://localhost:8080/api/workflow/<workflow-id>
```

## Common Operations

### Restart a Failed Workflow
```bash
curl -X POST http://localhost:8080/api/workflow/<workflow-id>/retry
```

### Stop a Running Workflow
```bash
curl -X DELETE http://localhost:8080/api/workflow/<workflow-id>
```

### View Workflow Logs
```bash
# In Conductor UI
# Go to Executions → Click workflow → View task logs
```

## Stopping Services

```bash
# Stop all services
docker-compose down

# Stop and remove all data (fresh start)
docker-compose down -v
```

## Next Steps

1. **Customize workflows**: Edit JSON files in `conductor/workflows/`
2. **Add more tasks**: Create new task definitions in `conductor/tasks/`
3. **Monitor production**: Use Conductor UI for real-time monitoring
4. **Scale up**: Add more Conductor worker nodes

## Troubleshooting

**Problem**: Conductor not starting  
**Solution**: Wait 2 minutes for Elasticsearch, then `docker-compose restart conductor-server`

**Problem**: Workflow fails  
**Solution**: Check Conductor UI logs, verify backend is accessible: `docker-compose exec conductor-server curl http://backend:8000/health`

**Problem**: Tasks timing out  
**Solution**: Increase `timeoutSeconds` in task definitions

## Full Documentation

- **Quick Start**: [conductor/QUICKSTART.md](./QUICKSTART.md)
- **Complete Guide**: [conductor/README.md](./README.md)
- **Diagrams**: [conductor/DIAGRAMS.md](./DIAGRAMS.md)

---

**You now have a production-ready workflow orchestration system running your backend in Docker with Conductor!** 🚀
