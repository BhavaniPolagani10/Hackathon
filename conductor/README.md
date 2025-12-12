# Running Backend with Netflix Conductor

This guide explains how to run the Hackathon backend application with Netflix Conductor workflow orchestration in Docker.

## Overview

Netflix Conductor is a workflow orchestration engine that allows you to:
- Define workflows as JSON
- Orchestrate microservices and APIs
- Handle retries, error handling, and timeouts
- Monitor and manage workflow executions

This integration provides two main workflows:
1. **Email Summarization Workflow**: Processes email threads using Azure OpenAI
2. **Quote Generation Workflow**: End-to-end quote generation from email conversations

## Architecture

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────┐
│  Conductor UI   │────▶│ Conductor Server │────▶│   Backend   │
│  (Port 5555)    │     │   (Port 8080)    │     │ (Port 8000) │
└─────────────────┘     └──────────────────┘     └─────────────┘
                               │
                               ├─────▶ Elasticsearch (Indexing)
                               └─────▶ Redis (Queue)
```

## Prerequisites

- **Docker** and **Docker Compose** installed
- **Azure OpenAI** credentials (for AI features)
- At least **4GB RAM** available for Docker

## Quick Start

### 1. Configure Environment Variables

Create a `.env` file in the root directory:

```bash
# Azure OpenAI Configuration
AZURE_OPENAI_ENDPOINT=https://your-resource.openai.azure.com/
AZURE_OPENAI_API_KEY=your-api-key-here
AZURE_OPENAI_DEPLOYMENT_NAME=gpt-4o
```

### 2. Start All Services

```bash
# Start all containers
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f
```

### 3. Wait for Services to be Ready

```bash
# Check backend health
curl http://localhost:8000/health

# Check Conductor server
curl http://localhost:8080/health

