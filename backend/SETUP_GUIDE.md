# Complete Setup Guide - Email Summarization & Quote Generation Backend

This guide provides step-by-step instructions to set up and run the backend system without any errors.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Quick Start (for experienced users)](#quick-start)
3. [Detailed Setup Instructions](#detailed-setup-instructions)
4. [Verifying the Installation](#verifying-the-installation)
5. [Common Issues and Solutions](#common-issues-and-solutions)
6. [Testing the System](#testing-the-system)

## Prerequisites

Before starting, ensure you have:

### 1. Python 3.9+
```bash
python3 --version
# Should show: Python 3.9.x or higher
```

If not installed:
- **Windows**: Download from https://www.python.org/downloads/
- **macOS**: `brew install python@3.9`
- **Linux**: `sudo apt install python3.9 python3.9-venv python3-pip`

### 2. PostgreSQL 12+
```bash
psql --version
# Should show: psql (PostgreSQL) 12.x or higher
```

If not installed:
- **Windows**: Download from https://www.postgresql.org/download/windows/
- **macOS**: `brew install postgresql@14`
- **Linux**: `sudo apt install postgresql postgresql-contrib`

### 3. Azure OpenAI Access
- Azure subscription
- Azure OpenAI service created
- GPT-4o deployment configured
- API key and endpoint available

## Quick Start

For experienced users, here's the quick setup:

```bash
# 1. Navigate to backend directory
cd backend

# 2. Create and activate virtual environment
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# 3. Install dependencies
pip install -r requirements.txt

# 4. Set up database
createdb hackathon_db
psql -d hackathon_db -f ../db/schema/crm_schema.sql
psql -d hackathon_db -f ../db/schema/erp_schema.sql
psql -d hackathon_db -f sample_data.sql

# 5. Configure environment
cp .env.example .env
# Edit .env with your configuration

# 6. Create directories
mkdir -p output/pdfs

# 7. Run the server
chmod +x run.sh
./run.sh
```

## Detailed Setup Instructions

### Step 1: Set Up Python Environment

#### 1.1 Navigate to Backend Directory
```bash
cd /path/to/Hackathon/backend
```

#### 1.2 Create Virtual Environment
```bash
# Create virtual environment
python3 -m venv venv

# Verify creation
ls -la venv/
# You should see: bin/, include/, lib/, pyvenv.cfg
```

#### 1.3 Activate Virtual Environment

**On macOS/Linux:**
```bash
source venv/bin/activate

# Verify activation - you should see (venv) in your prompt
# (venv) user@computer:~/backend$
```

**On Windows:**
```cmd
venv\Scripts\activate

# Verify activation
# (venv) C:\Users\YourName\backend>
```

#### 1.4 Upgrade pip
```bash
pip install --upgrade pip
```

#### 1.5 Install Dependencies
```bash
pip install -r requirements.txt

# This will install:
# - FastAPI and Uvicorn (API framework)
# - Azure OpenAI SDK
# - PostgreSQL adapter (psycopg2)
# - SQLAlchemy (ORM)
# - ReportLab (PDF generation)
# - And other dependencies
```

**Verify installation:**
```bash
pip list | grep -E "fastapi|openai|psycopg2|sqlalchemy|reportlab"
```

### Step 2: Set Up PostgreSQL Database

#### 2.1 Start PostgreSQL Service

**On macOS:**
```bash
brew services start postgresql@14
```

**On Linux:**
```bash
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

**On Windows:**
PostgreSQL service should start automatically. If not, start it from Services panel.

#### 2.2 Create Database

```bash
# Connect as postgres user
psql -U postgres

# In psql, create database:
CREATE DATABASE hackathon_db;

# Verify creation
\l
# You should see hackathon_db in the list

# Exit psql
\q
```

**Troubleshooting:**
- If you get "peer authentication failed", edit `pg_hba.conf`:
  ```bash
  # Find pg_hba.conf location
  psql -U postgres -c "SHOW hba_file;"
  
  # Edit it and change peer to md5 for local connections
  sudo nano /path/to/pg_hba.conf
  
  # Restart PostgreSQL
  sudo systemctl restart postgresql
  ```

#### 2.3 Load Database Schemas

```bash
# Navigate to repository root
cd ..

# Load CRM schema (creates customer, quotation, email tables)
psql -U postgres -d hackathon_db -f db/schema/crm_schema.sql

# Load ERP schema (creates vendor, product, pricing tables)
psql -U postgres -d hackathon_db -f db/schema/erp_schema.sql

# Load sample product data
cd backend
psql -U postgres -d hackathon_db -f sample_data.sql
```

**Verify schema loading:**
```bash
psql -U postgres -d hackathon_db -c "\dn"
# Should show: crm, erp schemas

psql -U postgres -d hackathon_db -c "SELECT count(*) FROM erp.erp_product;"
# Should show: 5 products
```

### Step 3: Configure Azure OpenAI

#### 3.1 Get Azure OpenAI Credentials

1. Log in to Azure Portal (https://portal.azure.com)
2. Navigate to your Azure OpenAI resource
3. Click on "Keys and Endpoint" in the left menu
4. Copy:
   - **Endpoint**: Something like `https://your-resource.openai.azure.com/`
   - **Key 1**: Your API key

#### 3.2 Get Deployment Name

1. In Azure OpenAI Studio (https://oai.azure.com)
2. Go to "Deployments"
3. Find your GPT-4o deployment
4. Copy the deployment name (e.g., `gpt-4o`, `gpt-4o-deployment`)

### Step 4: Configure Environment Variables

#### 4.1 Copy Example File
```bash
cd backend
cp .env.example .env
```

#### 4.2 Edit Configuration
```bash
# Open .env in your favorite editor
nano .env
# OR
vi .env
# OR on Windows
notepad .env
```

#### 4.3 Update Values

Replace the placeholder values with your actual configuration:

```bash
# Azure OpenAI Configuration
AZURE_OPENAI_ENDPOINT=https://your-actual-resource.openai.azure.com/
AZURE_OPENAI_API_KEY=your-actual-api-key-here
AZURE_OPENAI_DEPLOYMENT_NAME=gpt-4o  # or your deployment name
AZURE_OPENAI_API_VERSION=2024-02-15-preview

# PostgreSQL Database Configuration
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_NAME=hackathon_db
DATABASE_USER=postgres
DATABASE_PASSWORD=your_postgres_password

# Application Configuration
APP_ENV=development
DEBUG=True
API_PREFIX=/api/v1

# CORS Configuration
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:5173

# PDF Generation
PDF_OUTPUT_DIR=./output/pdfs

# Logging
LOG_LEVEL=INFO
```

**Important Notes:**
- The `AZURE_OPENAI_ENDPOINT` must end with a forward slash `/`
- Replace `your-actual-api-key-here` with your actual API key
- Update `your_postgres_password` with your PostgreSQL password
- Save and close the file

### Step 5: Create Required Directories

```bash
mkdir -p output/pdfs

# Verify creation
ls -la output/
# Should show: pdfs/
```

### Step 6: Verify Installation

#### 6.1 Test Database Connection
```bash
python -c "from app.utils import test_db_connection; print('✓ Database OK' if test_db_connection() else '✗ Database Failed')"
```

#### 6.2 Test Azure OpenAI Configuration
```bash
python -c "from app.config import settings; print('✓ Azure OpenAI Configured' if settings.AZURE_OPENAI_API_KEY else '✗ Azure OpenAI Not Configured')"
```

#### 6.3 Test Imports
```bash
python -c "from app.main import app; print('✓ All imports successful')"
```

### Step 7: Run the Application

#### 7.1 Using the Run Script (Recommended)
```bash
# Make script executable (macOS/Linux)
chmod +x run.sh

# Run the script
./run.sh
```

#### 7.2 Manual Start
```bash
# Activate virtual environment if not already active
source venv/bin/activate

# Start server
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

#### 7.3 Using Python Directly
```bash
python -m app.main
```

### Step 8: Verify Server is Running

1. **Check Server Output**
   ```
   INFO:     Uvicorn running on http://0.0.0.0:8000 (Press CTRL+C to quit)
   INFO:     Started reloader process
   INFO:     Started server process
   INFO:     Waiting for application startup.
   INFO:     Starting Email Summarization & Quote Generation API v1.0.0
   INFO:     Database connection successful
   INFO:     Azure OpenAI configured
   ```

2. **Test Health Endpoint**
   ```bash
   curl http://localhost:8000/health
   ```
   
   Expected response:
   ```json
   {
     "status": "healthy",
     "version": "1.0.0",
     "environment": "development",
     "database": "healthy",
     "services": {
       "api": "healthy",
       "database": "healthy",
       "azure_openai": "configured"
     }
   }
   ```

3. **Access API Documentation**
   - Open browser to: http://localhost:8000/docs
   - You should see the Swagger UI with all API endpoints

## Testing the System

### Test 1: List Email Conversations

**Using Browser:**
- Navigate to: http://localhost:8000/docs
- Find `GET /api/v1/emails/`
- Click "Try it out" → "Execute"

**Using curl:**
```bash
curl http://localhost:8000/api/v1/emails/
```

**Expected Result:**
You should see 3 mock email conversations (thread IDs: 21, 22, 23)

### Test 2: View Specific Email Thread

```bash
curl http://localhost:8000/api/v1/emails/21
```

**Expected Result:**
Full email thread with messages from Mark Thompson about CAT 320 Excavator

### Test 3: Summarize Email Conversation

```bash
curl -X POST http://localhost:8000/api/v1/emails/21/summarize
```

**Expected Result:**
AI-generated summary with:
- Products requested
- Quantities
- Urgency
- Shipping address
- Customer requirements

### Test 4: Generate Quote

```bash
curl -X POST "http://localhost:8000/api/v1/quotes/generate?thread_id=21"
```

**Expected Result:**
Complete quote with:
- Quote number
- Line items with pricing from database
- Tax calculations
- Total amount

### Test 5: Download PDF

```bash
curl -X GET "http://localhost:8000/api/v1/quotes/Q-XXXXX-XXXX/pdf?thread_id=21" --output quote.pdf
```

**Expected Result:**
Professional PDF quote document downloaded

## Common Issues and Solutions

### Issue 1: "ModuleNotFoundError: No module named 'app'"

**Solution:**
```bash
# Make sure you're in the backend directory
pwd  # Should show: .../backend

# Make sure virtual environment is activated
# You should see (venv) in your prompt

# Reinstall dependencies
pip install -r requirements.txt
```

### Issue 2: "psycopg2.OperationalError: could not connect to server"

**Solutions:**

1. **Check if PostgreSQL is running:**
   ```bash
   # On macOS
   brew services list | grep postgresql
   
   # On Linux
   sudo systemctl status postgresql
   ```

2. **Verify database exists:**
   ```bash
   psql -U postgres -l | grep hackathon_db
   ```

3. **Check connection settings in .env:**
   ```bash
   cat .env | grep DATABASE
   ```

4. **Test direct connection:**
   ```bash
   psql -U postgres -d hackathon_db -c "SELECT 1;"
   ```

### Issue 3: "Azure OpenAI authentication failed"

**Solutions:**

1. **Verify endpoint format:**
   - Must end with `/`
   - Example: `https://your-resource.openai.azure.com/`

2. **Check API key:**
   ```bash
   # View current setting (masks the key)
   python -c "from app.config import settings; print(f'Endpoint: {settings.AZURE_OPENAI_ENDPOINT}'); print(f'Key length: {len(settings.AZURE_OPENAI_API_KEY)}')"
   ```

3. **Verify deployment exists:**
   - Log in to Azure OpenAI Studio
   - Check deployments page
   - Ensure deployment name matches .env setting

### Issue 4: "Permission denied: './output/pdfs'"

**Solution:**
```bash
# Create directory with proper permissions
mkdir -p output/pdfs
chmod 755 output/pdfs

# Verify
ls -la output/
```

### Issue 5: Port 8000 already in use

**Solution:**
```bash
# Find process using port 8000
# On macOS/Linux:
lsof -i :8000

# Kill the process
kill -9 <PID>

# Or use a different port
uvicorn app.main:app --reload --port 8001
```

### Issue 6: "ImportError: cannot import name 'settings'"

**Solution:**
```bash
# Ensure .env file exists
ls -la .env

# If missing, copy from example
cp .env.example .env

# Verify imports
python -c "from app.config import settings; print('OK')"
```

## Production Deployment Notes

When deploying to production:

1. **Change environment to production:**
   ```bash
   APP_ENV=production
   DEBUG=False
   ```

2. **Use strong database password:**
   ```bash
   DATABASE_PASSWORD=<strong-password>
   ```

3. **Secure API keys:**
   - Use Azure Key Vault or similar
   - Don't commit .env to version control

4. **Use production WSGI server:**
   ```bash
   gunicorn app.main:app -w 4 -k uvicorn.workers.UvicornWorker
   ```

5. **Set up HTTPS:**
   - Use reverse proxy (nginx)
   - Configure SSL certificates

6. **Configure monitoring:**
   - Set up logging
   - Configure alerts
   - Monitor database connections

## Support

If you encounter issues not covered here:

1. Check application logs
2. Verify all prerequisites are met
3. Review environment variable configuration
4. Test each component independently
5. Consult the main README.md for additional information

## Summary

You should now have:
- ✓ Python environment set up
- ✓ PostgreSQL database configured with schemas
- ✓ Azure OpenAI integrated
- ✓ Backend server running on http://localhost:8000
- ✓ API documentation available at http://localhost:8000/docs

The system is ready to:
- Track email conversations
- Summarize emails using AI
- Generate quotes with pricing from database
- Create PDF documents

**Next Steps:**
1. Explore API documentation at /docs
2. Test all endpoints with the mock data
3. Integrate with frontend application
4. Customize for your specific requirements
