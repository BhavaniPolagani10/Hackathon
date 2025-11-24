# C4 Architecture Diagrams
## Heavy Machinery Dealer Management System

This document contains C4 model diagrams (Context, Container, Component, and Code) in Mermaid format to visualize the system architecture at different levels of abstraction.

---

## Level 1: System Context Diagram

Shows the system in its environment with external actors and systems.

```mermaid
graph TB
    subgraph ExternalActors[External Actors]
        Customer[Customer<br/>End customer looking for<br/>heavy machinery]
        SalesRep[Sales Representative<br/>Manages customer relationships<br/>Creates quotes]
        SalesManager[Sales Manager<br/>Oversees team<br/>Approves deals]
        InventoryMgr[Inventory Manager<br/>Manages stock<br/>across locations]
    end
    
    DealerSystem[Heavy Machinery Dealer<br/>Management System<br/><br/>Centralizes sales operations<br/>Automates workflows<br/>Improves response time]
    
    subgraph ExternalSystems[External Systems]
        ERP[ERP System<br/><br/>Stores financial data<br/>Customer history<br/>Machine records]
        EmailSys[Email System<br/><br/>Gmail / Outlook<br/>Customer communications]
        Manufacturer[Manufacturer API<br/><br/>Machine specifications<br/>Inventory updates<br/>Order processing]
    end
    
    Customer -->|Sends inquiries<br/>Requests quotes| DealerSystem
    DealerSystem -->|Sends quotes<br/>Order confirmations| Customer
    
    SalesRep -->|Creates quotes<br/>Manages deals<br/>Views inventory| DealerSystem
    SalesManager -->|Reviews dashboard<br/>Approves discounts| DealerSystem
    InventoryMgr -->|Updates stock<br/>Manages locations| DealerSystem
    
    DealerSystem -->|Queries customer data<br/>Machine history| ERP
    ERP -->|Returns financial data| DealerSystem
    
    DealerSystem <-->|Syncs emails<br/>Sends notifications| EmailSys
    
    DealerSystem -->|Submits purchase orders<br/>Queries specifications| Manufacturer
    Manufacturer -->|Confirms orders<br/>Updates inventory| DealerSystem
    
    style DealerSystem fill:#4A90E2,stroke:#2E5C8A,stroke-width:3px,color:#fff
    style Customer fill:#90EE90,stroke:#228B22,stroke-width:2px
    style SalesRep fill:#FFD700,stroke:#DAA520,stroke-width:2px
    style SalesManager fill:#FFD700,stroke:#DAA520,stroke-width:2px
    style InventoryMgr fill:#FFD700,stroke:#DAA520,stroke-width:2px
```

---

## Level 2: Container Diagram

Shows the high-level technology choices and how containers communicate.

