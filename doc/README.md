# Documentation Index
## Heavy Machinery Dealer Management System

Welcome to the comprehensive documentation for the Heavy Machinery Dealer Management System. This documentation provides detailed technical and business information about the system architecture, design decisions, and operational workflows.

---

## 📚 Documentation Overview

This documentation suite addresses the 10 critical pain points in heavy machinery dealer operations:

1. **Delayed Customer Responses** - Automated email classification and prioritization
2. **Lost Opportunities** - Intelligent email routing and tracking
3. **Incomplete Customer Data** - Centralized customer information hub
4. **Quote Configuration Errors** - Validation and rules engine
5. **Approval Bottlenecks** - Streamlined workflow automation
6. **Manual PO Creation** - Template-based automation
7. **Inventory Visibility** - Real-time multi-warehouse tracking
8. **Pipeline Opacity** - Comprehensive deal tracking dashboard
9. **Follow-up Failures** - Automated reminder system
10. **Slow Tender Response** - Document library and template system

---

## 📖 Document Structure

### High-Level Design (HLD)
**Location:** [`/doc/hld/HIGH_LEVEL_DESIGN.md`](hld/HIGH_LEVEL_DESIGN.md)

**Target Audience:** Architects, Technical Leaders, Business Stakeholders

**Contents:**
- Executive summary and business goals
- System context and external integrations
- Functional area descriptions
- Architecture overview and principles
- Technology stack summary
- Security architecture
- Non-functional requirements
- Integration points
- Deployment strategy
- Success metrics and KPIs

**Use this document when:**
- Understanding the overall system scope
- Making technology decisions
- Planning integration with external systems
- Presenting to non-technical stakeholders
- Estimating infrastructure requirements

---

### Low-Level Design (LLD)
**Location:** [`/doc/lld/LOW_LEVEL_DESIGN.md`](lld/LOW_LEVEL_DESIGN.md)

**Target Audience:** Software Engineers, DevOps Engineers, QA Engineers

**Contents:**
- Detailed component architecture
- C4 Container diagrams
- Component-level designs for each microservice
- Data models and entity relationships
- API specifications and endpoints
- Key algorithms and business logic
- Sequence diagrams for complex flows
- Performance optimization strategies
- Error handling patterns
- Security implementation details
- Testing strategies
- Deployment procedures

**Use this document when:**
- Implementing new features
- Debugging system issues
- Understanding data flows
- Designing APIs
- Planning database changes
- Writing tests
- Optimizing performance

---

### Architecture Decision Records (ADR)
**Location:** `/doc/adr/`

**Target Audience:** Architects, Technical Leaders, Senior Engineers

**ADR Index:**

1. **[ADR-001: Microservices Architecture](adr/ADR-001-microservices-architecture.md)**
   - Decision to adopt microservices pattern
   - Service boundaries and responsibilities
   - Trade-offs and mitigation strategies

2. **[ADR-002: Event-Driven Communication](adr/ADR-002-event-driven-communication.md)**
   - Event-driven architecture with RabbitMQ
   - Event schema and routing patterns
   - Handling eventual consistency

3. **[ADR-003: Database per Service](adr/ADR-003-database-per-service.md)**
   - Data ownership and isolation
   - Technology choices per service
   - Data consistency strategies
   - Cross-service data access patterns

4. **[ADR-004: API Gateway Pattern](adr/ADR-004-api-gateway-pattern.md)**
   - Centralized API Gateway using Kong
   - Authentication and authorization
   - Cross-cutting concerns
   - API composition for mobile

5. **[ADR-005: Machine Learning for Email Classification](adr/ADR-005-machine-learning-email-classification.md)**
   - ML model selection (BERT-based)
   - Training and inference architecture
   - Confidence thresholds
   - Active learning strategy
   - Model monitoring and retraining

6. **[ADR-006: Caching Strategy](adr/ADR-006-caching-strategy.md)**
   - Multi-layer caching with Redis
   - Cache-aside vs write-through patterns
   - TTL strategies per data type
   - Cache invalidation mechanisms
   - Performance impact analysis

