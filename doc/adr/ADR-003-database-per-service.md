# ADR-003: Database per Service Pattern

**Status:** Accepted

**Date:** 2025-11-24

**Context:**
Our microservices architecture requires data management strategy. Each service has distinct data access patterns and requirements:
- Email Service: Stores large email bodies, attachments (unstructured)
- Customer Service: Relational customer data with strong consistency
- Quote Service: Complex relational data with transactions
- Inventory Service: High-frequency reads for stock checks
- Pipeline Service: Analytics-friendly structure for reporting

Services need to:
- Optimize database technology for their specific use case
- Scale independently
- Deploy without coordinating schema changes
- Maintain clear ownership boundaries

**Decision:**
We will implement the "Database per Service" pattern with the following approach:

1. **Service-Specific Databases:**
   - Each service owns its database schema
   - No direct database access between services
   - Data sharing only via APIs or events

2. **Technology Choices:**
   - **PostgreSQL** for transactional services (Customer, Quote, Approval, PO, Inventory)
     - ACID properties for financial data
     - Rich query capabilities
     - Mature ecosystem
   
   - **MongoDB** for document-oriented services (Email, Tender)
     - Flexible schema for email storage
     - Good for semi-structured documents
     - Efficient full-text search
   
   - **Redis** for caching across all services
     - Sub-millisecond latency
     - Session management
     - Rate limiting
   
   - **Elasticsearch** for search-heavy services (Pipeline, Customer)
     - Full-text search
     - Analytics queries
     - Log aggregation

3. **Data Ownership:**
```
Email Service owns:
  - emails table
  - email_attachments table
  - email_assignments table

Customer Service owns:
  - customers table
  - customer_addresses table
  - customer_contacts table
  - machine_history table

Quote Service owns:
  - quotes table
  - quote_line_items table
  - machine_configurations table

Inventory Service owns:
  - products table
  - inventory table
  - stock_movements table
  - stock_reservations table
```

4. **Cross-Service Data Access:**
   - Services query other services via REST APIs
   - Services subscribe to events for local caching
   - Use CQRS for read-heavy scenarios

**Consequences:**

**Positive:**
- Services are truly independent (schema changes don't affect other services)
- Optimal database technology per use case
- Easier to scale databases independently
- Clear data ownership and responsibility
- Parallel development (no schema conflicts between teams)
- Service-specific backup and recovery strategies
- Better security (service-level database access control)

**Negative:**
- No database-level joins across services
- Distributed transactions are complex (use sagas)
- Data duplication across services
- Eventual consistency challenges
- Higher storage costs (redundant data)
- Complex reporting across services (need data warehouse)
- More databases to manage and monitor

**Mitigations:**
- Implement saga pattern for distributed transactions
- Use event-driven replication for frequently accessed cross-service data
- Build centralized data warehouse for reporting (batch ETL)
- Implement circuit breakers for inter-service calls
- Use shared reference data service for common lookups
- Establish data consistency monitoring
- Use database migration tools (Flyway/Liquibase) per service

**Data Consistency Strategies:**

1. **Strong Consistency (within service):**
   - Use database transactions
   - Example: Quote creation with line items

2. **Eventual Consistency (across services):**
   - Use event-driven replication
   - Example: Customer name cached in Quote Service

3. **Saga Pattern (distributed transactions):**
   - Example: Quote → Stock Reservation → PO Creation
   - Compensating transactions for rollback

**Example: Quote Creation Flow**
```
1. Quote Service creates quote (local transaction)
2. Quote Service publishes QuoteCreated event
3. Inventory Service receives event
4. Inventory Service reserves stock (local transaction)
5. Inventory Service publishes StockReserved event
6. Quote Service receives event and updates quote status

If stock reservation fails:
7. Inventory Service publishes StockReservationFailed event
8. Quote Service marks quote as "Pending Stock"
9. Notification sent to sales rep
```

**Shared Data Handling:**

**Reference Data (Products, Configurations):**
- Maintained by dedicated service
- Cached locally with TTL
- Updated via events

**Customer Data Replication:**
```
# Customer Service (source of truth)
customers: full table

# Quote Service (denormalized)
customer_cache: {id, name, tax_number}

# Email Service (minimal)
customer_email_index: {email, customer_id}
```

**Alternatives Considered:**

1. **Shared Database**
   - Simple to implement
   - Easy cross-service queries
   - Rejected because: Tight coupling, no independent scaling, schema coordination required

2. **Database per Service with Shared Tables**
   - Some shared tables (customers, products)
   - Private tables per service
   - Rejected because: Still creates coupling, unclear ownership

3. **Single Logical Database, Physical Schemas**
   - Schemas isolate services in same database
   - Rejected because: Can't optimize technology per service, shared resource contention

**Related Decisions:**
- ADR-001: Microservices Architecture
- ADR-002: Event-Driven Communication
- ADR-006: Eventual Consistency Model

**Notes:**
- Consider using multi-tenant database clusters for cost optimization
- Plan for cross-service reporting (data warehouse/lake)
- Review data replication strategy quarterly
- Monitor storage costs for duplicated data
