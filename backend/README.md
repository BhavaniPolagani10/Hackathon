# Email Summarization & Quote Generation Backend

A Python backend system that uses Azure GPT-4o to read mock email data, summarize conversations, and generate quotes with pricing from PostgreSQL.

## Features

- **Email Conversation Tracking**: Ingest and manage email conversations between customers and sales representatives
- **AI-Powered Summarization**: Use Azure GPT-4o to analyze email threads and extract structured information:
  - Requested products and quantities
  - Urgency level
  - Shipping address
  - Delivery deadlines
  - Customer comments and requirements
- **Automated Quote Generation**: 
  - Parse email summaries to extract structured data
  - Query PostgreSQL for machinery pricing based on previous purchases
  - Auto-calculate pricing with discounts and taxes
  - Generate standardized quotes from templates
  - Associate quotes with source email conversations
- **PDF Generation**: Download quotes as professional PDF documents
- **REST API**: Full-featured FastAPI backend with comprehensive documentation

## Tech Stack

- **Framework**: FastAPI 0.109+
- **AI/ML**: Azure OpenAI GPT-4o
- **Database**: PostgreSQL with SQLAlchemy
- **PDF Generation**: ReportLab
- **Python**: 3.9+

## Prerequisites

1. **Python 3.9 or higher**
   ```bash
   python --version
   ```

2. **PostgreSQL Database**
   - Install PostgreSQL 12+ or use existing instance
   - Database schemas should be created using the SQL files in `db/schema/`

3. **Azure OpenAI Account**
   - Azure subscription with OpenAI service enabled
   - GPT-4o deployment created
   - API key and endpoint URL

## Installation Steps

### Step 1: Clone Repository and Navigate to Backend

```bash
cd backend
```

### Step 2: Create Virtual Environment

```bash
# Create virtual environment
python -m venv venv

# Activate virtual environment
# On Windows:
venv\Scripts\activate

# On macOS/Linux:
source venv/bin/activate
```

### Step 3: Install Dependencies

```bash
pip install -r requirements.txt
```

### Step 4: Set Up PostgreSQL Database

1. **Create Database**:
   ```bash
   # Connect to PostgreSQL
   psql -U postgres

   # Create database
   CREATE DATABASE hackathon_db;
   
   # Exit psql
   \q
   ```

2. **Load Database Schemas**:
   ```bash
   # Load CRM schema
   psql -U postgres -d hackathon_db -f ../db/schema/crm_schema.sql
   
   # Load ERP schema
   psql -U postgres -d hackathon_db -f ../db/schema/erp_schema.sql
   ```

3. **Load Mock Data** (Optional - for testing):
   ```bash
   # If you have mock data SQL files
   psql -U postgres -d hackathon_db -f ../db/mockdata/sample_products.sql
   ```

### Step 5: Configure Environment Variables

1. **Copy example environment file**:
   ```bash
   cp .env.example .env
   ```

2. **Edit .env file** with your configuration:
   ```bash
   # Azure OpenAI Configuration
   AZURE_OPENAI_ENDPOINT=https://your-resource.openai.azure.com/
   AZURE_OPENAI_API_KEY=your-api-key-here
   AZURE_OPENAI_DEPLOYMENT_NAME=gpt-4o
   AZURE_OPENAI_API_VERSION=2024-02-15-preview

   # PostgreSQL Database Configuration
   DATABASE_HOST=localhost
   DATABASE_PORT=5432
   DATABASE_NAME=hackathon_db
   DATABASE_USER=postgres
   DATABASE_PASSWORD=your_password_here

   # Application Configuration
   APP_ENV=development
   DEBUG=True
   ```

### Step 6: Create Output Directories

```bash
mkdir -p output/pdfs
```

### Step 7: Verify Installation

Test database connection and dependencies:

```bash
python -c "from app.utils import test_db_connection; print('Database OK' if test_db_connection() else 'Database Failed')"
```

## Running the Application

### Start the Server

```bash
# Development mode with auto-reload
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# Or using Python directly
python -m app.main
```

The server will start at `http://localhost:8000`

### Access API Documentation

- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc
- **Health Check**: http://localhost:8000/health

## API Endpoints

### Email Management

#### List All Email Threads
```bash
GET /api/v1/emails/
```
Returns all email conversation threads.

#### Get Specific Email Thread
```bash
GET /api/v1/emails/{thread_id}
```
Returns email thread with all messages.

#### Get Thread Messages
```bash
GET /api/v1/emails/{thread_id}/messages
```
Returns all messages for a specific thread.

#### Summarize Email Thread
```bash
POST /api/v1/emails/{thread_id}/summarize
```
Analyzes email conversation using Azure GPT-4o and extracts:
- Summary of conversation
- Requested products and quantities
- Urgency level
- Shipping address
- Delivery deadline
- Customer comments

### Quote Generation

#### Generate Quote from Email
```bash
POST /api/v1/quotes/generate?thread_id={thread_id}
```
Generates complete quote from email conversation with pricing from PostgreSQL.

#### Download Quote as PDF
```bash
GET /api/v1/quotes/{quote_number}/pdf?thread_id={thread_id}
```
Downloads professional PDF document of the quote.

#### Get Product Pricing
```bash
GET /api/v1/quotes/pricing/{product_code}
```
Retrieves pricing for specific product based on purchase history.

## Usage Examples

### Example 1: List Email Conversations

```bash
curl -X GET "http://localhost:8000/api/v1/emails/"
```

