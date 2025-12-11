# Integration Testing Guide

This guide helps you verify that the frontend-backend integration is working correctly.

## Pre-Test Checklist

### Backend Prerequisites

- [ ] Python 3.9+ installed
- [ ] PostgreSQL 12+ installed and running
- [ ] Azure OpenAI credentials (optional, for AI features)
- [ ] Backend dependencies installed (`pip install -r requirements.txt`)
- [ ] `.env` file configured in `backend/` directory
- [ ] Database schemas loaded

### Frontend Prerequisites

- [ ] Node.js 16+ installed
- [ ] npm or yarn package manager
- [ ] Frontend dependencies installed (`npm install`)
- [ ] `.env` file exists (can be empty for local dev)

## Test Scenarios

### Scenario 1: Verify Individual Services

#### Test Backend Standalone

```bash
cd backend

# Create virtual environment
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Configure environment
cp .env.example .env
# Edit .env with your settings (see Configuration section below)

# Start backend
python -m app.main
```

**Expected Output:**
```
INFO:     Started server process [xxxxx]
INFO:     Waiting for application startup.
INFO:     Starting Email Summarization & Quote Generation API v1.0.0
INFO:     Environment: development
INFO:     Application startup complete.
INFO:     Uvicorn running on http://0.0.0.0:8000
```

**Verify:**
1. Open http://localhost:8000 in browser
   - Should show: `{"name":"Email Summarization & Quote Generation API","version":"1.0.0",...}`

2. Open http://localhost:8000/health
   - Should show: `{"status":"healthy",...}`

3. Open http://localhost:8000/docs
   - Should show Swagger UI with API documentation

#### Test Frontend Standalone

```bash
cd frontend

# Install dependencies
npm install

# Start frontend
npm run dev
```

**Expected Output:**
```
  VITE v5.4.21  ready in xxx ms

  ➜  Local:   http://localhost:3000/
  ➜  Network: use --host to expose
```

**Verify:**
1. Open http://localhost:3000 in browser
2. Should see Sales Tracker interface
3. If backend is not running, should see mock data (Innovate Corp, etc.)
4. May see error message: "Backend Error: ... Showing mock data as fallback."

### Scenario 2: Test Integration (Both Services Running)

#### Step 1: Start Backend

```bash
# Terminal 1
cd backend
source venv/bin/activate
python -m app.main
```

Wait for "Application startup complete" message.

#### Step 2: Start Frontend

```bash
# Terminal 2
cd frontend
npm run dev
```

Wait for "ready in xxx ms" message.

#### Step 3: Verify Integration

1. **Open browser to http://localhost:3000**

2. **Open DevTools (F12)**
   - Go to "Network" tab
   - Filter by "Fetch/XHR"

3. **Refresh the page**

4. **Check Network Requests**
   - Should see request to `/api/v1/emails/`
   - Status should be `200 OK` (green)
   - Preview should show JSON array of email threads

5. **Check Console**
   - Should NOT see CORS errors
   - Should NOT see "Backend Error" message (unless backend has no data)
   - May see logs from useEmailData hook

6. **Check UI**
   - "Opportunities" tab should show data from backend
   - If backend has data, should see email thread subjects as opportunity names
   - If backend has no data, may fall back to mock data

### Scenario 3: Test API Endpoints

With backend running, test endpoints using curl:

```bash
# Health check
curl http://localhost:8000/health

# Expected: {"status":"healthy","version":"1.0.0",...}

# List emails
curl http://localhost:8000/api/v1/emails/

# Expected: [] (empty array if no data) or array of email threads

# Get specific thread (if you have thread ID 1)
curl http://localhost:8000/api/v1/emails/1

# Expected: Thread details or 404 error
```

### Scenario 4: Test with Sample Data

If your backend has sample data loaded:

```bash
# Load sample data (if available)
cd backend
psql -U postgres -d hackathon_db -f sample_data.sql
```

Then:

1. Restart backend (to refresh any caches)
2. Refresh frontend page
3. Should see opportunities populated from database
4. Click on an opportunity to see details
5. Switch to "Clients" tab to see client data

### Scenario 5: Test Error Handling

#### Backend Offline

1. Stop backend server (Ctrl+C in Terminal 1)
2. Keep frontend running
3. Refresh browser at http://localhost:3000
4. Should see:
   - Error message at top: "Backend Error: Failed to fetch. Showing mock data as fallback."
   - Mock data displayed (Innovate Corp, Quantum Solutions, etc.)
   - Application still functional

#### Backend Returns Error

With backend running but database disconnected:

