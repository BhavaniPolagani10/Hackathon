# Quick Start Guide - 5 Minutes Setup

## Prerequisites
- Python 3.8+ installed
- pip installed

## Step-by-Step Instructions

### 1. Open Terminal/Command Prompt

Navigate to the backend directory:
```bash
cd backend
```

### 2. Create Virtual Environment

**macOS/Linux:**
```bash
python3 -m venv venv
source venv/bin/activate
```

**Windows:**
```bash
python -m venv venv
venv\Scripts\activate
```

You should see `(venv)` in your terminal prompt.

### 3. Install Dependencies

```bash
pip install -r requirements.txt
```

Wait for all packages to install (takes 2-3 minutes).

### 4. Start the Server

```bash
python run.py
```

You should see:
```
INFO:     Started server process
INFO:     Uvicorn running on http://0.0.0.0:8000
```

### 5. Load Sample Data (Optional)

Open a NEW terminal window, activate venv again, then:

```bash
cd backend
source venv/bin/activate  # or venv\Scripts\activate on Windows
python utils/load_mock_data.py
```

### 6. Test the API

Open your browser and visit:
- **API Docs**: http://localhost:8000/docs
- **Health Check**: http://localhost:8000/health

## Quick Test

### Via Browser (Swagger UI)
1. Go to http://localhost:8000/docs
2. Try `GET /emails/` - Click "Try it out" → "Execute"
3. Try `GET /dashboard/stats` - See statistics

### Via Command Line (curl)

**Check health:**
```bash
curl http://localhost:8000/health
```

**Get emails:**
```bash
curl http://localhost:8000/emails/
```

**Get dashboard stats:**
```bash
curl http://localhost:8000/dashboard/stats
```

## Complete Workflow Test

### 1. Create an email
```bash
curl -X POST "http://localhost:8000/emails/" \
  -H "Content-Type: application/json" \
  -d '{
    "subject": "Need 2 Excavators",
    "from_email": "test@example.com",
    "from_name": "Test Customer",
    "to_email": "sales@company.com",
    "body": "We need 2 CAT 320 excavators urgently for our construction site in New York. Deadline is next week."
  }'
```

### 2. Get the email (use ID from response, e.g., 1)
```bash
curl http://localhost:8000/emails/1
```

### 3. Generate quote from email
```bash
curl -X POST http://localhost:8000/quotes/from-email/1
```

### 4. Download PDF (use quote ID from response, e.g., 1)
Open in browser:
```
http://localhost:8000/quotes/1/pdf
```

## Troubleshooting

### "pip not found"
Install pip:
```bash
# macOS/Linux
python3 -m ensurepip

# Windows
python -m ensurepip
```

### "Port 8000 already in use"
Use a different port:
```bash
uvicorn app.main:app --port 8001
```

### "Module not found" errors
Make sure you're in the virtual environment:
```bash
# You should see (venv) in your prompt
# If not, activate it:
source venv/bin/activate  # macOS/Linux
# or
venv\Scripts\activate  # Windows
```

### Database errors
Delete the database and restart:
```bash
rm app.db
python run.py
```

## Next Steps

1. ✅ Server is running
2. ✅ Load mock data (optional)
3. 📖 Read full README.md for detailed documentation
4. 🎨 Connect with frontend (if available)
5. 🧪 Explore API at http://localhost:8000/docs

## Stopping the Server

Press `Ctrl+C` in the terminal where the server is running.

## Need Help?

- API Documentation: http://localhost:8000/docs
- Full README: See `README.md`
- Check server logs in terminal for errors

---

**That's it! You're ready to go! 🚀**
