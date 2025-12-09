# Complete Deployment Guide - Email Quote Management System

## Overview

This guide provides complete step-by-step instructions to run the Email Quote Management System without any errors.

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                   Email Quote Management System              │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────┐         ┌─────────────────┐              │
│  │   Frontend   │ ◄─────► │   Backend API   │              │
│  │  (Optional)  │  CORS   │    (FastAPI)    │              │
│  │              │         │                 │              │
│  │  React/Vite  │         │  Port 8000      │              │
│  │  Port 5173   │         │                 │              │
│  └──────────────┘         └────────┬────────┘              │
│                                    │                         │
│                                    ▼                         │
│                           ┌─────────────────┐               │
│                           │  SQLite Database│               │
│                           │    app.db       │               │
│                           └─────────────────┘               │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## Prerequisites

### Required Software

1. **Python 3.8 or higher**
   - Check: `python3 --version` or `python --version`
   - Download: https://www.python.org/downloads/

2. **pip (Python Package Manager)**
   - Usually included with Python
   - Check: `pip --version` or `pip3 --version`

### System Requirements

- **OS**: Windows, macOS, or Linux
- **RAM**: 2GB minimum (4GB recommended)
- **Disk Space**: 500MB free space
- **Network**: Internet connection for initial setup

## Step-by-Step Installation

### Step 1: Clone or Navigate to Repository

```bash
# If you have the repository
cd Hackathon/backend

# If you're downloading
# Download the backend folder and navigate to it
```

### Step 2: Create Virtual Environment

**Why?** Isolates project dependencies from system Python packages.

**macOS/Linux:**
```bash
python3 -m venv venv
source venv/bin/activate
```

**Windows Command Prompt:**
```bash
python -m venv venv
venv\Scripts\activate
```

**Windows PowerShell:**
```bash
python -m venv venv
venv\Scripts\Activate.ps1
```

**Verification:**
You should see `(venv)` prefix in your terminal prompt.

### Step 3: Install Dependencies

```bash
pip install -r requirements.txt
```

**Expected output:**
```
Successfully installed fastapi-0.104.1 uvicorn-0.24.0 sqlalchemy-2.0.23 ...
```

**Troubleshooting:**
- If `pip` command not found, try `pip3`
- If permission error on macOS/Linux, add `--user` flag
- For slow downloads, use a mirror: `pip install -r requirements.txt -i https://pypi.org/simple`

### Step 4: Verify Installation

```bash
python -c "import fastapi; import uvicorn; import sqlalchemy; print('✓ All dependencies installed successfully')"
```

Expected output: `✓ All dependencies installed successfully`

## Running the Application

### Method 1: Using the Run Script (Recommended)

```bash
python run.py
```

### Method 2: Using Uvicorn Directly

```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### Method 3: Using Python Module

```bash
python -m uvicorn app.main:app --reload
```

**Expected Output:**
```
INFO:     Will watch for changes in these directories: ['/path/to/backend']
INFO:     Uvicorn running on http://0.0.0.0:8000 (Press CTRL+C to quit)
INFO:     Started reloader process
INFO:     Started server process
INFO:     Waiting for application startup.
INFO:     Application startup complete.
```

**Server is ready when you see:** `Application startup complete.`

## Loading Sample Data

In a **new terminal window** (keep server running):

### Step 1: Activate Virtual Environment Again

```bash
cd backend
source venv/bin/activate  # macOS/Linux
# or
venv\Scripts\activate  # Windows
```

### Step 2: Load Mock Emails

```bash
python utils/load_mock_data.py
```

**Expected Output:**
```
Initializing database...
Loading mock email data...
Added email: Inquiry about CAT 320 Excavator
Added email: RE: Quotation #Q-2025-1201 - CAT 320 Excavator
Added email: URGENT: Need Mini Excavator ASAP
Added email: Quote Request - Wheel Loader Fleet
Added email: Bulldozer Purchase - Trade-In Available
Added email: Multi-Location Fleet Order

Loaded 6 mock emails successfully!

You can now:
1. View emails at: http://localhost:8000/emails/
2. Analyze emails by sending POST to: http://localhost:8000/emails/{id}/analyze
3. Generate quotes at: http://localhost:8000/quotes/from-email/{email_id}
```

## Testing the System

### Option 1: Using Web Browser (Easiest)

1. **Open API Documentation:**
   ```
   http://localhost:8000/docs
   ```

2. **Try the following endpoints:**
   - `GET /health` - Check if server is healthy
   - `GET /emails/` - List all emails
   - `GET /dashboard/stats` - View statistics
   - `POST /emails/{id}/analyze` - Analyze an email (try ID: 3)
   - `POST /quotes/from-email/{id}` - Generate quote (try ID: 3)
   - `GET /quotes/{id}/pdf` - Download PDF (try ID: 1)

### Option 2: Using Command Line (curl)

```bash
# Check health
curl http://localhost:8000/health