```mermaid
graph TB
    subgraph Users[Users and External Systems]
        User[User<br/>Browser/Mobile]
        EmailSystem[Email System]
        ERPSystem[ERP System]
        ManufacturerAPI[Manufacturer API]
    end
    
    subgraph FrontendContainers[Frontend Layer]
        WebApp[Web Application<br/><br/>React SPA<br/>Port 3000<br/>User interface for<br/>all operations]
        MobileApp[Mobile App<br/><br/>Progressive Web App<br/>Offline-capable<br/>Field access]
    end
    
    subgraph APILayer[API Layer]
        APIGateway[API Gateway<br/><br/>Kong<br/>Port 8000<br/>Authentication<br/>Rate limiting<br/>Request routing]
    end
    
    subgraph BackendServices[Backend Services - Microservices]
        EmailService[Email Service<br/><br/>Python FastAPI<br/>Port 8001<br/>Email processing<br/>ML classification<br/>Priority scoring]
        
        CustomerService[Customer Service<br/><br/>Python FastAPI<br/>Port 8002<br/>Customer data<br/>360 degree view<br/>History tracking]
        
        QuoteService[Quote Service<br/><br/>Python FastAPI<br/>Port 8003<br/>Quote generation<br/>Configuration<br/>Pricing engine]
        
        InventoryService[Inventory Service<br/><br/>Python FastAPI<br/>Port 8004<br/>Stock management<br/>Multi-warehouse<br/>Reservations]
        
        ApprovalService[Approval Service<br/><br/>Python FastAPI<br/>Port 8005<br/>Workflow engine<br/>Multi-level approvals]
        
        POService[Purchase Order Service<br/><br/>Python FastAPI<br/>Port 8006<br/>PO automation<br/>Template generation]
        
        PipelineService[Pipeline Service<br/><br/>Python FastAPI<br/>Port 8007<br/>Deal tracking<br/>Forecasting<br/>Analytics]
        
        NotificationService[Notification Service<br/><br/>Node.js<br/>Port 8008<br/>Real-time notifications<br/>WebSocket support]
    end
    
    subgraph DataLayer[Data Layer]
        PostgreSQL[(PostgreSQL<br/><br/>Port 5432<br/>Transactional data<br/>Customers, Quotes<br/>Inventory, Deals)]
        
        MongoDB[(MongoDB<br/><br/>Port 27017<br/>Document storage<br/>Emails<br/>Attachments)]
        
        Redis[(Redis<br/><br/>Port 6379<br/>Cache layer<br/>Sessions<br/>Rate limiting)]
        
        Elasticsearch[(Elasticsearch<br/><br/>Port 9200<br/>Full-text search<br/>Analytics<br/>Logging)]
        
        S3[S3 Object Storage<br/><br/>HTTPS<br/>Documents<br/>PDFs<br/>Attachments]
    end
    
    subgraph MessageLayer[Message Layer]
        RabbitMQ[RabbitMQ<br/><br/>Port 5672<br/>Event bus<br/>Async messaging<br/>Pub/Sub]
    end
    
    User -->|HTTPS| WebApp
    User -->|HTTPS| MobileApp
    
    WebApp -->|REST API<br/>JSON/HTTPS| APIGateway
    MobileApp -->|REST API<br/>JSON/HTTPS| APIGateway
    
    APIGateway -->|HTTP| EmailService
    APIGateway -->|HTTP| CustomerService
    APIGateway -->|HTTP| QuoteService
    APIGateway -->|HTTP| InventoryService
    APIGateway -->|HTTP| ApprovalService
    APIGateway -->|HTTP| POService
    APIGateway -->|HTTP| PipelineService
    APIGateway -->|WebSocket| NotificationService
    
    EmailService -->|Read/Write| PostgreSQL
    EmailService -->|Read/Write| MongoDB
    EmailService -->|Publish events| RabbitMQ
    EmailService -->|IMAP/SMTP| EmailSystem
    
    CustomerService -->|Read/Write| PostgreSQL
    CustomerService -->|Cache| Redis
    CustomerService -->|REST API| ERPSystem
    
    QuoteService -->|Read/Write| PostgreSQL
    QuoteService -->|Cache| Redis
    QuoteService -->|Store PDFs| S3
    QuoteService -->|Publish events| RabbitMQ
    
    InventoryService -->|Read/Write| PostgreSQL
    InventoryService -->|Cache| Redis
    InventoryService -->|Sync data| ERPSystem
    
    ApprovalService -->|Read/Write| PostgreSQL
    ApprovalService -->|Publish events| RabbitMQ
    
    POService -->|Read/Write| PostgreSQL
    POService -->|Store PDFs| S3
    POService -->|Submit orders| ManufacturerAPI
    
    PipelineService -->|Read/Write| PostgreSQL
    PipelineService -->|Search| Elasticsearch
    
    NotificationService -->|Subscribe events| RabbitMQ
    NotificationService -->|Cache| Redis
    
    style APIGateway fill:#FF6B6B,stroke:#C92A2A,stroke-width:2px
    style WebApp fill:#4ECDC4,stroke:#2C7A7B,stroke-width:2px
    style MobileApp fill:#4ECDC4,stroke:#2C7A7B,stroke-width:2px
```

