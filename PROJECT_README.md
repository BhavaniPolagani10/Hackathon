# Dealer Sales & Customer Management System

A comprehensive Proof of Concept (POC) for a Dealer Management System designed to streamline customer communication, improve sales processes, enhance inventory management, and provide real-time visibility into sales operations.

## Architecture Overview

This project follows a modern microservices-inspired architecture with:
- **Frontend:** React JS application with Firebase Authentication
- **Backend:** Python Flask REST API with PostgreSQL database

```
┌─────────────────────────────────────────────────────────────────┐
│                        Frontend (React)                          │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐  │
│  │   Login     │  │  Register   │  │      Dashboard          │  │
│  │   Page      │  │   Page      │  │   (Customers, Quotes,   │  │
│  └─────────────┘  └─────────────┘  │    Inventory, etc.)     │  │
│                                     └─────────────────────────┘  │
│              Firebase Authentication                             │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             │ REST API
                             │
┌────────────────────────────▼────────────────────────────────────┐
│                     Backend (Flask)                              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐  │
│  │   Auth      │  │  Customers  │  │      Products           │  │
│  │   Routes    │  │   Routes    │  │       Routes            │  │
│  └─────────────┘  └─────────────┘  └─────────────────────────┘  │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐  │
│  │  Inventory  │  │   Quotes    │  │   Purchase Orders       │  │
│  │   Routes    │  │   Routes    │  │       Routes            │  │
│  └─────────────┘  └─────────────┘  └─────────────────────────┘  │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             │ SQLAlchemy ORM
                             │
┌────────────────────────────▼────────────────────────────────────┐
│                    PostgreSQL Database                           │
│  Users | Customers | Products | Inventory | Quotes | POs        │
└─────────────────────────────────────────────────────────────────┘
```

## Features

### Authentication
- Firebase Authentication for user login and registration
- Secure JWT token-based authentication

### Core Modules
- **Customer Management:** 360° customer view, contacts, addresses
- **Product Catalog:** Product configurations, options, pricing
- **Inventory Management:** Multi-warehouse stock tracking
- **Quote Generation:** Quote creation, line items, configurations
- **Purchase Orders:** PO generation from quotes

## Project Structure

```
├── frontend/                # React JS application
│   ├── src/
│   │   ├── components/     # Reusable UI components
│   │   ├── pages/         # Page components
│   │   ├── services/      # API and auth services
│   │   └── config/        # Firebase configuration
│   └── README.md
│
├── backend/                 # Python Flask API
│   ├── app/
│   │   ├── models/        # SQLAlchemy models
│   │   ├── routes/        # API endpoints
│   │   └── services/      # Business logic
│   ├── config/            # Configuration settings
│   ├── DATABASE_QUERIES.md # SQL documentation
│   └── README.md
│
├── doc/                     # Documentation
│   ├── hld/               # High-Level Design
│   ├── lld/               # Low-Level Design
│   └── adr/               # Architecture Decision Records
│
└── solutionArchitecture/   # Solution Architecture Document
```

## Quick Start

### Prerequisites

- Node.js 18+ and npm
- Python 3.10+
- PostgreSQL 14+
- Firebase project with Authentication enabled

### Setup Frontend

```bash
cd frontend
npm install
cp .env.example .env.local
# Edit .env.local with your Firebase credentials
npm run dev
```

### Setup Backend

```bash
cd backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env
# Edit .env with your PostgreSQL credentials
python run.py
```

### Database Setup

```bash
# Create PostgreSQL database
createdb dealer_management

# The Flask app will auto-create tables on first run
python run.py
```

## API Documentation

See [backend/README.md](backend/README.md) for complete API endpoint documentation.

## Database Schema

See [backend/DATABASE_QUERIES.md](backend/DATABASE_QUERIES.md) for complete SQL schema and queries documentation.

## Technology Stack

| Layer | Technology |
|-------|------------|
| Frontend | React 19, Vite, React Router |
| Authentication | Firebase Auth |
| Backend | Python, Flask 3.1 |
| Database | PostgreSQL |
| ORM | SQLAlchemy |
| Migrations | Flask-Migrate / Alembic |

## Team Roles

As per the solution architecture:
- **Backend Developers:** Flask API, PostgreSQL, data models
- **Frontend Developers:** React UI, Firebase integration
- **Full-Stack Developers:** Integration, end-to-end features

## Documentation

- [Product Requirement Document](Product_Requirement_Document.md)
- [High-Level Design](doc/hld/HIGH_LEVEL_DESIGN.md)
- [Low-Level Design](doc/lld/LOW_LEVEL_DESIGN.md)
- [Solution Architecture](solutionArchitecture/Semantickernel/SolutionArchitecture.md)

## License

MIT