# List emails
curl http://localhost:8000/emails/

# Analyze email #3
curl -X POST http://localhost:8000/emails/3/analyze

# Generate quote from email #3
curl -X POST http://localhost:8000/quotes/from-email/3

# Download PDF for quote #1
curl http://localhost:8000/quotes/1/pdf --output quote.pdf

# View dashboard stats
curl http://localhost:8000/dashboard/stats
```

### Option 3: Complete Workflow Test

```bash
# 1. Create a new email
curl -X POST "http://localhost:8000/emails/" \
  -H "Content-Type: application/json" \
  -d '{
    "subject": "Need 5 Excavators",
    "from_email": "buyer@company.com",
    "from_name": "John Buyer",
    "to_email": "sales@dealer.com",
    "body": "We need 5 CAT 320 excavators urgently for our construction project in New York. Delivery needed within 2 weeks."
  }'

# 2. The email will be auto-analyzed
# Note the email ID from response (e.g., 7)

# 3. Generate quote
curl -X POST http://localhost:8000/quotes/from-email/7

# 4. Note the quote ID from response (e.g., 5)

# 5. Download PDF
curl http://localhost:8000/quotes/5/pdf --output my_quote.pdf

# 6. Check stats
curl http://localhost:8000/dashboard/stats
```

## API Endpoints Reference

### Email Management

| Method | Endpoint | Description | Example |
|--------|----------|-------------|---------|
| POST | `/emails/` | Create new email | See workflow above |
| GET | `/emails/` | List all emails | `curl http://localhost:8000/emails/` |
| GET | `/emails/{id}` | Get specific email | `curl http://localhost:8000/emails/1` |
| GET | `/emails/{id}/summary` | Get email summary | `curl http://localhost:8000/emails/1/summary` |
| POST | `/emails/{id}/analyze` | Analyze/re-analyze | `curl -X POST http://localhost:8000/emails/1/analyze` |
| DELETE | `/emails/{id}` | Delete email | `curl -X DELETE http://localhost:8000/emails/1` |

### Quote Management

| Method | Endpoint | Description | Example |
|--------|----------|-------------|---------|
| POST | `/quotes/from-email/{id}` | Auto-generate quote | `curl -X POST http://localhost:8000/quotes/from-email/1` |
| GET | `/quotes/` | List all quotes | `curl http://localhost:8000/quotes/` |
| GET | `/quotes/{id}` | Get specific quote | `curl http://localhost:8000/quotes/1` |
| GET | `/quotes/{id}/pdf` | Download as PDF | Open in browser: `http://localhost:8000/quotes/1/pdf` |
| PUT | `/quotes/{id}/status` | Update status | `curl -X PUT http://localhost:8000/quotes/1/status?status=sent` |
| DELETE | `/quotes/{id}` | Delete quote | `curl -X DELETE http://localhost:8000/quotes/1` |

### Dashboard

| Method | Endpoint | Description | Example |
|--------|----------|-------------|---------|
| GET | `/dashboard/stats` | Get statistics | `curl http://localhost:8000/dashboard/stats` |

## Features Demonstration

### 1. Email Analysis

The system automatically extracts:

- **Customer Information**: Name, company, email
- **Products**: Equipment types (excavators, loaders, etc.)
- **Quantities**: Number of units requested
- **Urgency**: Urgent, high, medium, or low
- **Deadlines**: Delivery dates and timelines
- **Shipping Address**: Delivery location
- **Special Requirements**: Custom needs and notes

### 2. Quote Generation

Automatically calculates:

- **Unit Prices**: Based on equipment type
- **Volume Discounts**: 
  - 5% off for 3+ units
  - 10% off for 5+ units
- **Tax**: 8% on subtotal
- **Shipping**: $2,500 base + $500 per unit
- **Delivery Time**: Based on urgency and quantity
- **Total Cost**: Complete breakdown

### 3. PDF Export

Professional quote includes:

- Company branding and formatting
- Quote number and validity period
- Customer information
- Detailed product table
- Pricing breakdown
- Delivery information
- Terms and conditions

## Common Issues and Solutions

### Issue 1: Port Already in Use

**Error:** `Address already in use`

