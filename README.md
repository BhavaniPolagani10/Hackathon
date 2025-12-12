# Hackathon Project - Sales Tracker with Email Integration

A full-stack application for tracking sales opportunities with AI-powered email summarization and quote generation.

## Overview

This project combines a React frontend for sales tracking with a FastAPI backend that provides:
- Email conversation management
- AI-powered email summarization using Azure OpenAI GPT-4o
- Automated quote generation from email threads
- Product pricing from PostgreSQL database
- PDF quote generation

## Quick Start

### Two Deployment Options

#### Option 1: Docker with Netflix Conductor (Recommended for Production)

Run the entire stack with workflow orchestration:

```bash
# See conductor/QUICKSTART.md for detailed instructions
docker-compose up -d
./conductor/setup.sh
```

Access services at:
- **Conductor UI**: http://localhost:5555
- **Backend API**: http://localhost:8000
- **Frontend**: http://localhost:3000

📘 **Full Guide**: [Conductor Integration Guide](./conductor/QUICKSTART.md)

#### Option 2: Local Development

### Prerequisites

- **Python 3.9+** for backend
- **Node.js 16+** for frontend
- **PostgreSQL 12+** database
- **Azure OpenAI** account (optional, for AI features)

### Start Both Services

```bash
# Automated start script (recommended)
./start.sh
```

Or start manually:

```bash
# Terminal 1 - Backend
cd backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env
# Edit .env with your configuration
python -m app.main

# Terminal 2 - Frontend
cd frontend
npm install
npm run dev
```

### Access the Application

- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8000
- **API Documentation**: http://localhost:8000/docs

## Project Structure

```
.
├── backend/              # FastAPI backend
│   ├── app/
│   │   ├── api/         # API endpoints
│   │   ├── models/      # Pydantic models
│   │   ├── services/    # Business logic
│   │   └── utils/       # Utilities
│   ├── requirements.txt
│   └── .env.example
│
├── frontend/            # React + TypeScript frontend
│   ├── src/
│   │   ├── components/  # React components
│   │   ├── pages/       # Page components
│   │   ├── services/    # API service layer
│   │   ├── hooks/       # Custom React hooks
│   │   └── types/       # TypeScript types
│   ├── package.json
│   └── .env.example
│
├── db/                  # Database schemas
├── conductor/           # Netflix Conductor workflows
│   ├── workflows/      # Workflow definitions (JSON)
│   ├── tasks/          # Task definitions (JSON)
│   ├── examples/       # Example scripts
│   ├── setup.sh        # Conductor setup script
│   ├── QUICKSTART.md   # Quick start guide
│   └── README.md       # Detailed documentation
├── docker-compose.yml  # Docker Compose configuration
├── start.sh            # Start script for both services
└── README_INTEGRATION.md  # Detailed integration guide
```

## Features

### Frontend (React + TypeScript)

- **Opportunities View**: Display sales opportunities with details
- **Clients View**: Show client information and conversations
- **Real-time Updates**: Live data from backend API
- **Responsive Design**: Works on desktop and mobile
- **Graceful Fallback**: Shows mock data if backend unavailable

### Backend (FastAPI + Python)

- **Email Management**: Track email conversations and threads
- **AI Summarization**: Extract key info from emails using GPT-4o
- **Quote Generation**: Auto-generate quotes with pricing
- **PDF Export**: Professional PDF quote documents
- **Database Integration**: PostgreSQL for data persistence
- **REST API**: Full API documentation with Swagger UI

### Workflow Orchestration (Netflix Conductor)

- **Email Summarization Workflow**: Automated email analysis pipeline
- **Quote Generation Workflow**: End-to-end quote creation process
- **Task Orchestration**: Retry logic, error handling, timeout management
- **Real-time Monitoring**: Track workflow execution in Conductor UI
- **Scalable Architecture**: Docker-based deployment with service orchestration

📘 **Learn more**: [Conductor Quick Start](./conductor/QUICKSTART.md)

## Integration

The frontend and backend are fully integrated:

1. **Vite Proxy**: Frontend proxies API calls to backend (no CORS issues)
2. **Service Layer**: Clean API abstraction in frontend
3. **Data Transformation**: Maps backend models to frontend types
4. **Error Handling**: Graceful degradation with mock data fallback