---

## Level 3: Component Diagram - Email Service

Detailed view of Email Service internal components.

```mermaid
graph TB
    subgraph EmailService[Email Service Container]
        direction TB
        
        APIController[API Controller<br/><br/>REST endpoints<br/>Request validation<br/>Response formatting]
        
        EmailReceiver[Email Receiver<br/><br/>IMAP client<br/>Email polling<br/>Webhook handling]
        
        EmailClassifier[Email Classifier<br/><br/>ML integration<br/>Feature extraction<br/>Category assignment]
        
        PriorityScorer[Priority Scorer<br/><br/>Rule engine<br/>Customer scoring<br/>Urgency detection]
        
        EmailRouter[Email Router<br/><br/>Assignment logic<br/>Load balancing<br/>Availability check]
        
        EmailSender[Email Sender<br/><br/>SMTP client<br/>Template engine<br/>Delivery tracking]
        
        StorageManager[Storage Manager<br/><br/>Database operations<br/>Attachment handling<br/>Archive management]
        
        EventPublisher[Event Publisher<br/><br/>Message formatting<br/>Event publishing<br/>Retry logic]
    end
    
    ExternalEmail[External Email System]
    MLModelService[ML Model Service]
    DatabasePostgres[(PostgreSQL)]
    DatabaseMongo[(MongoDB)]
    MessageQueue[RabbitMQ]
    ObjectStorage[S3 Storage]
    
    APIController --> EmailReceiver
    APIController --> EmailSender
    APIController --> StorageManager
    
    EmailReceiver -->|Fetch emails| ExternalEmail
    EmailReceiver --> EmailClassifier
    
    EmailClassifier -->|Call model| MLModelService
    EmailClassifier --> PriorityScorer
    
    PriorityScorer --> EmailRouter
    
    EmailRouter --> StorageManager
    EmailRouter --> EventPublisher
    
    EmailSender -->|Send email| ExternalEmail
    EmailSender --> StorageManager
    
    StorageManager -->|Store metadata| DatabasePostgres
    StorageManager -->|Store content| DatabaseMongo
    StorageManager -->|Store files| ObjectStorage
    
    EventPublisher -->|Publish| MessageQueue
    
    style EmailClassifier fill:#95E1D3,stroke:#38A3A5,stroke-width:2px
    style PriorityScorer fill:#F38181,stroke:#AA4465,stroke-width:2px
    style EmailRouter fill:#EAFFD0,stroke:#95E77D,stroke-width:2px
```

---

## Level 3: Component Diagram - Quote Service

Detailed view of Quote Service internal components.

