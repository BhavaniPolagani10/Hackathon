# Frontend-Backend Integration

This document explains how the frontend integrates with the backend API.

## Overview

The frontend React application integrates with the FastAPI backend to:
- Fetch email conversation threads
- Display opportunities based on email data
- Show client information with conversation history
- Generate quotes from email threads
- Download PDF quotes

## Architecture

### API Service Layer

The integration uses a layered architecture:

1. **Configuration** (`src/config/api.ts`)
   - API base URL configuration
   - Environment variable support
   - URL construction utilities

2. **API Client** (`src/services/api.ts`)
   - Generic `fetchApi` function for HTTP requests
   - Error handling with `ApiError` class
   - JSON request/response handling

3. **Domain Services**
   - `emailService.ts` - Email thread operations
   - `quoteService.ts` - Quote generation operations

4. **Data Transformation** (`src/utils/dataTransform.ts`)
   - Converts backend data structures to frontend models
   - Maps email threads to opportunities
   - Maps threads to clients with conversations

5. **React Hooks** (`src/hooks/useEmailData.ts`)
   - `useEmailData` - Fetches and transforms email data
   - `useQuoteGeneration` - Handles quote generation

## Development Setup

### Prerequisites

1. **Backend Running**: Start the backend server first
   ```bash
   cd backend
   python -m app.main
   ```
   Backend should be running on `http://localhost:8000`

2. **Frontend Development Server**
   ```bash
   cd frontend
   npm install
   npm run dev
   ```
   Frontend will run on `http://localhost:3000`

### Vite Proxy Configuration

The frontend uses Vite's proxy feature to avoid CORS issues during development:

```typescript
// vite.config.ts
server: {
  proxy: {
    '/api': {
      target: 'http://localhost:8000',
      changeOrigin: true,
    },
  },
}
```

This means:
- Frontend requests to `/api/v1/emails/` are proxied to `http://localhost:8000/api/v1/emails/`
- No CORS configuration needed in development
- No need to set `VITE_API_BASE_URL` for local development

## Environment Variables

Create a `.env` file in the `frontend` directory:

```bash
# Leave empty for local development (uses Vite proxy)
VITE_API_BASE_URL=

# For production, set to backend URL
# VITE_API_BASE_URL=https://api.yourapp.com
```

## Data Flow

### Opportunities View

1. `SalesTrackerPage` uses `useEmailData` hook
2. Hook calls `emailService.getThreads()` to fetch email threads
3. Each thread is transformed to an `Opportunity` via `transformThreadToOpportunity`
4. Opportunities are displayed in the sidebar and detail view

### Clients View

1. `SalesTrackerPage` uses `useEmailData` hook
2. Hook calls `emailService.getThread(id)` for detailed thread data
3. Thread with messages is transformed to `Client` via `transformThreadToClient`
4. Client data includes conversations from email messages

### Quote Generation

1. User clicks "Generate Quote" button (can be added to UI)
2. `useQuoteGeneration` hook is called with `threadId`
3. Hook calls `quoteService.generateQuote(threadId)`
4. Backend processes:
   - Summarizes email using Azure OpenAI
   - Extracts product requirements
   - Fetches pricing from PostgreSQL
   - Generates quote with line items
5. Quote data is returned and displayed

## API Endpoints Used

### Email Endpoints

- `GET /api/v1/emails/` - List all email threads
- `GET /api/v1/emails/{thread_id}` - Get thread with messages
- `POST /api/v1/emails/{thread_id}/summarize` - AI-powered summarization

### Quote Endpoints

- `POST /api/v1/quotes/generate?thread_id={id}` - Generate quote
- `GET /api/v1/quotes/{quote_number}/pdf?thread_id={id}` - Download PDF
- `GET /api/v1/quotes/pricing/{product_code}` - Get product pricing

## Error Handling

The integration includes robust error handling:

1. **Network Errors**: Caught and displayed to user
2. **API Errors**: Custom `ApiError` class with status codes
3. **Fallback to Mock Data**: If backend is unavailable, shows mock data
4. **Loading States**: Shows loading indicator while fetching

## Testing the Integration

### 1. Start Both Servers

```bash
# Terminal 1 - Backend
cd backend
python -m app.main

# Terminal 2 - Frontend
cd frontend
npm run dev
```

### 2. Verify Backend is Running

Visit `http://localhost:8000/health` - should show:
```json
{
  "status": "healthy",
  "version": "1.0.0",
  "database": "healthy"
}
```

### 3. Verify Frontend Integration

1. Open `http://localhost:3000` in browser
2. Open browser DevTools (F12) and check Network tab
3. Should see API requests to `/api/v1/emails/`
4. Data should load from backend (check for loading message)

### 4. Test with Mock Data

If you see "Backend Error" message but app still works, it's using fallback mock data. This is expected when backend is not running.

## Production Deployment

### Frontend Configuration

1. Set environment variable:
   ```bash
   VITE_API_BASE_URL=https://your-backend-api.com
   ```

2. Build frontend:
   ```bash
   npm run build
   ```

3. The build will use the production API URL instead of proxy

### CORS Configuration

Backend must allow frontend origin in production:

```python
# backend/app/config/settings.py
ALLOWED_ORIGINS = "https://yourfrontend.com"
```

## Troubleshooting

### Backend Not Connecting

1. Check if backend is running: `curl http://localhost:8000/health`
2. Check Vite proxy logs in terminal
3. Check browser console for errors
4. Verify `.env` file is not overriding API URL

### CORS Errors

1. Should not occur with Vite proxy in development
2. In production, verify backend CORS settings
3. Check `ALLOWED_ORIGINS` in backend settings

### Data Not Loading

1. Check browser Network tab for failed requests
2. Verify backend has data (visit `/api/v1/emails/` directly)
3. Check if database is populated with sample data
4. Look for errors in backend logs

### Mock Data vs Backend Data

- If you see mock data (Innovate Corp, etc.), backend integration is not active
- Check for error message at top of page
- Verify backend is running and accessible
- Check browser console for error details

## Future Enhancements

Potential improvements to the integration:

1. **Real-time Updates**: WebSocket connection for live data
2. **Caching**: Use React Query or SWR for better caching
3. **Optimistic Updates**: Update UI before API confirms
4. **Pagination**: Handle large datasets efficiently
5. **Search/Filter**: Add search across email threads
6. **Quote Actions**: Add UI for generating and downloading quotes
7. **Error Boundaries**: Better error handling UI
8. **Retry Logic**: Automatic retry for failed requests
