# Frontend-Backend Integration Guide

This guide explains how to run the integrated application with both frontend and backend.

## Quick Start

### 1. Start the Backend (Terminal 1)

```bash
cd backend

# Create virtual environment (first time only)
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies (first time only)
pip install -r requirements.txt

# Set up environment variables
cp .env.example .env
# Edit .env with your database and Azure OpenAI credentials

# Start the backend server
python -m app.main
```

Backend will be available at: `http://localhost:8000`
- API Documentation: `http://localhost:8000/docs`
- Health Check: `http://localhost:8000/health`

### 2. Start the Frontend (Terminal 2)

```bash
cd frontend

# Install dependencies (first time only)
npm install

# Start the development server
npm run dev
```

Frontend will be available at: `http://localhost:3000`

### 3. Access the Application

Open your browser and navigate to `http://localhost:3000`

## How It Works

### Architecture Overview

```
┌─────────────────┐         ┌──────────────────┐         ┌──────────────┐
│                 │         │                  │         │              │
│  React Frontend │◄────────┤   Vite Proxy     │◄────────┤   FastAPI    │
│  (Port 3000)    │         │   /api → :8000   │         │   Backend    │
│                 │         │                  │         │  (Port 8000) │
└─────────────────┘         └──────────────────┘         └──────────────┘
                                                                 │
                                                                 │
                                                                 ▼
                                                          ┌──────────────┐
                                                          │  PostgreSQL  │
                                                          │   Database   │
                                                          └──────────────┘
```

### Key Features

1. **Email Thread Management**
   - Frontend fetches email threads from backend API
   - Displays as "Opportunities" in the UI
   - Shows conversation history in "Clients" view

2. **Data Transformation**
   - Backend email threads → Frontend opportunities
   - Backend messages → Frontend conversations
   - Automatic mapping of status, timestamps, and metadata

3. **Graceful Fallback**
   - If backend is unavailable, shows mock data
   - Displays error message when backend fails
   - No loss of UI functionality

4. **Quote Generation** (Backend Ready)
   - Backend can generate quotes from email threads
   - Uses Azure OpenAI for intelligent parsing
   - Fetches pricing from PostgreSQL database
   - Generates PDF quotes

## API Integration Details

### Frontend Services

The frontend has dedicated service layers:

**Email Service** (`src/services/emailService.ts`)
- `getThreads()` - Fetch all email threads
- `getThread(id)` - Get thread with messages
- `summarizeThread(id)` - AI-powered summarization

**Quote Service** (`src/services/quoteService.ts`)
- `generateQuote(threadId)` - Generate quote from thread
- `getProductPricing(code)` - Get product pricing
- `getQuotePdfUrl()` - Generate PDF download URL

### Data Flow Example

1. **User opens Opportunities view**
   ```
   SalesTrackerPage → useEmailData hook → emailService.getThreads()
   → GET /api/v1/emails/ → Backend returns threads
   → transformThreadToOpportunity() → Display in UI
   ```

2. **User opens Clients view**
   ```
   SalesTrackerPage → useEmailData hook → emailService.getThread(id)
   → GET /api/v1/emails/{id} → Backend returns thread with messages
   → transformThreadToClient() → Display client with conversations
   ```

## Environment Configuration

### Backend (.env)

```bash
# Azure OpenAI Configuration
AZURE_OPENAI_ENDPOINT=https://your-resource.openai.azure.com/
AZURE_OPENAI_API_KEY=your-api-key-here
AZURE_OPENAI_DEPLOYMENT_NAME=gpt-4o
AZURE_OPENAI_API_VERSION=2024-02-15-preview

# PostgreSQL Database
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_NAME=hackathon_db
DATABASE_USER=postgres
DATABASE_PASSWORD=your_password

# Application
APP_ENV=development
DEBUG=True
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:5173
```

### Frontend (.env)

```bash
# Leave empty for local development (uses Vite proxy)
VITE_API_BASE_URL=

# For production deployment
# VITE_API_BASE_URL=https://api.yourapp.com
```

## Testing the Integration

### 1. Verify Backend Health