```mermaid
graph TB
    subgraph QuoteService[Quote Service Container]
        direction TB
        
        QuoteAPIController[Quote API Controller<br/><br/>CRUD operations<br/>Input validation<br/>Error handling]
        
        QuoteBuilder[Quote Builder<br/><br/>Quote creation<br/>Line item management<br/>Customer linking]
        
        ConfigValidator[Configuration Validator<br/><br/>Rule engine<br/>Compatibility checks<br/>Constraint validation]
        
        PricingEngine[Pricing Engine<br/><br/>Price calculation<br/>Discount application<br/>Tax computation]
        
        TemplateEngine[Template Engine<br/><br/>PDF generation<br/>HTML rendering<br/>Branding application]
        
        ApprovalIntegration[Approval Integration<br/><br/>Approval requests<br/>Status tracking<br/>Notification handling]
        
        QuoteRepository[Quote Repository<br/><br/>Data access layer<br/>Transaction management<br/>Audit logging]
        
        CacheManager[Cache Manager<br/><br/>Cache operations<br/>Invalidation logic<br/>TTL management]
    end
    
    CustomerServiceAPI[Customer Service]
    InventoryServiceAPI[Inventory Service]
    ApprovalServiceAPI[Approval Service]
    
    DatabasePostgres[(PostgreSQL)]
    CacheRedis[(Redis)]
    StorageS3[S3 Storage]
    EventBus[RabbitMQ]
    
    QuoteAPIController --> QuoteBuilder
    QuoteAPIController --> QuoteRepository
    
    QuoteBuilder --> ConfigValidator
    QuoteBuilder -->|Get customer data| CustomerServiceAPI
    
    ConfigValidator --> PricingEngine
    
    PricingEngine --> QuoteRepository
    PricingEngine --> CacheManager
    
    QuoteBuilder --> TemplateEngine
    
    TemplateEngine -->|Store PDF| StorageS3
    
    QuoteBuilder --> ApprovalIntegration
    ApprovalIntegration -->|Request approval| ApprovalServiceAPI
    
    QuoteBuilder -->|Check stock| InventoryServiceAPI
    
    QuoteRepository -->|Read/Write| DatabasePostgres
    CacheManager -->|Cache ops| CacheRedis
    
    QuoteBuilder -->|Publish events| EventBus
    
    style ConfigValidator fill:#FFB6B9,stroke:#FE8A8A,stroke-width:2px
    style PricingEngine fill:#BAE8E8,stroke:#2D9CDB,stroke-width:2px
    style TemplateEngine fill:#FFFFDD,stroke:#FFD93D,stroke-width:2px
```

---

## Level 3: Component Diagram - Inventory Service

Detailed view of Inventory Service internal components.

```mermaid
graph TB
    subgraph InventoryService[Inventory Service Container]
        direction TB
        
        InventoryAPIController[Inventory API Controller<br/><br/>Stock queries<br/>Availability checks<br/>Reservation management]
        
        StockManager[Stock Manager<br/><br/>Inventory CRUD<br/>Quantity updates<br/>Location management]
        
        ReservationEngine[Reservation Engine<br/><br/>Stock reservation<br/>Release logic<br/>Expiry handling]
        
        AvailabilityCalculator[Availability Calculator<br/><br/>Real-time availability<br/>Multi-warehouse check<br/>Delivery estimation]
        
        ERPSyncManager[ERP Sync Manager<br/><br/>Data synchronization<br/>Conflict resolution<br/>Batch processing]
        
        AlertEngine[Alert Engine<br/><br/>Low stock alerts<br/>Reorder notifications<br/>Expiry warnings]
        
        InventoryRepository[Inventory Repository<br/><br/>Data persistence<br/>Transaction handling<br/>Audit trail]
        
        CacheManager[Cache Manager<br/><br/>Inventory cache<br/>Invalidation<br/>Refresh logic]
    end
    
    ERPSystemAPI[ERP System]
    DatabasePostgres[(PostgreSQL)]
    CacheRedis[(Redis)]
    EventBus[RabbitMQ]
    
    InventoryAPIController --> StockManager
    InventoryAPIController --> ReservationEngine
    InventoryAPIController --> AvailabilityCalculator
    
    StockManager --> InventoryRepository
    StockManager --> CacheManager
    StockManager --> AlertEngine
    
    ReservationEngine --> InventoryRepository
    ReservationEngine -->|Lock mechanism| CacheRedis
    
    AvailabilityCalculator --> InventoryRepository
    AvailabilityCalculator --> CacheManager
    
    ERPSyncManager -->|Sync data| ERPSystemAPI
    ERPSyncManager --> InventoryRepository
    
    AlertEngine -->|Publish alerts| EventBus
    
    InventoryRepository -->|Read/Write| DatabasePostgres
    CacheManager -->|Cache ops| CacheRedis
    
    StockManager -->|Publish events| EventBus
    ReservationEngine -->|Publish events| EventBus
    
    style ReservationEngine fill:#C7CEEA,stroke:#B8B8D1,stroke-width:2px
    style AvailabilityCalculator fill:#FFC8DD,stroke:#FFAFCC,stroke-width:2px
    style ERPSyncManager fill:#D8F3DC,stroke:#95D5B2,stroke-width:2px
```

