# Quick Reference Guide

## 🚀 Getting Started in 3 Steps

### Step 1: Start the Backend (Terminal 1)

```bash
cd backend
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env
# Edit .env with your settings
python -m app.main
```

**Expected output:**
```
INFO:     Application startup complete.
INFO:     Uvicorn running on http://0.0.0.0:8000
```

### Step 2: Start the Frontend (Terminal 2)

```bash
cd frontend
npm install
npm run dev
```

**Expected output:**
```
VITE v5.4.21  ready in xxx ms
➜  Local:   http://localhost:3000/
```

### Step 3: Open Your Browser

Navigate to: **http://localhost:3000**

---

## 📋 Quick Commands

### Check if everything is running:
```bash
# Check backend health
curl http://localhost:8000/health

# Check frontend
curl http://localhost:3000

# List email threads via API
curl http://localhost:8000/api/v1/emails/
```

### Start both services with one command:
```bash
./start.sh
```

### Build for production:
```bash
# Frontend
cd frontend
VITE_API_BASE_URL=https://your-api.com npm run build

# Backend
cd backend
pip install -r requirements.txt
# Set production .env
```

---

## 🎯 What to Expect

### With Backend Running ✅
- Opportunities tab shows data from email threads
- Clients tab shows conversation history
- Data loads from PostgreSQL database
- No error messages

### Without Backend Running ⚠️
- Shows error message: "Backend Error: ... Showing mock data as fallback"
- Displays mock data (Innovate Corp, Quantum Solutions, etc.)
- App still works, just with sample data

---

## 📁 Key Files Reference

### Frontend Files
```
frontend/
├── src/
│   ├── config/api.ts          ← API configuration
│   ├── services/
│   │   ├── emailService.ts    ← Email API calls
│   │   └── quoteService.ts    ← Quote API calls
│   ├── hooks/
│   │   └── useEmailData.ts    ← Data fetching hook
│   ├── utils/
│   │   └── dataTransform.ts   ← Backend→Frontend mapping
│   └── pages/
│       └── SalesTrackerPage.tsx ← Main page (updated)
├── vite.config.ts             ← Proxy configuration
└── .env                       ← Environment variables
```

### Backend Files
```
backend/
├── app/
│   ├── api/
│   │   ├── emails.py          ← Email endpoints
│   │   └── quotes.py          ← Quote endpoints
│   ├── services/
│   │   ├── email_service.py   ← Email logic
│   │   └── quote_service.py   ← Quote logic
│   └── main.py                ← FastAPI app
└── .env                       ← Configuration
```

---

## 🔧 Configuration Files

### Backend .env
```bash
# Required for database
DATABASE_HOST=localhost
DATABASE_NAME=hackathon_db
DATABASE_USER=postgres
DATABASE_PASSWORD=your_password

# Required for CORS
ALLOWED_ORIGINS=http://localhost:3000

# Optional for AI features
AZURE_OPENAI_ENDPOINT=https://...
AZURE_OPENAI_API_KEY=...
```

### Frontend .env
```bash
# Empty for local dev (uses Vite proxy)
VITE_API_BASE_URL=

# For production
# VITE_API_BASE_URL=https://api.yourapp.com
```

---

## 🐛 Common Issues & Solutions

### ❌ "Module not found" in backend
```bash
cd backend
pip install -r requirements.txt
```

### ❌ "Port already in use"
```bash
# Find and kill process on port 8000
lsof -i :8000          # macOS/Linux
netstat -ano | findstr :8000  # Windows
```

### ❌ CORS errors in browser
```bash
# Check backend .env has:
ALLOWED_ORIGINS=http://localhost:3000
```

### ❌ Frontend shows error message
```bash
# Backend is not running. Start it:
cd backend
python -m app.main
```

---

## 📊 API Endpoints

### Emails
- `GET /api/v1/emails/` - List threads
- `GET /api/v1/emails/{id}` - Get thread details
- `POST /api/v1/emails/{id}/summarize` - AI summary

### Quotes
- `POST /api/v1/quotes/generate?thread_id={id}` - Generate quote
- `GET /api/v1/quotes/{number}/pdf?thread_id={id}` - Download PDF

### Health
- `GET /health` - Check backend status

---

## 📚 Documentation

| Document | Purpose |
|----------|---------|
| README.md | Project overview & quick start |
| README_INTEGRATION.md | Detailed integration guide |
| TESTING.md | Testing procedures |
| ARCHITECTURE.md | System architecture |
| INTEGRATION_SUMMARY.md | Integration summary |
| frontend/INTEGRATION.md | Frontend details |

---

## ✅ Success Checklist

Before reporting issues, verify:

- [ ] Backend running on port 8000
- [ ] Frontend running on port 3000
- [ ] PostgreSQL database running
- [ ] `.env` files configured
- [ ] Dependencies installed (pip/npm)
- [ ] Browser console shows no CORS errors
- [ ] Network tab shows API calls to `/api/v1/...`

---

## 🎓 How It Works

```
┌──────────────┐
│   Browser    │
│  localhost:  │
│     3000     │
└──────┬───────┘
       │
       │ /api/v1/emails/
       ▼
┌──────────────┐
│ Vite Proxy   │
│  (Dev Mode)  │
└──────┬───────┘
       │
       │ Forwards to localhost:8000
       ▼
┌──────────────┐
│   FastAPI    │
│  Backend     │
│  Port 8000   │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│  PostgreSQL  │
│   Database   │
└──────────────┘
```

---

## 🎉 Quick Test

Once both services are running:

1. Open http://localhost:3000
2. Open DevTools (F12)
3. Go to Network tab
4. Refresh page
5. Look for request to `/api/v1/emails/`
6. If status is 200 → ✅ Integration working!
7. If status is error → Check backend is running

---

## 💡 Pro Tips

1. **Use the start script**: `./start.sh` starts everything
2. **Check logs**: Backend errors show in Terminal 1
3. **Use Swagger UI**: http://localhost:8000/docs for API testing
4. **Mock data fallback**: App works even if backend is down
5. **Hot reload**: Changes auto-refresh in both services

---

## 🚀 Next Steps

1. ✅ Integration complete
2. ⏳ Test with real data (load sample_data.sql)
3. 🎯 Add quote generation button (future)
4. 📄 Add PDF download (future)
5. 🔄 Add real-time updates (future)

---

## 📞 Need Help?

1. Check the error message in browser
2. Read the documentation files
3. Verify environment configuration
4. Check that all services are running
5. Review the TESTING.md file

---

**Integration Status: ✅ COMPLETE**

The frontend and backend are fully integrated and ready to use!
