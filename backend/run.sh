#!/bin/bash

# Email Summarization & Quote Generation Backend - Run Script

echo "======================================"
echo "Email Summarization & Quote Generation"
echo "======================================"
echo ""

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo "Virtual environment not found. Creating..."
    python3 -m venv venv
    echo "✓ Virtual environment created"
fi

# Activate virtual environment
echo "Activating virtual environment..."
source venv/bin/activate

# Install/update dependencies
echo "Installing dependencies..."
pip install -q -r requirements.txt
echo "✓ Dependencies installed"

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo "⚠ Warning: .env file not found!"
    echo "Please copy .env.example to .env and configure it."
    echo "cp .env.example .env"
    exit 1
fi

# Create output directories
mkdir -p output/pdfs
echo "✓ Output directories created"

# Test database connection
echo ""
echo "Testing database connection..."
python -c "from app.utils import test_db_connection; exit(0 if test_db_connection() else 1)"
if [ $? -eq 0 ]; then
    echo "✓ Database connection successful"
else
    echo "⚠ Warning: Database connection failed"
    echo "Please check your database configuration in .env"
fi

echo ""
echo "======================================"
echo "Starting FastAPI Server"
echo "======================================"
echo ""
echo "Server will be available at:"
echo "  - API: http://localhost:8000"
echo "  - Docs: http://localhost:8000/docs"
echo "  - Health: http://localhost:8000/health"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""

# Start the server
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