**Use ADR documents when:**
- Understanding why certain technologies were chosen
- Evaluating alternative approaches
- Making similar decisions in the future
- Onboarding new team members
- Conducting architecture reviews

---

### C4 Architecture Diagrams
**Location:** [`/doc/diagrams/C4_DIAGRAMS.md`](diagrams/C4_DIAGRAMS.md)

**Target Audience:** All technical stakeholders

**Total Diagrams:** 16 comprehensive C4 diagrams covering all architectural levels

**Diagram Levels:**

**Level 1 - System Context (1 diagram):**
- Shows the system boundary
- External actors (customers, sales reps, managers)
- External systems (ERP, Email, Manufacturer APIs)
- High-level interactions

**Level 2 - Container Diagram (1 diagram):**
- Frontend applications (Web, Mobile)
- API Gateway
- All 9 microservices
- Data stores (PostgreSQL, MongoDB, Redis, Elasticsearch, S3)
- Message broker (RabbitMQ)
- Technology choices and ports

**Level 3 - Component Diagrams (9 diagrams - Complete Coverage):**
- ✅ Email Service (Receiver, Classifier, Router, Sender)
- ✅ Quote Service (Builder, Validator, Pricing, Template)
- ✅ Inventory Service (Stock Manager, Reservation, Sync)
- ✅ Customer Service (Manager, 360 Builder, Interaction Tracker)
- ✅ Approval Service (Workflow Engine, Rule Evaluator, Escalation)
- ✅ Purchase Order Service (Generator, Validator, Supplier Integration)
- ✅ Pipeline Service (Deal Manager, Forecast Engine, Analytics)
- ✅ Notification Service (Event Subscriber, Delivery Manager, WebSocket)
- ✅ Tender Service (Document Assembler, Compliance Checker)

**Level 4 - Code Diagrams (5 diagrams):**
- Email classification classes and ML integration
- Quote calculation and pricing engine
- Inventory reservation and locking mechanism
- Approval workflow state machine
- Pipeline forecasting and analytics classes

**Deployment Diagram (1 diagram):**
- Cloud infrastructure layout (AWS/Azure)
- Kubernetes cluster organization
- Managed services (RDS, ElastiCache, etc.)
- Monitoring and logging stack

**Use these diagrams when:**
- Explaining system architecture
- Planning new features
- Identifying integration points
- Understanding data flows
- Creating presentations

---

### Workflow and Process Diagrams
**Location:** [`/doc/diagrams/WORKFLOW_DIAGRAMS.md`](diagrams/WORKFLOW_DIAGRAMS.md)

**Target Audience:** Business Analysts, Product Managers, Engineers, QA

**Process Flows:**

1. **Email Processing Workflow**
   - End-to-end email handling
   - ML classification integration
   - Priority scoring logic
   - Assignment and notification

2. **Quote Generation Workflow**
   - Customer selection and data fetch
   - Product configuration and validation
   - Pricing and discount approval
   - Inventory checking and reservation
   - PDF generation and delivery
   - Follow-up scheduling

3. **Purchase Order Creation Workflow**
   - Quote-to-PO conversion
   - Data aggregation from multiple services
   - Validation and approval
   - Supplier submission
   - Confirmation handling

4. **Approval Workflow State Machine**
   - Multi-level approval flows
   - State transitions
   - Escalation rules
   - Timeout handling

5. **Sales Pipeline Process Flow**
   - Lead qualification
   - Quote preparation and delivery
   - Negotiation handling
   - Deal closure (won/lost)
   - Commission calculation

6. **Inventory Stock Reservation Sequence**
   - Detailed sequence diagram
   - Database locking strategy
   - Cache invalidation
   - Event publishing

7. **Tender Management Process**
   - Tender identification and triage
   - Document assembly
   - Compliance checking
   - Submission and tracking

8. **Customer Follow-up Automation**
   - Automated reminder system
   - Escalation to managers
   - Failed attempt handling
   - Next action scheduling

