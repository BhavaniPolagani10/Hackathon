#!/bin/bash

# Example: Run Quote Generation Workflow
# This script demonstrates how to execute the quote generation workflow

set -e

CONDUCTOR_URL="http://localhost:8080"
THREAD_ID=${1:-1}  # Default to thread_id=1 if not provided
DISCOUNT_RATE=${2:-0.05}  # Default 5% discount

echo "================================================"
echo "Running Quote Generation Workflow"
echo "================================================"
echo "Thread ID: $THREAD_ID"
echo "Discount Rate: $DISCOUNT_RATE"
echo ""

# Start the workflow
echo "Starting workflow..."
WORKFLOW_ID=$(curl -s -X POST "$CONDUCTOR_URL/api/workflow/quote_generation_workflow" \
    -H "Content-Type: application/json" \
    -d "{\"thread_id\": $THREAD_ID, \"discount_rate\": $DISCOUNT_RATE}" | tr -d '"')

if [ -z "$WORKFLOW_ID" ]; then
    echo "ERROR: Failed to start workflow"
    exit 1
fi

echo "Workflow started with ID: $WORKFLOW_ID"
echo ""

# Poll for completion
MAX_WAIT=120  # Quote generation may take longer
ELAPSED=0
echo "Waiting for workflow to complete..."

while [ $ELAPSED -lt $MAX_WAIT ]; do
    STATUS=$(curl -s "$CONDUCTOR_URL/api/workflow/$WORKFLOW_ID" | jq -r '.status')
    
    case $STATUS in
        "COMPLETED")
            echo ""
            echo "✓ Workflow completed successfully!"
            echo ""
            echo "Quote details:"
            curl -s "$CONDUCTOR_URL/api/workflow/$WORKFLOW_ID" | jq '{
                status: .status,
                quote_number: .output.quote_number,
                pdf_url: .output.pdf_url,
                startTime: .startTime,
                endTime: .endTime
            }'
            
            QUOTE_NUMBER=$(curl -s "$CONDUCTOR_URL/api/workflow/$WORKFLOW_ID" | jq -r '.output.quote_number')
            echo ""
            echo "Download PDF: http://localhost:8000/api/v1/quotes/$QUOTE_NUMBER/pdf?thread_id=$THREAD_ID"
            exit 0
            ;;
        "FAILED")
            echo ""
            echo "✗ Workflow failed!"
            echo ""
            echo "Error details:"
            curl -s "$CONDUCTOR_URL/api/workflow/$WORKFLOW_ID" | jq '.tasks[] | select(.status == "FAILED")'
            exit 1
            ;;
        "RUNNING"|"SCHEDULED")
            echo -n "."
            sleep 2
            ((ELAPSED+=2))
            ;;
        *)
            echo ""
            echo "Workflow status: $STATUS"
            sleep 2
            ((ELAPSED+=2))
            ;;
    esac
done

echo ""
echo "WARNING: Workflow did not complete within $MAX_WAIT seconds"
echo "Current status: $(curl -s "$CONDUCTOR_URL/api/workflow/$WORKFLOW_ID" | jq -r '.status')"
echo ""
echo "Check the Conductor UI for details: http://localhost:5555/execution/$WORKFLOW_ID"
