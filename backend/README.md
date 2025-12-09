# Email Quote Management System - Python Backend

A comprehensive Python backend system for tracking email conversations, generating summaries, and automatically creating quotations with PDF export capabilities.

## Features

✅ **Email Conversation Tracking**
- Ingest and store email conversations
- Extract customer details, requirements, and deadlines
- Parse product requests and quantities
- Track conversation threads

✅ **Email Summarization**
- Analyze email content using NLP
- Extract key information (products, quantities, urgency)
- Generate concise summaries
- Identify special requirements

✅ **Quote Generation**
- Auto-generate quotes from email conversations
- Calculate pricing with volume discounts
- Apply taxes and shipping costs
- Set delivery timelines based on urgency
- Include standard terms and conditions

✅ **PDF Export**
- Professional PDF quote generation
- Company branding support
- Detailed product listings
- Terms and conditions included

✅ **REST API**
- FastAPI-based RESTful API
- Interactive API documentation
- Async/await for performance
- CORS support for frontend integration

## Technology Stack

- **Framework**: FastAPI 0.104.1
- **Database**: SQLAlchemy with SQLite (async)
- **PDF Generation**: ReportLab
- **NLP**: NLTK, Transformers (optional)
- **Server**: Uvicorn

## Prerequisites

- Python 3.8 or higher
- pip (Python package manager)
- Virtual environment (recommended)

## Installation & Setup

### Step 1: Navigate to Backend Directory

```bash
cd backend
```

### Step 2: Create Virtual Environment

**On macOS/Linux:**
```bash
python3 -m venv venv
source venv/bin/activate
```

**On Windows:**
```bash
python -m venv venv
venv\Scripts\activate
```

### Step 3: Install Dependencies

```bash
pip install -r requirements.txt
```

This will install all required packages including:
- FastAPI and Uvicorn (web framework and server)
- SQLAlchemy (database ORM)
- ReportLab (PDF generation)
- Pydantic (data validation)
- And other dependencies

### Step 4: Configure Environment (Optional)

Copy the example environment file:
```bash
cp .env.example .env
```

Edit `.env` if you need to customize settings:
- Database URL
- API host/port
- CORS origins
- Debug mode

## Running the Application

### Option 1: Using Python Script (Recommended)

```bash
python run.py
```

### Option 2: Using Uvicorn Directly

```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### Option 3: Using Python Module

```bash
python -m uvicorn app.main:app --reload
```

The API will start on **http://localhost:8000**

## Loading Mock Data

To load sample email conversations into the database:

```bash
python utils/load_mock_data.py
```

This will create 6 mock email conversations with various scenarios:
- Simple inquiries
- Urgent requests
- Fleet orders
- Trade-in deals
- Multi-location orders

## API Documentation

Once the server is running, access the interactive API documentation:

- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc

## API Endpoints

### Email Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/emails/` | Create new email conversation |
| GET | `/emails/` | List all email conversations |
| GET | `/emails/{id}` | Get specific email |
| GET | `/emails/{id}/summary` | Get email summary |
| POST | `/emails/{id}/analyze` | Analyze/re-analyze email |
| DELETE | `/emails/{id}` | Delete email |

### Quote Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/quotes/` | Create new quote |
| POST | `/quotes/from-email/{email_id}` | Auto-generate quote from email |
| GET | `/quotes/` | List all quotes |
| GET | `/quotes/{id}` | Get specific quote |
| GET | `/quotes/{id}/pdf` | Download quote as PDF |
| PUT | `/quotes/{id}/status` | Update quote status |
| DELETE | `/quotes/{id}` | Delete quote |

### Dashboard Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/dashboard/stats` | Get dashboard statistics |

## Usage Examples

### 1. Create and Analyze Email

```bash
# Create an email
curl -X POST "http://localhost:8000/emails/" \
  -H "Content-Type: application/json" \
  -d '{
    "subject": "Need 3 Excavators Urgently",
    "from_email": "customer@example.com",
    "from_name": "John Doe",
    "to_email": "sales@company.com",
    "to_name": "Sales Team",
    "body": "We need 3 CAT 320 excavators delivered by next month to our Boston site."
  }'
```

The email will be automatically analyzed upon creation.

### 2. Generate Quote from Email

```bash
# Generate quote from email ID 1
curl -X POST "http://localhost:8000/quotes/from-email/1"
```

### 3. Download Quote as PDF

Open in browser:
```
http://localhost:8000/quotes/1/pdf
```

Or use curl:
```bash
curl -X GET "http://localhost:8000/quotes/1/pdf" --output quote.pdf
```

### 4. Get Dashboard Statistics

```bash
curl -X GET "http://localhost:8000/dashboard/stats"
```

Response:
```json
{
  "total_emails": 6,
  "analyzed_emails": 6,
  "quotes_generated": 3,
  "pending_emails": 0
}
```

## Complete Workflow Example

### 1. Start the Server
```bash
python run.py
```

### 2. Load Mock Data
```bash
python utils/load_mock_data.py
```

### 3. View Emails
Open browser: http://localhost:8000/docs

Navigate to `GET /emails/` and click "Try it out" → "Execute"

### 4. Analyze an Email
Use `POST /emails/{email_id}/analyze` endpoint with an email ID

### 5. Generate Quote
Use `POST /quotes/from-email/{email_id}` endpoint

### 6. Download PDF
Use `GET /quotes/{quote_id}/pdf` endpoint to download the PDF