---

## Level 4: Code Diagram - Email Classification

Shows key classes and their relationships in the email classification logic.

```mermaid
classDiagram
    class EmailClassificationService {
        -MLModelClient model_client
        -EmailRepository repository
        -EventPublisher event_publisher
        +classify_email(email_id) ClassificationResult
        +batch_classify(email_ids) List~ClassificationResult~
        -extract_features(email) FeatureVector
        -apply_rules(email) Category
    }
    
    class MLModelClient {
        -str model_endpoint
        -int timeout_seconds
        -Cache result_cache
        +predict(features) Prediction
        +predict_batch(features_list) List~Prediction~
        -preprocess_text(text) ProcessedText
        -get_embeddings(text) Vector
    }
    
    class FeatureExtractor {
        -KeywordExtractor keyword_extractor
        -SenderAnalyzer sender_analyzer
        +extract_subject_features(subject) Features
        +extract_body_features(body) Features
        +extract_metadata_features(email) Features
        +extract_attachment_features(attachments) Features
        -tokenize(text) List~Token~
        -calculate_tfidf(tokens) Vector
    }
    
    class PriorityScorer {
        -CustomerRepository customer_repo
        -RuleEngine rule_engine
        -int base_priority_weight
        +calculate_priority(email, category) int
        -get_customer_score(customer_id) int
        -detect_urgency_keywords(text) int
        -calculate_recency_score(last_contact) int
    }
    
    class EmailRouter {
        -SalesRepRepository sales_rep_repo
        -LoadBalancer load_balancer
        +assign_to_rep(email, priority) Assignment
        +rebalance_assignments() void
        -find_available_rep(category) SalesRep
        -calculate_rep_load(rep_id) int
    }
    
    class ClassificationResult {
        +UUID email_id
        +Category category
        +float confidence
        +int priority_score
        +UUID assigned_to
        +DateTime classified_at
        +validate() bool
    }
    
    class Email {
        +UUID email_id
        +str subject
        +str body
        +str from_address
        +List~Attachment~ attachments
        +DateTime received_at
        +Category category
        +int priority
    }
    
    class Category {
        <<enumeration>>
        INQUIRY
        SERVICE
        TENDER
        SUPPLIER
        SPAM
        MANUAL_REVIEW
    }
    
    class Prediction {
        +Category category
        +float confidence
        +Dict~str_float~ probabilities
        +List~str~ key_features
    }
    
    EmailClassificationService --> MLModelClient : uses
    EmailClassificationService --> FeatureExtractor : uses
    EmailClassificationService --> PriorityScorer : uses
    EmailClassificationService --> EmailRouter : uses
    EmailClassificationService --> ClassificationResult : creates
    
    MLModelClient --> Prediction : returns
    FeatureExtractor --> Email : processes
    PriorityScorer --> Email : analyzes
    PriorityScorer --> ClassificationResult : enriches
    EmailRouter --> ClassificationResult : updates
    
    ClassificationResult --> Category : contains
    Email --> Category : categorized_as
    Prediction --> Category : predicts
```

---

## Level 4: Code Diagram - Quote Calculation

Shows key classes involved in quote price calculation.