```bash
curl http://localhost:8000/health
```

Expected response:
```json
{
  "status": "healthy",
  "version": "1.0.0",
  "database": "healthy"
}
```

### 2. Test Email Endpoint

```bash
curl http://localhost:8000/api/v1/emails/
```

Should return array of email threads (empty if no data loaded).

### 3. Check Frontend Integration

1. Open browser DevTools (F12)
2. Go to Network tab
3. Navigate to `http://localhost:3000`
4. Look for API calls to `/api/v1/emails/`
5. Check Console for any errors

### 4. Load Sample Data (Optional)

If you want to test with sample data:

```bash
cd backend
psql -U postgres -d hackathon_db -f sample_data.sql
```

Then refresh the frontend to see the data.

## Troubleshooting

### Backend Not Starting

**Issue**: `ModuleNotFoundError`
```bash
# Solution: Install dependencies
cd backend
pip install -r requirements.txt
```

**Issue**: Database connection failed
```bash
# Solution: Check PostgreSQL is running
sudo systemctl status postgresql

# Or start it
sudo systemctl start postgresql
```

### Frontend Not Connecting

**Issue**: "Backend Error" message shown
```bash
# Solution 1: Verify backend is running
curl http://localhost:8000/health

# Solution 2: Check Vite proxy configuration
# Edit frontend/vite.config.ts, ensure proxy is set to localhost:8000

# Solution 3: Restart frontend dev server
cd frontend
npm run dev
```

**Issue**: CORS errors in console
```bash
# Solution: Check backend ALLOWED_ORIGINS includes http://localhost:3000
# Edit backend/.env
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:5173
```

### Build Issues

**Issue**: TypeScript errors during build
```bash
# Solution: Ensure vite-env.d.ts exists
# File: frontend/src/vite-env.d.ts should have Vite types
```

**Issue**: Module not found
```bash
# Solution: Clear node_modules and reinstall
cd frontend
rm -rf node_modules package-lock.json
npm install
```

## Development Workflow

### Making Changes

1. **Backend Changes**
   - Edit Python files in `backend/app/`
   - Uvicorn auto-reloads (if using `--reload` flag)
   - Test with `curl` or Swagger UI at `/docs`

2. **Frontend Changes**
   - Edit TypeScript/React files in `frontend/src/`
   - Vite hot-reloads automatically
   - Changes appear instantly in browser

### Adding New API Endpoints

1. **Backend**:
   ```python
   # backend/app/api/new_endpoint.py
   @router.get("/new-endpoint")
   async def new_endpoint():
       return {"data": "value"}
   ```

2. **Frontend**:
   ```typescript
   // frontend/src/services/newService.ts
   export const newService = {
     async getData() {
       return fetchApi('/new-endpoint');
     }
   };
   ```

## Production Deployment

### Backend

1. Set production environment variables
2. Disable DEBUG mode
3. Use production database
4. Configure CORS for production frontend URL

### Frontend

1. Set `VITE_API_BASE_URL` to production backend URL
2. Build: `npm run build`
3. Serve `dist/` folder with nginx or similar
4. Ensure backend CORS allows frontend domain

## Additional Resources

- Backend API Documentation: `http://localhost:8000/docs`
- Frontend Integration Guide: `frontend/INTEGRATION.md`
- Backend Setup Guide: `backend/SETUP_GUIDE.md`
- Backend Quick Start: `backend/QUICKSTART.md`

## Support

If you encounter issues:

1. Check this README
2. Review error messages in browser console
3. Check backend logs in terminal
4. Verify environment variables are set
5. Ensure all services are running

## Features Ready for Implementation

The integration provides the foundation for these features:

- [x] Display email threads as opportunities
- [x] Show client conversations
- [x] Graceful fallback to mock data
- [x] Error handling and loading states
- [ ] Generate quotes UI button
- [ ] Download PDF quotes
- [ ] Real-time data refresh
- [ ] Search and filter opportunities
- [ ] Create new email threads
- [ ] Edit opportunities

The backend supports quote generation and PDF download - these just need UI buttons added in the frontend!
