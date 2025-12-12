#!/bin/bash

# Conductor Setup Script for Hackathon Backend
# This script sets up and registers Conductor workflows

set -e

echo "================================================"
echo "Hackathon Conductor Setup Script"
echo "================================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration
CONDUCTOR_URL="http://localhost:8080"
BACKEND_URL="http://localhost:8000"

# Function to wait for service
wait_for_service() {
    local url=$1
    local name=$2
    local max_attempts=30
    local attempt=1

    echo -n "Waiting for $name to be ready..."
    while [ $attempt -le $max_attempts ]; do
        if curl -s -f "$url" > /dev/null 2>&1; then
            echo -e " ${GREEN}✓${NC}"
            return 0
        fi
        echo -n "."
        sleep 2
        ((attempt++))
    done
    echo -e " ${RED}✗${NC}"
    echo "ERROR: $name did not start in time"
    return 1
}

# Check if Docker Compose is running
if ! docker-compose ps | grep -q "Up"; then
    echo "Starting Docker Compose services..."
    docker-compose up -d
fi

# Wait for services to be ready
echo ""
echo "Checking services..."
wait_for_service "$CONDUCTOR_URL/health" "Conductor Server" || exit 1
wait_for_service "$BACKEND_URL/health" "Backend API" || exit 1
wait_for_service "http://localhost:9200/_cluster/health" "Elasticsearch" || exit 1

echo ""
echo "================================================"
echo "Registering Task Definitions"
echo "================================================"

# Register each task
for task_file in conductor/tasks/*.json; do
    task_name=$(basename "$task_file" .json)
    echo -n "Registering task: $task_name..."
    
    response=$(curl -s -w "\n%{http_code}" -X POST "$CONDUCTOR_URL/api/metadata/taskdefs" \
        -H "Content-Type: application/json" \
        -d @"$task_file")
    
    http_code=$(echo "$response" | tail -n1)
    
    if [ "$http_code" = "204" ] || [ "$http_code" = "200" ]; then
        echo -e " ${GREEN}✓${NC}"
    else
        echo -e " ${YELLOW}⚠${NC} (might already exist)"
    fi
done

echo ""
echo "================================================"
echo "Registering Workflow Definitions"
echo "================================================"

# Register email summarization workflow
echo -n "Registering workflow: email_summarization_workflow..."
response=$(curl -s -w "\n%{http_code}" -X POST "$CONDUCTOR_URL/api/metadata/workflow" \
    -H "Content-Type: application/json" \
    -d @conductor/workflows/email_summarization_workflow.json)

http_code=$(echo "$response" | tail -n1)
if [ "$http_code" = "204" ] || [ "$http_code" = "200" ]; then
    echo -e " ${GREEN}✓${NC}"
else
    echo -e " ${YELLOW}⚠${NC} (might already exist)"
fi

# Register quote generation workflow
echo -n "Registering workflow: quote_generation_workflow..."
response=$(curl -s -w "\n%{http_code}" -X POST "$CONDUCTOR_URL/api/metadata/workflow" \
    -H "Content-Type: application/json" \
    -d @conductor/workflows/quote_generation_workflow.json)

http_code=$(echo "$response" | tail -n1)
if [ "$http_code" = "204" ] || [ "$http_code" = "200" ]; then
    echo -e " ${GREEN}✓${NC}"
else
    echo -e " ${YELLOW}⚠${NC} (might already exist)"
fi

echo ""
echo "================================================"
echo "Setup Complete!"
echo "================================================"
echo ""
echo "Services are running at:"
echo "  • Conductor UI:     http://localhost:5555"
echo "  • Conductor Server: http://localhost:8080"
echo "  • Backend API:      http://localhost:8000"
echo "  • Backend API Docs: http://localhost:8000/docs"
echo ""
echo "To execute a workflow:"
echo ""
echo "  1. Email Summarization:"
echo "     curl -X POST $CONDUCTOR_URL/api/workflow/email_summarization_workflow \\"
echo "       -H 'Content-Type: application/json' \\"
echo "       -d '{\"thread_id\": 1}'"
echo ""
echo "  2. Quote Generation:"
echo "     curl -X POST $CONDUCTOR_URL/api/workflow/quote_generation_workflow \\"
echo "       -H 'Content-Type: application/json' \\"
echo "       -d '{\"thread_id\": 1, \"discount_rate\": 0.05}'"
echo ""
echo "View workflows in the UI: http://localhost:5555"
echo ""