1. Should see "degraded" status in health check
2. Frontend should handle gracefully
3. Error messages should be user-friendly

## Configuration for Testing

### Minimal Backend .env

For testing without full setup:

```bash
# Minimal config - no database or AI
APP_ENV=development
DEBUG=True
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:5173

# Optional - leave empty to skip database
DATABASE_HOST=localhost
DATABASE_NAME=hackathon_db
DATABASE_USER=postgres
DATABASE_PASSWORD=postgres

# Optional - leave empty to skip AI features
AZURE_OPENAI_ENDPOINT=
AZURE_OPENAI_API_KEY=
```

### Frontend .env

```bash
# Empty for local development (uses proxy)
VITE_API_BASE_URL=
```

## Expected Test Results

### ✅ Success Indicators

1. **Backend**
   - Starts without errors
   - `/health` returns `{"status":"healthy"}`
   - `/docs` loads Swagger UI
   - CORS headers include `http://localhost:3000`

2. **Frontend**
   - Builds without TypeScript errors
   - Starts on port 3000
   - Network requests to `/api/v1/emails/` succeed
   - No CORS errors in console
   - Data displays (from backend or fallback)

3. **Integration**
   - Vite proxy forwards `/api` requests to backend
   - API responses display in Network tab
   - Loading states show briefly
   - Data transforms correctly (threads → opportunities)

### ❌ Failure Indicators

1. **Backend Issues**
   - Import errors → Missing dependencies
   - Database errors → PostgreSQL not running or misconfigured
   - Port 8000 already in use → Another service running

2. **Frontend Issues**
   - TypeScript errors → Missing types or dependencies
   - Build fails → Check Node version and dependencies
   - Port 3000 already in use → Change port in vite.config.ts

3. **Integration Issues**
   - CORS errors → Backend ALLOWED_ORIGINS not set
   - 404 on API calls → Vite proxy misconfigured
   - Connection refused → Backend not running

## Troubleshooting

### Backend won't start

```bash
# Check Python version
python --version  # Should be 3.9+

# Reinstall dependencies
pip install -r requirements.txt --force-reinstall

# Check if port is in use
lsof -i :8000  # macOS/Linux
netstat -ano | findstr :8000  # Windows
```

### Frontend won't start

```bash
# Check Node version
node --version  # Should be 16+

# Clear and reinstall
rm -rf node_modules package-lock.json
npm install

# Check port
lsof -i :3000  # macOS/Linux
netstat -ano | findstr :3000  # Windows
```

### Integration not working

```bash
# Verify backend is accessible
curl http://localhost:8000/health

# Check Vite proxy in vite.config.ts
# Should have: proxy: { '/api': { target: 'http://localhost:8000' } }

# Check backend CORS
# .env should have: ALLOWED_ORIGINS=http://localhost:3000

# Clear browser cache
# Hard refresh: Ctrl+Shift+R (Chrome/Firefox)
```

## Performance Testing

### Check API Response Times

With both services running:

```bash
# Measure response time
time curl http://localhost:8000/api/v1/emails/

# Should be < 1 second for small datasets
```

### Check Frontend Load Time

1. Open DevTools → Network tab
2. Disable cache (checkbox at top)
3. Refresh page
4. Check "Finish" time at bottom
5. Should be < 3 seconds for initial load

## Next Steps After Testing

Once integration is verified:

1. **Add Sample Data**: Load realistic test data into database
2. **Test Quote Generation**: Add UI button to generate quotes
3. **Test PDF Download**: Verify PDF generation works
4. **Add Error Boundaries**: Improve error handling UI
5. **Add Loading Indicators**: Better UX during API calls
6. **Add Caching**: Implement React Query or SWR

## Automated Testing Script

Save as `test_integration.sh`:

```bash
#!/bin/bash

echo "Testing Backend..."
curl -s http://localhost:8000/health | grep -q "healthy" && echo "✅ Backend healthy" || echo "❌ Backend down"

echo "Testing Frontend..."
curl -s http://localhost:3000 | grep -q "root" && echo "✅ Frontend serving" || echo "❌ Frontend down"

echo "Testing API via Proxy..."
curl -s http://localhost:3000/api/v1/emails/ > /dev/null && echo "✅ Proxy working" || echo "❌ Proxy failed"

echo "Done!"
```

Run with: `chmod +x test_integration.sh && ./test_integration.sh`

## Support

If tests fail, check:
1. This testing guide
2. [README_INTEGRATION.md](./README_INTEGRATION.md)
3. Backend logs in terminal
4. Browser console errors
5. Network tab in DevTools
