# Quick Start Guide - 5 Minutes to Running

This guide gets you up and running in ~5 minutes.

## Prerequisites Check

Run these commands to verify you have everything:

```bash
python3 --version  # Should be 3.9+
psql --version     # Should be 12+
```

## Setup Steps

### 1. Install Python Dependencies (1 min)

```bash
cd backend
python3 -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
```

### 2. Setup Database (2 min)

```bash
# Create database
createdb hackathon_db

# Load schemas (from repository root)
cd ..
psql -d hackathon_db -f db/schema/crm_schema.sql
psql -d hackathon_db -f db/schema/erp_schema.sql

# Load sample data
cd backend
psql -d hackathon_db -f sample_data.sql
```

### 3. Configure Environment (1 min)

```bash
cp .env.example .env
```

Edit `.env` and update:
- `AZURE_OPENAI_ENDPOINT` - Your Azure endpoint
- `AZURE_OPENAI_API_KEY` - Your API key
- `DATABASE_PASSWORD` - Your PostgreSQL password

### 4. Start Server (1 min)

```bash
./run.sh
```

Or manually:
```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

## Verify It's Working

1. **Health Check**
   ```bash
   curl http://localhost:8000/health
   ```
   Should return: `{"status": "healthy", ...}`

2. **Open API Docs**
   - Browser: http://localhost:8000/docs

3. **Test Email Listing**
   ```bash
   curl http://localhost:8000/api/v1/emails/
   ```
   Should return 3 mock email threads

## Test the Full Workflow

### Step 1: List Emails
```bash
curl http://localhost:8000/api/v1/emails/
```

### Step 2: View Email Thread
```bash
curl http://localhost:8000/api/v1/emails/21
```

### Step 3: Summarize Email (Uses Azure GPT-4o)
```bash
curl -X POST http://localhost:8000/api/v1/emails/21/summarize
```

### Step 4: Generate Quote (Uses PostgreSQL pricing)
```bash
curl -X POST "http://localhost:8000/api/v1/quotes/generate?thread_id=21"
```

### Step 5: Download PDF
```bash
curl -X GET "http://localhost:8000/api/v1/quotes/{quote_number}/pdf?thread_id=21" -o quote.pdf
```
(Replace `{quote_number}` with the number from Step 4)

## What You Get

- ✅ Email conversation tracking
- ✅ AI-powered summarization (Azure GPT-4o)
- ✅ Automated quote generation
- ✅ Pricing from PostgreSQL database
- ✅ Professional PDF quotes
- ✅ REST API with documentation

## Troubleshooting

### Database connection failed
```bash
# Check PostgreSQL is running
# macOS: brew services start postgresql@14
# Linux: sudo systemctl start postgresql

# Test connection
psql -d hackathon_db -c "SELECT 1;"
```

### Azure OpenAI errors
- Verify endpoint ends with `/`
- Check API key is correct
- Ensure GPT-4o deployment exists

### Module not found
```bash
# Activate virtual environment
source venv/bin/activate

# Reinstall dependencies
pip install -r requirements.txt
```

## Next Steps

- Read [README.md](README.md) for detailed API documentation
- See [SETUP_GUIDE.md](SETUP_GUIDE.md) for comprehensive setup instructions
- Explore API at http://localhost:8000/docs
- Test with your own email data
- Integrate with frontend

## Support

- API Documentation: http://localhost:8000/docs
- Health Check: http://localhost:8000/health
- Detailed Guide: SETUP_GUIDE.md
- Full Docs: README.md
