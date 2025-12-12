# Conductor Integration - Quick Start Guide

Get your backend running with Netflix Conductor in 5 minutes!

## What is Conductor?

Netflix Conductor is a workflow orchestration engine that helps you:
- Chain multiple API calls together
- Handle retries and failures automatically
- Monitor workflow execution in real-time
- Scale microservices easily

## Prerequisites

- Docker and Docker Compose installed
- Azure OpenAI API key (for AI features)
- 4GB+ RAM available

## Steps to Run

### 1. Clone and Navigate

```bash
cd /path/to/Hackathon
```

### 2. Configure Azure OpenAI

```bash
# Copy the example environment file
cp .env.example .env

# Edit .env with your Azure OpenAI credentials
nano .env
```

Add your credentials:
```bash
AZURE_OPENAI_ENDPOINT=https://your-resource.openai.azure.com/
AZURE_OPENAI_API_KEY=your-actual-api-key
AZURE_OPENAI_DEPLOYMENT_NAME=gpt-4o
```

### 3. Start Everything

```bash
# Start all services with Docker Compose
docker-compose up -d

# Wait for services to be ready (about 1-2 minutes)
docker-compose ps
```

### 4. Setup Conductor Workflows

```bash
# Run the setup script to register workflows
./conductor/setup.sh
```

This script will:
- ✓ Wait for all services to be ready
- ✓ Register all task definitions
- ✓ Register workflow definitions

### 5. Access the Services

Open in your browser:
- **Conductor UI**: http://localhost:5555 (workflow management)
- **Backend API Docs**: http://localhost:8000/docs (API documentation)
- **Frontend**: http://localhost:3000 (web interface)

## Run Your First Workflow

### Option 1: Using the Example Script

```bash
# Run email summarization for thread ID 1
./conductor/examples/run_email_summarization.sh 1

# Run quote generation for thread ID 1 with 5% discount
./conductor/examples/run_quote_generation.sh 1 0.05
```

### Option 2: Using curl

```bash
# Start email summarization workflow
curl -X POST http://localhost:8080/api/workflow/email_summarization_workflow \
  -H "Content-Type: application/json" \
  -d '{"thread_id": 1}'

# Returns workflow ID like: "abc123-def456-ghi789"

# Check status
curl http://localhost:8080/api/workflow/<workflow-id>
```

### Option 3: Using Conductor UI

1. Go to http://localhost:5555
2. Click "Workbench" → "Workflow Definitions"
3. Find "email_summarization_workflow"
4. Click "Execute"
5. Enter input: `{"thread_id": 1}`
6. Click "Execute Workflow"
7. View progress in "Executions" tab

## Available Workflows

### 1. Email Summarization Workflow

**What it does**: Analyzes email conversations using AI

**Input**:
```json
{
  "thread_id": 1
}
```

**Run it**:
```bash
curl -X POST http://localhost:8080/api/workflow/email_summarization_workflow \
  -H "Content-Type: application/json" \
  -d '{"thread_id": 1}'
```

### 2. Quote Generation Workflow

**What it does**: Generates complete quote from email thread

**Input**:
```json
{
  "thread_id": 1,
  "discount_rate": 0.05
}
```

**Run it**:
```bash
curl -X POST http://localhost:8080/api/workflow/quote_generation_workflow \
  -H "Content-Type: application/json" \
  -d '{"thread_id": 1, "discount_rate": 0.05}'
```

## Monitoring Workflows

### View All Executions

```bash
# List all workflow executions
curl "http://localhost:8080/api/workflow/search?query=workflowType=email_summarization_workflow"
```

### Check Specific Execution

```bash
# Get workflow details
curl http://localhost:8080/api/workflow/<workflow-id>

# Get execution with task details
curl http://localhost:8080/api/workflow/<workflow-id>?includeTasks=true
```

### Use the UI

1. Open http://localhost:5555
2. Go to "Executions"
3. Filter by workflow type
4. Click on execution ID for details

## Troubleshooting

### Services not starting?

```bash
# Check what's running
docker-compose ps

# View logs
docker-compose logs -f

# Restart everything
docker-compose restart
```

### Conductor not accessible?

```bash
# Wait for Elasticsearch to be ready
curl http://localhost:9200/_cluster/health

# Check Conductor health
curl http://localhost:8080/health

# Restart Conductor
docker-compose restart conductor-server
```

### Backend API errors?

```bash
# Check backend health
curl http://localhost:8000/health

# Check database connection
docker-compose exec backend python -c "from app.utils import test_db_connection; print(test_db_connection())"

# View backend logs
docker-compose logs backend
```

### Workflow failed?

1. Check Conductor UI for task errors
2. Verify backend is accessible:
   ```bash
   docker-compose exec conductor-server curl http://backend:8000/health
   ```
3. Check Azure OpenAI credentials in .env
4. Review input parameters

## Stopping Services

```bash
# Stop all services
docker-compose down

# Stop and remove volumes (clean slate)
docker-compose down -v
```

## What's Next?

1. **Customize workflows**: Edit JSON files in `conductor/workflows/`
2. **Add new tasks**: Create task definitions in `conductor/tasks/`
3. **Build workers**: Implement custom task workers for complex logic
4. **Monitor production**: Use Conductor UI to track real-time execution

## Architecture Overview

```
User Request
    ↓
Conductor UI (http://localhost:5555)
    ↓
Conductor Server (http://localhost:8080)
    ↓
Workflows (JSON definitions)
    ↓
Tasks → Backend API (http://localhost:8000)
    ↓
PostgreSQL Database
    ↓
Azure OpenAI (GPT-4o)
```

## File Structure

```
conductor/
├── workflows/              # Workflow definitions (JSON)
│   ├── email_summarization_workflow.json
│   └── quote_generation_workflow.json
├── tasks/                  # Task definitions (JSON)
│   ├── fetch_email_thread.json
│   ├── summarize_with_openai.json
│   └── ... (more tasks)
├── examples/               # Example scripts
│   ├── run_email_summarization.sh
│   └── run_quote_generation.sh
├── setup.sh               # Setup script
└── README.md              # Detailed documentation
```

## Learn More

- **Detailed Guide**: [conductor/README.md](./README.md)
- **Backend Documentation**: [backend/README.md](../backend/README.md)
- **Netflix Conductor Docs**: https://conductor.netflix.com/

---

**Need help?** Check the [detailed README](./README.md) or open an issue!