# Check Elasticsearch
curl http://localhost:9200/_cluster/health
```

### 4. Access the Services

- **Conductor UI**: http://localhost:5555
- **Backend API**: http://localhost:8000
- **Backend API Docs**: http://localhost:8000/docs
- **Conductor Server**: http://localhost:8080
- **Frontend** (optional): http://localhost:3000

## Setting Up Conductor Workflows

### Register Task Definitions

Register all task definitions with Conductor:

```bash
# Register all tasks
for task in conductor/tasks/*.json; do
  curl -X POST http://localhost:8080/api/metadata/taskdefs \
    -H "Content-Type: application/json" \
    -d @"$task"
  echo "Registered: $task"
done
```

### Register Workflow Definitions

Register the workflow definitions:

```bash
# Register Email Summarization Workflow
curl -X POST http://localhost:8080/api/metadata/workflow \
  -H "Content-Type: application/json" \
  -d @conductor/workflows/email_summarization_workflow.json

# Register Quote Generation Workflow
curl -X POST http://localhost:8080/api/metadata/workflow \
  -H "Content-Type: application/json" \
  -d @conductor/workflows/quote_generation_workflow.json
```

### Verify Registration

Check registered workflows:

```bash
# List all workflows
curl http://localhost:8080/api/metadata/workflow

# Get specific workflow
curl http://localhost:8080/api/metadata/workflow/email_summarization_workflow
```

## Running Workflows

### Option 1: Using Conductor UI

1. Open http://localhost:5555
2. Navigate to "Workbench" → "Workflow Definitions"
3. Find your workflow and click "Execute"
4. Provide input parameters:
   ```json
   {
     "thread_id": 1
   }
   ```
5. Click "Execute Workflow"
6. View execution in "Executions" tab

### Option 2: Using API

#### Start Email Summarization Workflow

```bash
curl -X POST http://localhost:8080/api/workflow/email_summarization_workflow \
  -H "Content-Type: application/json" \
  -d '{
    "thread_id": 1
  }'
```

Response:
```json
"abc123-def456-ghi789"  # Workflow execution ID
```

#### Start Quote Generation Workflow

```bash
curl -X POST http://localhost:8080/api/workflow/quote_generation_workflow \
  -H "Content-Type: application/json" \
  -d '{
    "thread_id": 1,
    "discount_rate": 0.05
  }'
```

#### Check Workflow Status

```bash
# Get workflow status
curl http://localhost:8080/api/workflow/<workflow_id>

# Get workflow execution details
curl http://localhost:8080/api/workflow/<workflow_id>?includeTasks=true
```

## Workflow Details

### Email Summarization Workflow

**Purpose**: Analyze email conversations using Azure OpenAI GPT-4o

**Steps**:
1. Fetch email thread from backend
2. Validate email thread exists
3. Extract messages from thread
4. Summarize using Azure OpenAI
5. Store summary results

**Input**:
```json
{
  "thread_id": 1
}
```

**Output**:
```json
{
  "summary": {
    "summary": "Customer requesting quote for products...",
    "products": [...],
    "urgency": "high",
    "shipping_address": "..."
  },
  "thread_id": 1,
  "status": "completed"
}
```

### Quote Generation Workflow

**Purpose**: Generate complete quote from email conversation

**Steps**:
1. Fetch email thread
2. Summarize email (calls email_summarization_workflow)
3. Extract product requirements
4. Fetch pricing from database
5. Calculate totals with tax and discounts
6. Generate quote document
7. Generate PDF version
8. Send notification

**Input**:
```json
{
  "thread_id": 1,
  "discount_rate": 0.05
}
```

**Output**:
```json
{
  "quote_number": "Q-20231215-001",
  "quote": {...},
  "pdf_url": "/api/v1/quotes/Q-20231215-001/pdf",
  "status": "completed"
}
```

## Task Definitions

The following task workers are defined:

1. **fetch_email_thread**: GET email thread from backend API
2. **extract_messages**: Process email messages
3. **summarize_with_openai**: Call Azure OpenAI for summarization
4. **store_summary**: Store summary results
5. **extract_products**: Extract product info from summary
6. **fetch_pricing**: Get product pricing from database
7. **calculate_totals**: Calculate quote totals
8. **generate_quote**: Generate final quote
9. **generate_pdf**: Create PDF document
10. **notify_completion**: Send notifications
11. **handle_error**: Error handling

## Monitoring and Management

### View Workflow Executions

```bash
# List all executions of a workflow
curl "http://localhost:8080/api/workflow/search?query=workflowType=email_summarization_workflow"

# Get execution by ID
curl http://localhost:8080/api/workflow/<workflow_id>
```

### Retry Failed Workflow

```bash
curl -X POST http://localhost:8080/api/workflow/<workflow_id>/retry
```

### Restart Workflow

```bash
curl -X POST http://localhost:8080/api/workflow/<workflow_id>/restart
```

### Terminate Workflow

```bash
curl -X DELETE http://localhost:8080/api/workflow/<workflow_id>
```

## Testing the Integration

### 1. Load Sample Data

```bash
# Connect to PostgreSQL and load sample data
docker-compose exec postgres psql -U postgres -d hackathon_db -f /docker-entrypoint-initdb.d/sample_data.sql
```

### 2. Test Backend API

```bash
# List email threads
curl http://localhost:8000/api/v1/emails/

# Get specific thread
curl http://localhost:8000/api/v1/emails/1

# Summarize email (direct API call)
curl -X POST http://localhost:8000/api/v1/emails/1/summarize
```

### 3. Run Workflow

```bash
# Execute email summarization workflow
WORKFLOW_ID=$(curl -s -X POST http://localhost:8080/api/workflow/email_summarization_workflow \
  -H "Content-Type: application/json" \
  -d '{"thread_id": 1}' | jq -r '.')

echo "Workflow ID: $WORKFLOW_ID"

# Wait a few seconds, then check status
sleep 5
curl http://localhost:8080/api/workflow/$WORKFLOW_ID | jq '.'
```

### 4. Generate Quote via Workflow

```bash
# Execute quote generation workflow
QUOTE_WORKFLOW_ID=$(curl -s -X POST http://localhost:8080/api/workflow/quote_generation_workflow \
  -H "Content-Type: application/json" \
  -d '{"thread_id": 1, "discount_rate": 0.1}' | jq -r '.')

echo "Quote Workflow ID: $QUOTE_WORKFLOW_ID"

# Monitor execution
curl http://localhost:8080/api/workflow/$QUOTE_WORKFLOW_ID | jq '.status'
```

## Troubleshooting

### Services Not Starting

```bash
# Check container status
docker-compose ps

# View logs for specific service
docker-compose logs backend
docker-compose logs conductor-server
docker-compose logs elasticsearch

# Restart services
docker-compose restart
```

### Elasticsearch Issues

```bash
# Check Elasticsearch health
curl http://localhost:9200/_cluster/health

# If yellow/red, check indices
curl http://localhost:9200/_cat/indices

# Restart Elasticsearch
docker-compose restart elasticsearch
```

### Conductor Server Not Responding

```bash
# Check if server is up
curl http://localhost:8080/health

# View conductor logs
docker-compose logs -f conductor-server

# Restart conductor server
docker-compose restart conductor-server
```

### Backend Connection Issues

```bash
# Check backend health
curl http://localhost:8000/health

# Check database connection
docker-compose exec backend python -c "from app.utils import test_db_connection; print(test_db_connection())"

# View backend logs
docker-compose logs -f backend
```

### Workflow Failing

1. Check task execution logs in Conductor UI
2. Verify backend API is accessible from Conductor container:
   ```bash
   docker-compose exec conductor-server curl http://backend:8000/health
   ```
3. Check Azure OpenAI configuration
4. Review workflow input parameters

## Advanced Configuration

### Custom Conductor Configuration

Create `conductor/config/config-redis.properties`:

```properties
conductor.db.type=redis_standalone
conductor.redis.hosts=redis:6379
conductor.elasticsearch.url=http://elasticsearch:9200
conductor.elasticsearch.indexName=conductor
```

### Environment-Specific Settings

For production, update `docker-compose.yml`:

```yaml
backend:
  environment:
    APP_ENV: production
    DEBUG: "false"
    LOG_LEVEL: WARNING
```

### Scaling Workers

To handle more concurrent workflows, scale Conductor:

```bash
docker-compose up -d --scale conductor-server=3
```

## Cleanup

### Stop All Services

```bash
# Stop all containers
docker-compose down

# Stop and remove volumes
docker-compose down -v
```

### Remove Everything

```bash
# Remove all containers, volumes, and networks
docker-compose down -v --remove-orphans

# Clean up Docker system
docker system prune -a
```

## Additional Resources

- **Netflix Conductor Docs**: https://conductor.netflix.com/
- **Conductor GitHub**: https://github.com/Netflix/conductor
- **Backend API Docs**: http://localhost:8000/docs
- **Project README**: [README.md](../README.md)

## Summary

You now have:
- ✅ Backend running in Docker
- ✅ Netflix Conductor orchestrating workflows
- ✅ Email summarization workflow
- ✅ Quote generation workflow
- ✅ Full monitoring and management UI

The backend APIs are accessible through both:
1. Direct API calls (http://localhost:8000)
2. Conductor workflows (http://localhost:8080)

Use Conductor for complex, multi-step processes with retry logic and monitoring!
