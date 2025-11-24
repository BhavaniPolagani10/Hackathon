# ADR-002: Event-Driven Communication Pattern

**Status:** Accepted

**Date:** 2025-11-24

**Context:**
In our microservices architecture, services need to communicate with each other. For example:
- When an email is classified, multiple services need to know (Customer Service, Pipeline Service)
- When a quote is created, Inventory Service needs to reserve stock
- When an approval is granted, the originating service needs to be notified
- When a PO is created, multiple stakeholders need notifications

Synchronous request-response patterns create tight coupling and can cascade failures. We need a communication mechanism that:
- Decouples services
- Handles asynchronous operations
- Provides reliability (guaranteed delivery)
- Scales independently

**Decision:**
We will implement an event-driven architecture using RabbitMQ as our message broker with the following patterns:

1. **Event Publishing:**
   - Services publish domain events when state changes occur
   - Events are immutable facts about what happened (past tense)
   - Example events: `EmailClassified`, `QuoteCreated`, `ApprovalGranted`, `StockReserved`

2. **Event Subscription:**
   - Services subscribe to events they're interested in
   - Each service maintains its own queue
   - Failed message processing triggers retry with exponential backoff

3. **Event Schema:**
```json
{
  "event_id": "uuid",
  "event_type": "EmailClassified",
  "timestamp": "2025-11-24T05:32:00Z",
  "version": "1.0",
  "payload": {
    "email_id": "...",
    "category": "INQUIRY",
    "priority_score": 8
  },
  "metadata": {
    "correlation_id": "...",
    "source_service": "email-service"
  }
}
```

4. **Message Routing:**
   - Use topic exchanges for flexible routing
   - Use routing keys like: `email.classified`, `quote.created`, `approval.granted`
   - Dead letter queues for failed messages

**Consequences:**

**Positive:**
- Services are decoupled - publisher doesn't know about subscribers
- New subscribers can be added without changing publishers
- Resilient to temporary service outages (messages queued until service recovers)
- Natural fit for eventual consistency model
- Scales well (add more consumers to process messages faster)
- Audit trail built-in (events are logged)
- Enables event sourcing for critical entities

**Negative:**
- Eventual consistency - data may be temporarily inconsistent
- More complex debugging (distributed traces needed)
- Duplicate message handling required (idempotency)
- Ordering guarantees are limited
- Message broker becomes critical infrastructure (single point of failure)
- More complex testing (need to test event flows)

**Mitigations:**
- Make all event handlers idempotent
- Use correlation IDs for distributed tracing
- Implement dead letter queues for poison messages
- Set up RabbitMQ cluster for high availability
- Use message TTL to prevent queue buildup
- Implement monitoring for queue depths
- Document event catalog with schemas

**Event Examples:**

```
# Email classified
Event: EmailClassified
Publisher: Email Service
Subscribers: Customer Service, Pipeline Service, Notification Service

# Quote created
Event: QuoteCreated
Publisher: Quote Service
Subscribers: Pipeline Service, Inventory Service, Notification Service

# Approval granted
Event: ApprovalGranted
Publisher: Approval Service
Subscribers: Quote Service, PO Service, Notification Service

# Stock reserved
Event: StockReserved
Publisher: Inventory Service
Subscribers: Quote Service, Analytics Service
```

**Synchronous Communication Still Used For:**
- Direct user requests requiring immediate response
- Queries that don't change state
- Operations requiring strong consistency
- Service health checks

**Alternatives Considered:**

1. **REST API Calls Only**
   - Simpler initial implementation
   - Rejected because: Creates tight coupling and cascade failures

2. **Apache Kafka**
   - Better for high-throughput scenarios
   - Better retention policies
   - Rejected because: More complex to operate, overkill for our current scale

3. **AWS SQS/SNS**
   - Managed service, no infrastructure to maintain
   - Rejected because: Vendor lock-in, prefer open-source initially

**Related Decisions:**
- ADR-001: Microservices Architecture
- ADR-006: Eventual Consistency Model

**Notes:**
- Consider Kafka if message volume exceeds 10,000 messages/second
- Review message retention policies quarterly
- Plan for message schema evolution (versioning strategy)