See [README_INTEGRATION.md](./README_INTEGRATION.md) for detailed integration guide.

## Configuration

### Backend Environment Variables

Create `backend/.env`:

```bash
# Azure OpenAI
AZURE_OPENAI_ENDPOINT=https://your-resource.openai.azure.com/
AZURE_OPENAI_API_KEY=your-key-here
AZURE_OPENAI_DEPLOYMENT_NAME=gpt-4o

# Database
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_NAME=hackathon_db
DATABASE_USER=postgres
DATABASE_PASSWORD=your-password

# CORS
ALLOWED_ORIGINS=http://localhost:3000
```

### Frontend Environment Variables

Create `frontend/.env`:

```bash
# Empty for local dev (uses Vite proxy)
VITE_API_BASE_URL=

# For production, set to backend URL
# VITE_API_BASE_URL=https://api.yourapp.com
```

## Development

### Backend Development

```bash
cd backend
source venv/bin/activate
python -m app.main  # Auto-reload enabled
```

- API Docs: http://localhost:8000/docs
- Health Check: http://localhost:8000/health

### Frontend Development

```bash
cd frontend
npm run dev  # Hot reload enabled
```

- App: http://localhost:3000
- Changes auto-reload in browser

## Building for Production

### Backend

```bash
cd backend
pip install -r requirements.txt
# Configure production .env
uvicorn app.main:app --host 0.0.0.0 --port 8000
```

### Frontend

```bash
cd frontend
VITE_API_BASE_URL=https://api.yourapp.com npm run build
# Serve dist/ folder with nginx or similar
```

## Testing

### Backend Tests

```bash
cd backend
pytest
```

### Frontend Build Test

```bash
cd frontend
npm run build
```

## API Endpoints

### Email Management

- `GET /api/v1/emails/` - List all email threads
- `GET /api/v1/emails/{id}` - Get thread with messages
- `POST /api/v1/emails/{id}/summarize` - AI summarization

### Quote Generation

- `POST /api/v1/quotes/generate?thread_id={id}` - Generate quote
- `GET /api/v1/quotes/{number}/pdf?thread_id={id}` - Download PDF
- `GET /api/v1/quotes/pricing/{code}` - Get product pricing

## Documentation

- **[Conductor Quick Start](./conductor/QUICKSTART.md)** - Get started with Docker & Conductor in 5 minutes
- **[Conductor Guide](./conductor/README.md)** - Complete Conductor integration documentation
- [Integration Guide](./README_INTEGRATION.md) - Detailed setup and troubleshooting
- [Frontend Integration](./frontend/INTEGRATION.md) - Frontend-specific details
- [Backend Setup](./backend/SETUP_GUIDE.md) - Backend configuration guide
- [Backend Quick Start](./backend/QUICKSTART.md) - Quick backend setup

## Technologies

### Frontend
- React 18
- TypeScript
- Vite
- React Router
- Lucide Icons

### Backend
- FastAPI
- SQLAlchemy
- Azure OpenAI (GPT-4o)
- PostgreSQL
- ReportLab (PDF generation)
- Pydantic

### Workflow Orchestration
- Netflix Conductor
- Docker & Docker Compose
- Elasticsearch (indexing)
- Redis (queue)
- Pydantic

## Troubleshooting

### Backend won't start
- Check Python version: `python --version` (need 3.9+)
- Install dependencies: `pip install -r requirements.txt`
- Check PostgreSQL is running
- Verify `.env` file exists and is configured

### Frontend won't start
- Check Node version: `node --version` (need 16+)
- Install dependencies: `npm install`
- Clear cache: `rm -rf node_modules && npm install`

### Integration issues
- Verify backend is running: `curl http://localhost:8000/health`
- Check browser console for errors
- Review `README_INTEGRATION.md` for detailed troubleshooting

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is part of a hackathon submission.

## Support

For detailed setup and troubleshooting, see:
- [README_INTEGRATION.md](./README_INTEGRATION.md)
- Backend documentation in `backend/`
- Frontend documentation in `frontend/`