```mermaid
classDiagram
    class QuoteCalculationService {
        -PricingEngine pricing_engine
        -ProductCatalog product_catalog
        -DiscountManager discount_manager
        -TaxCalculator tax_calculator
        +calculate_quote(quote_id) CalculationResult
        +recalculate_on_change(quote_id, changes) CalculationResult
        -validate_configuration(config) ValidationResult
    }
    
    class PricingEngine {
        -PricingRuleRepository rule_repo
        -Cache price_cache
        +calculate_line_item_price(line_item) Decimal
        +apply_quantity_discount(quantity, price) Decimal
        +get_configuration_cost(config) Decimal
        -load_pricing_rules(product) List~PricingRule~
    }
    
    class ProductCatalog {
        -ProductRepository product_repo
        -Cache catalog_cache
        +get_product(product_code) Product
        +get_base_price(product_code) Decimal
        +get_configuration_options(product_code) List~Option~
        +validate_configuration(config) bool
    }
    
    class MachineConfiguration {
        +str base_model
        +str bucket_size
        +str tire_type
        +str attachment_1
        +str attachment_2
        +str warranty_package
        +validate() List~ValidationError~
        +get_cost_additions() Decimal
    }
    
    class ConfigurationValidator {
        -CompatibilityRules rules
        +validate(config) ValidationResult
        -check_bucket_compatibility(model, bucket) bool
        -check_tire_compatibility(model, tire) bool
        -check_attachment_compatibility(att1, att2) bool
    }
    
    class DiscountManager {
        -ApprovalService approval_service
        -DiscountRuleRepository rule_repo
        +calculate_discount(quote, discount_pct) Decimal
        +requires_approval(discount_pct, amount) bool
        +request_approval(quote, discount) ApprovalRequest
    }
    
    class TaxCalculator {
        -TaxRateRepository tax_repo
        +calculate_tax(amount, jurisdiction) Decimal
        +get_tax_rate(jurisdiction) Decimal
        -determine_jurisdiction(customer) str
    }
    
    class Quote {
        +UUID quote_id
        +UUID customer_id
        +List~QuoteLineItem~ line_items
        +Decimal subtotal
        +Decimal discount_amount
        +Decimal tax_amount
        +Decimal total_amount
        +calculate_totals() void
    }
    
    class QuoteLineItem {
        +UUID line_item_id
        +str product_code
        +int quantity
        +Decimal unit_price
        +Decimal discount_percent
        +MachineConfiguration configuration
        +Decimal line_total
        +calculate_line_total() Decimal
    }
    
    class CalculationResult {
        +UUID quote_id
        +Decimal subtotal
        +Decimal total_discount
        +Decimal tax_amount
        +Decimal grand_total
        +List~LineItemResult~ line_items
        +bool requires_approval
        +DateTime calculated_at
    }
    
    QuoteCalculationService --> PricingEngine : uses
    QuoteCalculationService --> ProductCatalog : uses
    QuoteCalculationService --> DiscountManager : uses
    QuoteCalculationService --> TaxCalculator : uses
    QuoteCalculationService --> ConfigurationValidator : uses
    
    PricingEngine --> ProductCatalog : queries
    PricingEngine --> QuoteLineItem : calculates
    
    ConfigurationValidator --> MachineConfiguration : validates
    
    QuoteCalculationService --> CalculationResult : produces
    Quote --> QuoteLineItem : contains
    QuoteLineItem --> MachineConfiguration : has
    
    DiscountManager --> Quote : analyzes
    TaxCalculator --> Quote : calculates_for
```

---

## Deployment Diagram

Shows how the system is deployed in cloud infrastructure.