### 7. View in UI
If you have the frontend running (on port 5173 or 3000), it will automatically connect to this backend.

## Database

The application uses SQLite database (`app.db`) which is created automatically on first run.

### Database Schema

**Emails Table:**
- Email metadata (subject, from, to, date)
- Customer information (name, company, email)
- Extracted data (products, quantities, deadline)
- Analysis results (summary, urgency, requirements)
- Status tracking

**Quotes Table:**
- Quote number (auto-generated)
- Customer information
- Product details with pricing
- Calculations (subtotal, tax, shipping, total)
- Delivery information
- Terms and conditions
- Status tracking

## Email Processing Logic

The system automatically extracts:

1. **Customer Information**
   - Name and company from email signature
   - Email address
   - Contact details

2. **Products**
   - Heavy equipment models (CAT, Komatsu, etc.)
   - Equipment types (excavator, bulldozer, etc.)

3. **Quantities**
   - Number of units requested
   - Multiple items support

4. **Urgency Level**
   - Urgent: ASAP, emergency, rush
   - High: Soon, quickly
   - Medium: Standard requests
   - Low: Flexible timing

5. **Deadlines**
   - Specific dates mentioned
   - Time-based requirements (e.g., "within 2 weeks")

6. **Shipping Address**
   - Delivery location extraction
   - Address parsing

## Quote Calculation Logic

### Pricing
- Base prices for equipment categories
- ±5% random variation for market conditions
- Volume discounts:
  - 5% off for 3+ units
  - 10% off for 5+ units

### Taxes
- 8% tax rate (configurable)

### Shipping
- Base shipping: $2,500
- Per unit additional: $500

### Delivery Time
- Urgent: 7 days + (3 days per extra unit)
- High: 14 days + (3 days per extra unit)
- Medium: 21 days + (3 days per extra unit)
- Low: 30 days + (3 days per extra unit)

## Troubleshooting

### Port Already in Use
If port 8000 is busy, change it in `.env`:
```
API_PORT=8001
```

Or run with different port:
```bash
uvicorn app.main:app --port 8001
```

### Database Locked Error
Stop all running instances and delete `app.db`:
```bash
rm app.db
python run.py
```

### Import Errors
Ensure you're in the virtual environment and dependencies are installed:
```bash
source venv/bin/activate  # or venv\Scripts\activate on Windows
pip install -r requirements.txt
```

### CORS Issues
Add your frontend URL to `.env`:
```
CORS_ORIGINS=http://localhost:3000,http://localhost:5173,http://localhost:5174
```

## Testing with Frontend

If you have the React frontend running:

1. Start backend: `python run.py` (on port 8000)
2. Start frontend: `npm run dev` (typically on port 5173)
3. Frontend will automatically connect to backend API
4. CORS is pre-configured for common frontend ports

## Development

### Project Structure
```
backend/
├── app/
│   ├── __init__.py
│   ├── main.py              # FastAPI application
│   ├── config.py            # Configuration
│   ├── database.py          # Database setup
│   ├── schemas.py           # Pydantic schemas
│   ├── models/              # SQLAlchemy models
│   │   ├── email.py
│   │   └── quote.py
│   ├── routes/              # API routes
│   │   ├── emails.py
│   │   ├── quotes.py
│   │   └── dashboard.py
│   └── services/            # Business logic
│       ├── email_processor.py
│       ├── quote_generator.py
│       └── pdf_generator.py
├── utils/
│   └── load_mock_data.py    # Mock data loader
├── tests/                    # Test files
├── requirements.txt          # Dependencies
├── run.py                   # Entry point
├── .env.example             # Environment template
└── README.md                # This file
```

### Adding New Features

1. **New Models**: Add to `app/models/`
2. **New Routes**: Add to `app/routes/`
3. **Business Logic**: Add to `app/services/`
4. **Schemas**: Add to `app/schemas.py`

### Running Tests

```bash
pytest
```

## Performance Considerations

- **Async/Await**: All database operations are async
- **Connection Pooling**: SQLAlchemy manages connections
- **PDF Generation**: Happens in-memory, fast response
- **Caching**: Can be added for frequently accessed data

## Security Notes

- Input validation using Pydantic
- SQL injection protection via SQLAlchemy ORM
- CORS configuration for frontend access
- Environment-based configuration
- Production deployment should use:
  - HTTPS
  - Proper authentication/authorization
  - Production-grade database (PostgreSQL)
  - Rate limiting
  - Input sanitization

## Future Enhancements

Potential improvements:
- [ ] Advanced NLP with transformers
- [ ] Email thread tracking
- [ ] Quote comparison
- [ ] Customer history
- [ ] Analytics dashboard
- [ ] Email templates
- [ ] Multi-language support
- [ ] Currency conversion
- [ ] Integration with email servers (IMAP/SMTP)
- [ ] Webhook notifications

## Support

For issues or questions:
1. Check the API documentation at `/docs`
2. Review this README
3. Check server logs for errors
4. Ensure all dependencies are installed

## License

This project is part of the Hackathon repository.

---

**Quick Start Summary:**
```bash
# 1. Setup
cd backend
python3 -m venv venv
source venv/bin/activate  # or venv\Scripts\activate on Windows
pip install -r requirements.txt

# 2. Run
python run.py

# 3. Load sample data
python utils/load_mock_data.py

# 4. Access API
# Open http://localhost:8000/docs
```

**You're all set! 🚀**
