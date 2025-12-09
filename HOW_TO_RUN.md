# How to Run the Email Quote Management System

## ⚡ Quick Start (5 Minutes)

### Step 1: Prerequisites Check
Ensure you have:
- Python 3.8 or higher: `python3 --version`
- pip installed: `pip --version`

### Step 2: Navigate to Backend
```bash
cd backend
```

### Step 3: Setup Virtual Environment
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

You should see `(venv)` in your terminal.

### Step 4: Install Dependencies
```bash
pip install -r requirements.txt
```

Wait 1-2 minutes for installation to complete.

### Step 5: Start the Server
```bash
python run.py
```

**Expected Output:**
```
INFO:     Uvicorn running on http://0.0.0.0:8000 (Press CTRL+C to quit)
INFO:     Application startup complete.
```

✅ **Server is now running!**

### Step 6: Load Sample Data (Optional but Recommended)

Open a **NEW terminal window**, then:

```bash
cd backend
source venv/bin/activate  # or venv\Scripts\activate on Windows
python utils/load_mock_data.py
```

**Expected Output:**
```
Loaded 6 mock emails successfully!
```

### Step 7: Test the System

**Option A: Web Browser (Easiest)**
1. Open: http://localhost:8000/docs
2. Try these endpoints:
   - `GET /health` - Check server health
   - `GET /emails/` - List all emails
   - `GET /dashboard/stats` - View statistics

**Option B: Command Line**
```bash
# Check health
curl http://localhost:8000/health

# Get dashboard stats
curl http://localhost:8000/dashboard/stats

# List emails
curl http://localhost:8000/emails/
```

## 🎯 Complete Workflow Example

### 1. Create an Email
```bash
curl -X POST "http://localhost:8000/emails/" \
  -H "Content-Type: application/json" \
  -d '{
    "subject": "Need 3 Excavators",
    "from_email": "buyer@company.com",
    "from_name": "John Buyer",
    "to_email": "sales@dealer.com",
    "to_name": "Sales Team",
    "body": "We need 3 CAT 320 excavators urgently for our project in NYC. Delivery needed by end of month."
  }'
```

**Note the `id` from the response (e.g., 7)**

### 2. View Email Analysis
```bash
curl http://localhost:8000/emails/7
```

The email is automatically analyzed!

### 3. Generate Quote
```bash
curl -X POST http://localhost:8000/quotes/from-email/7
```

**Note the quote `id` from response (e.g., 5)**

### 4. Download PDF Quote
Open in browser:
```
http://localhost:8000/quotes/5/pdf
```

Or download via command line:
```bash
curl http://localhost:8000/quotes/5/pdf --output quote.pdf
```

### 5. Check Dashboard
```bash
curl http://localhost:8000/dashboard/stats
```

## 📖 Available Endpoints

### Email Endpoints
- `POST /emails/` - Create new email
- `GET /emails/` - List all emails
- `GET /emails/{id}` - Get specific email
- `GET /emails/{id}/summary` - Get email summary
- `POST /emails/{id}/analyze` - Re-analyze email
- `DELETE /emails/{id}` - Delete email

### Quote Endpoints
- `POST /quotes/from-email/{id}` - Generate quote from email
- `GET /quotes/` - List all quotes
- `GET /quotes/{id}` - Get specific quote
- `GET /quotes/{id}/pdf` - Download quote as PDF
- `PUT /quotes/{id}/status` - Update quote status
- `DELETE /quotes/{id}` - Delete quote

### Dashboard
- `GET /dashboard/stats` - Get system statistics

## 🛑 Stopping the Server

Press `Ctrl+C` in the terminal where the server is running.

## 🔧 Troubleshooting

### Problem: "Port 8000 already in use"
**Solution:**
```bash
# Use different port
uvicorn app.main:app --port 8001
```

### Problem: "Module not found"
**Solution:**
```bash
# Make sure venv is activated (you should see (venv) in prompt)
source venv/bin/activate  # macOS/Linux
venv\Scripts\activate     # Windows

# Reinstall dependencies
pip install -r requirements.txt
```

### Problem: "Database locked"
**Solution:**
```bash
# Stop server (Ctrl+C)
# Delete database
rm app.db
# Restart
python run.py
```

### Problem: "Python version too old"
**Solution:**
- Install Python 3.8 or higher from https://www.python.org/
- Verify: `python3 --version`

## ✅ Success Checklist

- [ ] Python 3.8+ installed
- [ ] Virtual environment created
- [ ] Dependencies installed
- [ ] Server starts without errors
- [ ] Can access http://localhost:8000/docs
- [ ] Mock data loaded (optional but helpful)
- [ ] Can list emails
- [ ] Can generate quotes
- [ ] Can download PDFs

If all checked, you're ready to go! 🚀

## 📚 Additional Resources

- **Full Documentation**: See `backend/README.md`
- **Quick Setup**: See `backend/QUICKSTART.md`
- **Deployment Guide**: See `DEPLOYMENT_GUIDE.md`
- **Implementation Summary**: See `BACKEND_IMPLEMENTATION_SUMMARY.md`

## 🎓 What the System Does

### Email Processing
- Ingests email conversations
- Extracts customer information (name, company, email)
- Identifies products requested (excavators, loaders, etc.)
- Determines quantities
- Assesses urgency (urgent/high/medium/low)
- Finds deadlines and shipping addresses
- Generates summaries

### Quote Generation
- Auto-calculates pricing based on equipment type
- Applies volume discounts (5% for 3+, 10% for 5+ units)
- Calculates tax (8%) and shipping costs
- Estimates delivery times based on urgency
- Generates unique quote numbers
- Creates professional PDF documents

### API Features
- RESTful endpoints
- Interactive documentation
- Input validation
- Error handling
- CORS support for frontend

## 🎯 Key Features

✅ **Smart Email Analysis** - Automatically extracts all key information
✅ **Dynamic Pricing** - Volume discounts and market variation
✅ **Professional PDFs** - 2-page formatted quote documents
✅ **REST API** - 15+ endpoints with Swagger documentation
✅ **Dashboard** - Real-time statistics
✅ **Mock Data** - Sample emails for immediate testing

## 🚀 Next Steps

1. ✅ Server is running
2. ✅ Load mock data
3. 📖 Explore API at http://localhost:8000/docs
4. 🧪 Try creating emails and generating quotes
5. 📄 Download PDF quotes
6. 🎨 Integrate with frontend (if available)

---

## Quick Command Reference

```bash
# Setup (one time)
cd backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Run server
python run.py

# Load data (in new terminal)
python utils/load_mock_data.py

# Test endpoints
curl http://localhost:8000/health
curl http://localhost:8000/dashboard/stats
curl http://localhost:8000/emails/

# Stop server
# Press Ctrl+C
```

---

**You're all set! The system is ready to use! 🎉**

For detailed information, see the comprehensive documentation files in the backend folder.