Response:
```json
[
  {
    "thread_id": 21,
    "subject": "Quotation #Q-2025-1201 - CAT 320 Excavator",
    "customer_name": "Mark Thompson",
    "customer_email": "m.thompson@thompsonexcavating.com",
    "status": "open",
    "message_count": 2,
    "first_message_at": "2025-12-10T09:00:00",
    "last_message_at": "2025-12-10T11:00:00"
  }
]
```

### Example 2: Summarize Email Conversation

```bash
curl -X POST "http://localhost:8000/api/v1/emails/21/summarize"
```

Response:
```json
{
  "thread_id": 21,
  "summary_text": "Customer interested in purchasing CAT 320 Excavator with specific configuration...",
  "requested_products": ["CAT 320 Excavator"],
  "quantities": {"CAT 320 Excavator": 1},
  "urgency": "normal",
  "shipping_address": "Thompson Excavating, 1234 Industrial Blvd, Chicago, IL 60601",
  "delivery_deadline": "3-4 weeks",
  "customer_comments": "Need 42\" bucket, standard tracks, AC cabin, rear camera",
  "estimated_budget": 290000.0,
  "confidence_score": 0.95
}
```

### Example 3: Generate Quote

```bash
curl -X POST "http://localhost:8000/api/v1/quotes/generate?thread_id=21"
```

Response:
```json
{
  "quote_id": null,
  "quote_number": "Q-20251209-ABC123DE",
  "thread_id": 21,
  "customer_name": "Mark Thompson",
  "customer_email": "m.thompson@thompsonexcavating.com",
  "quote_date": "2025-12-09",
  "valid_until": "2026-01-08",
  "subtotal": 288000.00,
  "tax_rate": 8.00,
  "tax_amount": 23040.00,
  "total_amount": 311040.00,
  "line_items": [
    {
      "line_number": 1,
      "product_code": "CAT320-NG",
      "product_name": "CAT 320 Next Gen Hydraulic Excavator",
      "quantity": 1,
      "unit_price": 288000.00,
      "line_total": 288000.00
    }
  ]
}
```

### Example 4: Download Quote PDF

```bash
curl -X GET "http://localhost:8000/api/v1/quotes/Q-20251209-ABC123DE/pdf?thread_id=21" --output quote.pdf
```

## Testing

### Run Tests

```bash
# Run all tests
pytest

# Run with coverage
pytest --cov=app tests/

# Run specific test file
pytest tests/test_email_service.py
```

### Manual Testing with Mock Data

The application includes mock email data based on the MockMailConversations.md file. You can test the full flow:

1. Start the server
2. Access Swagger UI at http://localhost:8000/docs
3. Try the endpoints:
   - List emails
   - View thread 21, 22, or 23
   - Summarize a thread
   - Generate quote
   - Download PDF

## Troubleshooting

### Database Connection Issues

```bash
# Test PostgreSQL connection
psql -U postgres -d hackathon_db -c "SELECT 1;"

# Check if schemas exist
psql -U postgres -d hackathon_db -c "\dn"
```

### Azure OpenAI Issues

- Verify API key is correct in .env file
- Check endpoint URL format (must end with /)
- Ensure GPT-4o deployment exists in your Azure OpenAI resource
- Verify API version is compatible

### PDF Generation Issues

```bash
# Ensure output directory exists
mkdir -p output/pdfs

# Check write permissions
ls -la output/
```

### Import Errors

```bash
# Reinstall dependencies
pip install -r requirements.txt --force-reinstall

# Verify Python version
python --version  # Should be 3.9+
```

## Project Structure

```
backend/
├── app/
│   ├── __init__.py
│   ├── main.py                 # FastAPI application
│   ├── config/
│   │   ├── __init__.py
│   │   └── settings.py         # Configuration settings
│   ├── models/
│   │   ├── __init__.py
│   │   ├── email.py            # Email models
│   │   └── quote.py            # Quote models
│   ├── services/
│   │   ├── __init__.py
│   │   ├── azure_openai_service.py  # Azure GPT-4o integration
│   │   ├── email_service.py    # Email management
│   │   ├── quote_service.py    # Quote generation
│   │   └── pdf_service.py      # PDF generation
│   ├── api/
│   │   ├── __init__.py
│   │   ├── emails.py           # Email endpoints
│   │   └── quotes.py           # Quote endpoints
│   └── utils/
│       ├── __init__.py
│       └── database.py         # Database utilities
├── tests/                       # Test files
├── output/
│   └── pdfs/                   # Generated PDFs
├── requirements.txt            # Python dependencies
├── .env.example               # Example environment variables
└── README.md                  # This file
```

## Environment Variables Reference

| Variable | Description | Example |
|----------|-------------|---------|
| `AZURE_OPENAI_ENDPOINT` | Azure OpenAI endpoint URL | `https://your-resource.openai.azure.com/` |
| `AZURE_OPENAI_API_KEY` | Azure OpenAI API key | Your API key |
| `AZURE_OPENAI_DEPLOYMENT_NAME` | GPT-4o deployment name | `gpt-4o` |
| `AZURE_OPENAI_API_VERSION` | API version | `2024-02-15-preview` |
| `DATABASE_HOST` | PostgreSQL host | `localhost` |
| `DATABASE_PORT` | PostgreSQL port | `5432` |
| `DATABASE_NAME` | Database name | `hackathon_db` |
| `DATABASE_USER` | Database user | `postgres` |
| `DATABASE_PASSWORD` | Database password | Your password |
| `APP_ENV` | Environment | `development` |
| `DEBUG` | Debug mode | `True` |
| `LOG_LEVEL` | Logging level | `INFO` |

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review API documentation at /docs
3. Check application logs
4. Verify all environment variables are set correctly

## License

This project is part of the Hackathon project.