**Use these diagrams when:**
- Training new users
- Writing user stories
- Designing test cases
- Analyzing process improvements
- Troubleshooting issues

---

## 🎯 Quick Start Guide

### For Business Stakeholders:
1. Start with [High-Level Design](hld/HIGH_LEVEL_DESIGN.md) - Executive Summary
2. Review [System Context Diagram](diagrams/C4_DIAGRAMS.md#level-1-system-context-diagram)
3. Explore [Workflow Diagrams](diagrams/WORKFLOW_DIAGRAMS.md) for your area of interest

### For Technical Leaders:
1. Read [High-Level Design](hld/HIGH_LEVEL_DESIGN.md) completely
2. Review all [ADR documents](adr/) to understand key decisions
3. Study [C4 Container Diagram](diagrams/C4_DIAGRAMS.md#level-2-container-diagram)
4. Review [Deployment Architecture](hld/HIGH_LEVEL_DESIGN.md#9-deployment-architecture)

### For Developers:
1. Read [Low-Level Design](lld/LOW_LEVEL_DESIGN.md) for your service
2. Study [Component Diagrams](diagrams/C4_DIAGRAMS.md#level-3-component-diagram-email-service) for your area
3. Review [API Specifications](lld/LOW_LEVEL_DESIGN.md#314-api-endpoints)
4. Check [Data Models](lld/LOW_LEVEL_DESIGN.md#312-data-model)
5. Read relevant [ADR documents](adr/) for architectural context

### For DevOps Engineers:
1. Review [Deployment Architecture](hld/HIGH_LEVEL_DESIGN.md#9-deployment-architecture)
2. Study [Deployment Diagram](diagrams/C4_DIAGRAMS.md#deployment-diagram)
3. Read [ADR-001: Microservices](adr/ADR-001-microservices-architecture.md)
4. Review [Monitoring Strategy](lld/LOW_LEVEL_DESIGN.md#8-monitoring-and-observability)
5. Check [CI/CD Pipeline](lld/LOW_LEVEL_DESIGN.md#10-deployment-procedures)

### For QA Engineers:
1. Read [Workflow Diagrams](diagrams/WORKFLOW_DIAGRAMS.md) for test scenarios
2. Review [Testing Strategy](lld/LOW_LEVEL_DESIGN.md#9-testing-strategy)
3. Study [API Endpoints](lld/LOW_LEVEL_DESIGN.md) for test cases
4. Check [Error Handling](lld/LOW_LEVEL_DESIGN.md#6-error-handling)

---

## 🔍 Finding Information

### Common Scenarios:

**"How does email classification work?"**
- [HLD: Intelligent Email Management](hld/HIGH_LEVEL_DESIGN.md#31-intelligent-email-management)
- [LLD: Email Service Component](lld/LOW_LEVEL_DESIGN.md#31-email-service)
- [ADR-005: ML Email Classification](adr/ADR-005-machine-learning-email-classification.md)
- [Workflow: Email Processing](diagrams/WORKFLOW_DIAGRAMS.md#1-email-processing-workflow)

**"How do we handle approvals?"**
- [HLD: Approval Workflow Engine](hld/HIGH_LEVEL_DESIGN.md#35-approval-workflow-engine)
- [LLD: Approval Service](lld/LOW_LEVEL_DESIGN.md#35-approval-service)
- [Workflow: Approval State Machine](diagrams/WORKFLOW_DIAGRAMS.md#4-approval-workflow-state-machine)

**"What databases do we use?"**
- [HLD: Technology Stack](hld/HIGH_LEVEL_DESIGN.md#5-technology-stack-overview)
- [ADR-003: Database per Service](adr/ADR-003-database-per-service.md)
- [C4 Container Diagram](diagrams/C4_DIAGRAMS.md#level-2-container-diagram)

**"How is the system deployed?"**
- [HLD: Deployment Architecture](hld/HIGH_LEVEL_DESIGN.md#9-deployment-architecture)
- [Deployment Diagram](diagrams/C4_DIAGRAMS.md#deployment-diagram)
- [LLD: Deployment Procedures](lld/LOW_LEVEL_DESIGN.md#10-deployment-procedures)

**"What APIs are available?"**
- [LLD: API Endpoints](lld/LOW_LEVEL_DESIGN.md) - Each service section has API specs
- [ADR-004: API Gateway](adr/ADR-004-api-gateway-pattern.md)

**"Why did we choose microservices?"**
- [ADR-001: Microservices Architecture](adr/ADR-001-microservices-architecture.md)

---

## 📊 Diagram Formats

All diagrams in this documentation use **Mermaid.js** format, which is:
- **Human-readable:** Text-based diagram definitions
- **Version-controlled:** Can be tracked in Git
- **Widely supported:** GitHub, GitLab, VS Code, documentation tools
- **Easy to maintain:** Update text to update diagram

### Viewing Diagrams:
- **GitHub:** Automatically renders Mermaid diagrams
- **VS Code:** Install "Markdown Preview Mermaid Support" extension
- **Online:** Use [Mermaid Live Editor](https://mermaid.live/)
- **Documentation Sites:** Supported by MkDocs, Docusaurus, etc.

---

## 🔄 Document Maintenance

### Version Control:
- All documents include "Document Control" section at the end
- Version numbers follow semantic versioning
- Last updated date tracked
- Status field (Draft, Review, Approved, Deprecated)

### Review Schedule:
- **HLD:** Quarterly review
- **LLD:** Updated with each major feature
- **ADR:** Created as needed, reviewed when revisiting decisions
- **Diagrams:** Updated when architecture changes

### Contributing:
When updating documentation:
1. Update the relevant section(s)
2. Update "Last Updated" date
3. Increment version number if significant changes
4. Update related diagrams if necessary
5. Cross-reference with other affected documents
6. Submit for review before merging

---

## 🎓 Learning Path

### Week 1 - System Understanding:
- Day 1-2: Read HLD Executive Summary and System Context
- Day 3-4: Study Workflow Diagrams for key processes
- Day 5: Review C4 Context and Container Diagrams

### Week 2 - Technical Deep Dive:
- Day 1-2: Read ADR documents
- Day 3-4: Study LLD for your focus area
- Day 5: Review Component and Code diagrams

### Week 3 - Hands-On:
- Day 1-2: Set up development environment
- Day 3-4: Implement a small feature using documentation
- Day 5: Update documentation with your learnings

---

## 📞 Support and Questions

For questions about this documentation:
- **Technical Clarifications:** Contact Architecture Team
- **Business Context:** Contact Product Management
- **Deployment Questions:** Contact DevOps Team
- **API Usage:** Refer to API documentation in LLD

---

## 📄 Document Versions

| Document | Version | Last Updated | Status |
|----------|---------|--------------|--------|
| HLD | 1.0 | 2025-11-24 | Draft for Review |
| LLD | 1.0 | 2025-11-24 | Draft for Review |
| ADR-001 | 1.0 | 2025-11-24 | Accepted |
| ADR-002 | 1.0 | 2025-11-24 | Accepted |
| ADR-003 | 1.0 | 2025-11-24 | Accepted |
| ADR-004 | 1.0 | 2025-11-24 | Accepted |
| ADR-005 | 1.0 | 2025-11-24 | Accepted |
| ADR-006 | 1.0 | 2025-11-24 | Accepted |
| **C4 Diagrams** | **2.0** | **2025-11-24** | **Complete - All Services** |
| Workflow Diagrams | 1.0 | 2025-11-24 | Draft for Review |

---

## 🔗 External References

- **C4 Model:** https://c4model.com/
- **Mermaid.js:** https://mermaid.js.org/
- **ADR Process:** https://adr.github.io/
- **Microservices Patterns:** https://microservices.io/
- **12-Factor Apps:** https://12factor.net/

---

**This documentation was generated to support the Heavy Machinery Dealer Management System development and maintenance. It is a living document that should evolve with the system.**