```mermaid
graph TB
    subgraph CloudProvider[Cloud Provider - AWS/Azure]
        subgraph LoadBalancing[Load Balancing Layer]
            ALB[Application Load Balancer<br/>HTTPS Termination<br/>SSL Certificates]
        end
        
        subgraph ComputeLayer[Compute Layer - Kubernetes Cluster]
            subgraph FrontendPods[Frontend Pods]
                WebPod1[Web App Pod 1]
                WebPod2[Web App Pod 2]
            end
            
            subgraph ServicePods[Microservice Pods]
                EmailPod1[Email Service Pod]
                EmailPod2[Email Service Pod]
                CustomerPod[Customer Service Pod]
                QuotePod[Quote Service Pod]
                InventoryPod[Inventory Service Pod]
                ApprovalPod[Approval Service Pod]
                POPod[PO Service Pod]
                PipelinePod[Pipeline Service Pod]
                NotificationPod[Notification Service Pod]
            end
            
            GatewayPod[API Gateway Pod]
        end
        
        subgraph DataLayer[Data Layer - Managed Services]
            RDSPostgres[RDS PostgreSQL<br/>Multi-AZ<br/>Automated Backups]
            
            DocumentDB[DocumentDB<br/>MongoDB Compatible<br/>3-node cluster]
            
            ElastiCache[ElastiCache Redis<br/>Cluster Mode<br/>5 Shards]
            
            OpenSearch[OpenSearch<br/>Elasticsearch Compatible<br/>3-node cluster]
        end
        
        subgraph StorageLayer[Storage Layer]
            S3Bucket[S3 Bucket<br/>Documents & PDFs<br/>Lifecycle Policies<br/>Versioning Enabled]
        end
        
        subgraph MessagingLayer[Messaging Layer]
            AmazonMQ[Amazon MQ<br/>RabbitMQ<br/>Active/Standby]
        end
        
        subgraph MonitoringLayer[Monitoring & Logging]
            CloudWatch[CloudWatch<br/>Metrics & Logs]
            Prometheus[Prometheus<br/>Metrics Collection]
            Grafana[Grafana<br/>Dashboards]
            Jaeger[Jaeger<br/>Distributed Tracing]
        end
    end
    
    Internet[Internet Users]
    
    Internet -->|HTTPS| ALB
    ALB --> GatewayPod
    
    GatewayPod --> WebPod1
    GatewayPod --> WebPod2
    
    GatewayPod --> EmailPod1
    GatewayPod --> EmailPod2
    GatewayPod --> CustomerPod
    GatewayPod --> QuotePod
    GatewayPod --> InventoryPod
    GatewayPod --> ApprovalPod
    GatewayPod --> POPod
    GatewayPod --> PipelinePod
    GatewayPod --> NotificationPod
    
    EmailPod1 --> RDSPostgres
    EmailPod2 --> RDSPostgres
    EmailPod1 --> DocumentDB
    EmailPod2 --> DocumentDB
    
    CustomerPod --> RDSPostgres
    CustomerPod --> ElastiCache
    
    QuotePod --> RDSPostgres
    QuotePod --> ElastiCache
    QuotePod --> S3Bucket
    
    InventoryPod --> RDSPostgres
    InventoryPod --> ElastiCache
    
    ApprovalPod --> RDSPostgres
    POPod --> RDSPostgres
    POPod --> S3Bucket
    
    PipelinePod --> RDSPostgres
    PipelinePod --> OpenSearch
    
    NotificationPod --> ElastiCache
    
    EmailPod1 --> AmazonMQ
    EmailPod2 --> AmazonMQ
    QuotePod --> AmazonMQ
    ApprovalPod --> AmazonMQ
    NotificationPod --> AmazonMQ
    
    ServicePods --> CloudWatch
    ServicePods --> Prometheus
    Prometheus --> Grafana
    ServicePods --> Jaeger
    
    style ALB fill:#FF9800,stroke:#F57C00,stroke-width:3px
    style GatewayPod fill:#FF6B6B,stroke:#C92A2A,stroke-width:2px
    style RDSPostgres fill:#4CAF50,stroke:#388E3C,stroke-width:2px
    style DocumentDB fill:#4CAF50,stroke:#388E3C,stroke-width:2px
    style ElastiCache fill:#E91E63,stroke:#C2185B,stroke-width:2px
```

---

**Document Control:**
- Version: 1.0
- Last Updated: 2025-11-24
- Diagram Format: Mermaid
- Tool Compatibility: GitHub, VS Code, Mermaid Live Editor
