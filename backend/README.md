# Dealer Management System - Backend

A Flask-based REST API backend for the Dealer Sales & Customer Management System.

## Features

- RESTful API endpoints for CRUD operations
- PostgreSQL database with SQLAlchemy ORM
- Firebase Authentication integration
- Customer, Product, Quote, and Inventory management
- CORS enabled for frontend integration

## Tech Stack

- **Framework:** Flask 3.1
- **Database:** PostgreSQL with SQLAlchemy
- **Migrations:** Flask-Migrate / Alembic
- **Authentication:** Firebase Admin SDK
- **API Documentation:** REST endpoints

## Getting Started

### Prerequisites

- Python 3.10+
- PostgreSQL 14+
- Firebase project (for authentication)

### Installation

1. Create a virtual environment:
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

3. Configure environment variables:
   - Copy `.env.example` to `.env`
   - Update the values:
     ```
     FLASK_ENV=development
     SECRET_KEY=your-secret-key
     POSTGRES_HOST=localhost
     POSTGRES_PORT=5432
     POSTGRES_USER=postgres
     POSTGRES_PASSWORD=postgres
     POSTGRES_DB=dealer_management
     ```

4. Create the database:
   ```bash
   createdb dealer_management  # Or use pgAdmin/psql
   ```

5. Initialize the database:
   ```bash
   flask db init
   flask db migrate -m "Initial migration"
   flask db upgrade
   ```

   Or simply run the application (tables will be auto-created):
   ```bash
   python run.py
   ```

6. The API will be available at http://localhost:5000

### Available Scripts

- `python run.py` - Start development server
- `flask db migrate` - Generate database migration
- `flask db upgrade` - Apply database migrations

## API Endpoints

### Health
- `GET /api/health` - Health check

### Authentication
- `POST /api/auth/register` - Register user
- `POST /api/auth/login` - Login user
- `GET /api/auth/profile` - Get user profile
- `PUT /api/auth/profile` - Update profile

### Customers
- `GET /api/customers` - List customers
- `GET /api/customers/{id}` - Get customer details
- `POST /api/customers` - Create customer
- `PUT /api/customers/{id}` - Update customer
- `POST /api/customers/{id}/addresses` - Add address
- `POST /api/customers/{id}/contacts` - Add contact

### Products
- `GET /api/products` - List products
- `GET /api/products/{id}` - Get product details
- `POST /api/products` - Create product
- `PUT /api/products/{id}` - Update product
- `POST /api/products/{id}/options` - Add option
- `GET /api/products/categories` - Get categories
- `GET /api/products/manufacturers` - Get manufacturers

### Inventory
- `GET /api/inventory/availability` - Check stock
- `GET /api/inventory/products/{id}` - Get product inventory
- `GET /api/inventory/warehouses` - List warehouses
- `POST /api/inventory/warehouses` - Create warehouse
- `POST /api/inventory/stock` - Update stock
- `GET /api/inventory/low-stock` - Get low stock items

### Quotes
- `GET /api/quotes` - List quotes
- `GET /api/quotes/{id}` - Get quote details
- `POST /api/quotes` - Create quote
- `POST /api/quotes/{id}/line-items` - Add line item
- `DELETE /api/quotes/{id}/line-items/{item_id}` - Remove line item
- `PUT /api/quotes/{id}/status` - Update status
- `POST /api/quotes/validate-configuration` - Validate config

## Project Structure

```
backend/
├── app/
│   ├── models/          # SQLAlchemy models
│   │   ├── user.py
│   │   ├── customer.py
│   │   ├── product.py
│   │   ├── inventory.py
│   │   ├── quote.py
│   │   └── purchase_order.py
│   ├── routes/          # API endpoints
│   │   ├── auth.py
│   │   ├── customers.py
│   │   ├── products.py
│   │   ├── inventory.py
│   │   ├── quotes.py
│   │   └── health.py
│   ├── services/        # Business logic
│   ├── utils/           # Utility functions
│   ├── extensions.py    # Flask extensions
│   └── factory.py       # Application factory
├── config/
│   └── settings.py      # Configuration classes
├── migrations/          # Database migrations
├── DATABASE_QUERIES.md  # SQL documentation
├── requirements.txt
├── run.py              # Entry point
└── .env.example        # Environment template
```

## Database Schema

See `DATABASE_QUERIES.md` for complete SQL schema and queries documentation.

## License

MIT