**Solution:**
```bash
# Use different port
uvicorn app.main:app --port 8001

# Or kill process on port 8000
# macOS/Linux:
lsof -ti:8000 | xargs kill -9

# Windows:
netstat -ano | findstr :8000
taskkill /PID <PID> /F
```

### Issue 2: Module Not Found

**Error:** `ModuleNotFoundError: No module named 'fastapi'`

**Solution:**
```bash
# Ensure virtual environment is activated
source venv/bin/activate  # macOS/Linux
venv\Scripts\activate  # Windows

# Reinstall dependencies
pip install -r requirements.txt
```

### Issue 3: Database Locked

**Error:** `database is locked`

**Solution:**
```bash
# Stop all server instances (Ctrl+C)
# Delete database
rm app.db

# Restart server
python run.py
```

### Issue 4: Permission Denied (macOS/Linux)

**Error:** `Permission denied` when installing packages

**Solution:**
```bash
# Install with --user flag
pip install --user -r requirements.txt

# Or use sudo (not recommended in venv)
sudo pip install -r requirements.txt
```

### Issue 5: Python Version Too Old

**Error:** `Python 3.8 or higher required`

**Solution:**
1. Download Python 3.8+ from https://www.python.org/
2. Install and verify: `python3 --version`
3. Create new venv with correct Python: `python3.8 -m venv venv`

### Issue 6: CORS Errors in Frontend

**Error:** `CORS policy: No 'Access-Control-Allow-Origin'`

**Solution:**
1. Check backend is running
2. Verify frontend URL in `backend/.env`:
   ```
   CORS_ORIGINS=http://localhost:3000,http://localhost:5173,http://localhost:5174
   ```
3. Restart backend after changes

## Production Deployment Considerations

For production use, consider:

1. **Database**: Switch to PostgreSQL or MySQL
2. **Security**: 
   - Add authentication/authorization
   - Use HTTPS
   - Set proper CORS origins
   - Add rate limiting
3. **Performance**:
   - Use production ASGI server (gunicorn)
   - Enable caching
   - Optimize database queries
4. **Monitoring**:
   - Add logging
   - Set up error tracking
   - Monitor performance metrics

## Stopping the Server

Press `Ctrl+C` in the terminal where server is running.

## File Structure

```
backend/
├── app/
│   ├── __init__.py
│   ├── main.py              # Main application
│   ├── config.py            # Configuration
│   ├── database.py          # Database setup
│   ├── schemas.py           # API schemas
│   ├── models/              # Database models
│   │   ├── email.py
│   │   └── quote.py
│   ├── routes/              # API endpoints
│   │   ├── emails.py
│   │   ├── quotes.py
│   │   └── dashboard.py
│   └── services/            # Business logic
│       ├── email_processor.py
│       ├── quote_generator.py
│       └── pdf_generator.py
├── utils/
│   └── load_mock_data.py    # Sample data loader
├── requirements.txt          # Python dependencies
├── run.py                   # Startup script
├── README.md                # Detailed documentation
├── QUICKSTART.md            # Quick setup guide
└── .env.example             # Environment template
```

## Getting Help

1. **API Documentation**: http://localhost:8000/docs
2. **README**: See `backend/README.md` for detailed docs
3. **Quickstart**: See `backend/QUICKSTART.md` for quick setup
4. **Check Logs**: Server logs appear in the terminal

## Summary - Quick Commands

```bash
# Complete setup (first time)
cd backend
python3 -m venv venv
source venv/bin/activate  # or venv\Scripts\activate on Windows
pip install -r requirements.txt

# Start server
python run.py

# Load sample data (in new terminal)
cd backend
source venv/bin/activate  # or venv\Scripts\activate on Windows
python utils/load_mock_data.py

# Test system
# Open browser: http://localhost:8000/docs

# Stop server
# Press Ctrl+C
```

---

## Success Checklist

- [ ] Python 3.8+ installed
- [ ] Virtual environment created and activated
- [ ] Dependencies installed (`pip install -r requirements.txt`)
- [ ] Server starts without errors
- [ ] Can access http://localhost:8000/docs
- [ ] Mock data loaded successfully
- [ ] Can list emails at /emails/
- [ ] Can analyze emails
- [ ] Can generate quotes
- [ ] Can download PDF quotes
- [ ] Dashboard stats showing correct numbers

**If all items checked, your system is fully operational! 🚀**

---

**Need immediate help?**
- Check server logs in terminal
- Review README.md for detailed documentation
- Ensure virtual environment is activated
- Verify all dependencies installed correctly
