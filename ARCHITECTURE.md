# Frontend-Backend Integration Architecture

## System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           User's Browser                                │
│                                                                          │
│  ┌────────────────────────────────────────────────────────────────────┐│
│  │                    React Application (Port 3000)                    ││
│  │                                                                      ││
│  │  ┌──────────────────┐  ┌─────────────────┐  ┌──────────────────┐  ││
│  │  │  Pages/          │  │  Components/     │  │  Hooks/          │  ││
│  │  │  SalesTracker    │→ │  OpportunityList │→ │  useEmailData    │  ││
│  │  │  Page            │  │  ClientDetail    │  │                  │  ││
│  │  └──────────────────┘  └─────────────────┘  └────────┬─────────┘  ││
│  │                                                        │             ││
│  │                                                        ▼             ││
│  │                                              ┌──────────────────┐   ││
│  │                                              │  Services/       │   ││
│  │                                              │  - emailService  │   ││
│  │                                              │  - quoteService  │   ││
│  │                                              └────────┬─────────┘   ││
│  │                                                       │              ││
│  │                                                       ▼              ││
│  │                                              ┌──────────────────┐   ││
│  │                                              │  Utils/          │   ││
│  │                                              │  - fetchApi      │   ││
│  │                                              │  - dataTransform │   ││
│  │                                              └────────┬─────────┘   ││
│  └───────────────────────────────────────────────────────┼─────────────┘│
│                                                           │              │
└───────────────────────────────────────────────────────────┼──────────────┘
                                                            │
                                                            │ HTTP Request
                                                            │ /api/v1/...
                                                            ▼
                                             ┌──────────────────────────┐
                                             │   Vite Dev Server        │
                                             │   (Development Proxy)    │
                                             │                          │
                                             │   Proxies /api → :8000   │
                                             └────────────┬─────────────┘
                                                          │
                                                          ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                         FastAPI Backend (Port 8000)                     │
│                                                                          │
│  ┌────────────────────────────────────────────────────────────────────┐│
│  │                         API Layer                                   ││
│  │  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐ ││
│  │  │  /emails         │  │  /quotes         │  │  /health         │ ││
│  │  │  - GET /         │  │  - POST /generate│  │  - GET /         │ ││
│  │  │  - GET /{id}     │  │  - GET /{id}/pdf │  │                  │ ││
│  │  │  - POST /summary │  │  - GET /pricing  │  │                  │ ││
│  │  └────────┬─────────┘  └────────┬─────────┘  └──────────────────┘ ││
│  └───────────┼─────────────────────┼─────────────────────────────────┘│
│              │                     │                                   │
│              ▼                     ▼                                   │
│  ┌───────────────────────────────────────────────────────────────────┐│
│  │                        Services Layer                              ││
│  │  ┌─────────────────┐  ┌────────────────┐  ┌──────────────────┐   ││
│  │  │ email_service   │  │ quote_service  │  │ pdf_service      │   ││
│  │  │ - get_threads   │  │ - generate     │  │ - create_pdf     │   ││
│  │  │ - get_messages  │  │ - get_pricing  │  │                  │   ││
│  │  └────────┬────────┘  └────────┬───────┘  └──────────────────┘   ││
│  │           │                    │                                   ││
│  │           │                    │                                   ││
│  │           ▼                    ▼                                   ││
│  │  ┌─────────────────┐  ┌────────────────┐  ┌──────────────────┐   ││
│  │  │ azure_openai    │  │ Database Utils │  │ Models           │   ││
│  │  │ - summarize     │  │ - get_db       │  │ - EmailThread    │   ││
│  │  │ - extract_info  │  │ - queries      │  │ - Quote          │   ││
│  │  └─────────────────┘  └────────┬───────┘  └──────────────────┘   ││
│  └────────────────────────────────┼──────────────────────────────────┘│
└────────────────────────────────────┼───────────────────────────────────┘
                                     │
                                     ▼
                          ┌────────────────────┐
                          │  PostgreSQL        │
                          │  Database          │
                          │                    │
                          │  - email_threads   │
                          │  - email_messages  │
                          │  - quotes          │
                          │  - products        │
                          └────────────────────┘

                External Services:
                          │
                          ▼
                 ┌────────────────────┐
                 │  Azure OpenAI      │
                 │  GPT-4o            │
                 │                    │
                 │  - Email summary   │
                 │  - Extract products│
                 └────────────────────┘
```

## Data Flow Diagrams

### Flow 1: Loading Opportunities

```
User Opens App
     │
     ▼
React Router loads SalesTrackerPage
     │
     ▼
useEmailData hook executes
     │
     ├─────────────────────────────────────┐
     │                                     │
     ▼                                     ▼
emailService.getThreads()          (Fallback to mock data
     │                              if API fails)
     ▼
fetchApi('/api/v1/emails/')
     │
     ▼
Vite Proxy forwards to
http://localhost:8000/api/v1/emails/
     │
     ▼
FastAPI /emails/ endpoint
     │
     ▼
email_service.get_all_threads(db)
     │
     ▼
PostgreSQL Query:
SELECT * FROM email_threads
     │
     ▼
Returns: EmailThread[]
     │
     ▼
transformThreadToOpportunity()
     │
     ▼
Display as Opportunities in UI
```

### Flow 2: Generating a Quote

```
User clicks "Generate Quote"
     │
     ▼
useQuoteGeneration.generateQuote(threadId)
     │
     ▼
quoteService.generateQuote(threadId)
     │
     ▼
POST /api/v1/quotes/generate?thread_id=X
     │
     ▼
FastAPI quotes endpoint
     │
     ├──────────────────────────────┐
     │                              │
     ▼                              ▼
email_service                  quote_service
.summarize_thread()            .generate_quote()
     │                              │
     ▼                              │
azure_openai_service                │
.summarize()                        │
     │                              │
     ▼                              │
Azure OpenAI GPT-4o                 │
Analyzes email text                 │
     │                              │
     ▼                              │
Returns: EmailSummary               │
- Products requested                │
- Quantities                        │
- Shipping info                     │
     │                              │
     └──────────────┬───────────────┘
                    │
                    ▼
         quote_service.get_product_pricing()
                    │
                    ▼
         PostgreSQL: SELECT from products
                    │
                    ▼
         Calculate totals, tax, discounts
                    │
                    ▼
         Returns: QuoteWithLineItems
                    │
                    ▼
         Display quote in UI
```

### Flow 3: Error Handling

```
API Request Fails
     │
     ├─────────────────────────────────┐
     │                                 │
     ▼                                 ▼
Network Error               HTTP Error (4xx/5xx)
(Backend down)               (Bad request, etc.)
     │                                 │
     └─────────────┬───────────────────┘
                   │
                   ▼
            ApiError thrown
                   │
                   ▼
      useEmailData catches error
                   │
                   ├─────────────────┐
                   │                 │
                   ▼                 ▼
         Set error state    Use fallback data
                   │                 │
                   ▼                 ▼
         Display error     Display mock data
          message          (Innovate Corp, etc.)
                   │                 │
                   └────────┬────────┘
                            │
                            ▼
                  App remains functional
```

## Key Integration Points

### 1. Vite Proxy Configuration

**File:** `frontend/vite.config.ts`

```typescript
server: {
  proxy: {
    '/api': {
      target: 'http://localhost:8000',
      changeOrigin: true,
    },
  },
}
```

**Purpose:**
- Avoids CORS issues in development
- Frontend makes requests to `/api/v1/...`
- Vite forwards to `http://localhost:8000/api/v1/...`

### 2. API Service Layer

**File:** `frontend/src/services/api.ts`

```typescript
async function fetchApi<T>(endpoint: string): Promise<T> {
  const url = getApiUrl(endpoint);  // /api/v1/endpoint
  const response = await fetch(url);
  return response.json();
}
```

**Purpose:**
- Centralized API calls
- Consistent error handling
- Type-safe responses

### 3. Data Transformation

**File:** `frontend/src/utils/dataTransform.ts`

```typescript
function transformThreadToOpportunity(thread: EmailThread): Opportunity {
  // Maps backend EmailThread → frontend Opportunity
}
```

**Purpose:**
- Backend and frontend have different data models
- Transformation layer keeps them decoupled
- Easy to update one without changing the other

### 4. React Hooks

**File:** `frontend/src/hooks/useEmailData.ts`

```typescript
function useEmailData() {
  const [opportunities, setOpportunities] = useState([]);
  
  useEffect(() => {
    emailService.getThreads()
      .then(threads => setOpportunities(
        threads.map(transformThreadToOpportunity)
      ));
  }, []);
  
  return { opportunities };
}
```

**Purpose:**
- Encapsulates data fetching logic
- Manages loading and error states
- Reusable across components

### 5. CORS Configuration

**File:** `backend/app/config/settings.py`

```python
ALLOWED_ORIGINS = "http://localhost:3000,http://localhost:5173"
```

**File:** `backend/app/main.py`

```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.allowed_origins_list,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

**Purpose:**
- Allows frontend to call backend APIs
- Required for production deployment
- Not needed in dev due to Vite proxy

## Environment-Specific Behavior

### Development

- **Frontend**: Uses Vite proxy (`VITE_API_BASE_URL` = empty)
- **Backend**: Runs on localhost:8000 with DEBUG=True
- **Database**: Local PostgreSQL instance
- **CORS**: Configured for localhost:3000

### Production

- **Frontend**: Direct API calls (`VITE_API_BASE_URL` = production URL)
- **Backend**: Production server with DEBUG=False
- **Database**: Production PostgreSQL
- **CORS**: Configured for production domain

## Security Considerations

1. **API Keys**: Never committed to git (use .env files)
2. **CORS**: Restricted to known frontend origins
3. **Input Validation**: Pydantic models validate all inputs
4. **SQL Injection**: SQLAlchemy ORM prevents injection
5. **Error Messages**: Production mode hides detailed errors

## Performance Optimizations

1. **Caching**: Can add React Query for client-side caching
2. **Lazy Loading**: Components loaded on demand
3. **Code Splitting**: Vite automatically splits bundles
4. **Database Indexing**: Proper indexes on frequently queried fields
5. **Connection Pooling**: SQLAlchemy manages DB connections

## Monitoring and Debugging

### Development Tools

- **Frontend**: React DevTools, Network tab
- **Backend**: Swagger UI at /docs, logs in terminal
- **Database**: psql, pgAdmin
- **API Testing**: Swagger UI, curl, Postman

### Logging

- **Frontend**: Console logs in development
- **Backend**: Python logging module
- **Levels**: DEBUG, INFO, WARNING, ERROR

### Health Checks

- **Backend**: GET /health
- **Database**: Connection test on startup
- **Azure OpenAI**: Configuration check on startup
