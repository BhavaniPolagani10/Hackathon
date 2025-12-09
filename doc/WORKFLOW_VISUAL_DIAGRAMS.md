# GitHub Actions Workflow Visual Diagrams
## Heavy Machinery Dealer Management System

---

## Document Information
- **Document Version:** 1.0
- **Date:** December 2025
- **Status:** Final
- **Related Document:** WORKFLOW_AND_AGENTS_DESIGN.md

---

## Table of Contents

1. [Complete CI/CD Pipeline Overview](#1-complete-cicd-pipeline-overview)
2. [Frontend Workflow Detailed Flow](#2-frontend-workflow-detailed-flow)
3. [Backend Microservices Workflow](#3-backend-microservices-workflow)
4. [Security Scanning Pipeline](#4-security-scanning-pipeline)
5. [Release Management Flow](#5-release-management-flow)
6. [Agent Interaction Diagram](#6-agent-interaction-diagram)

---

## 1. Complete CI/CD Pipeline Overview

### 1.1 High-Level Pipeline Flow

```mermaid
graph TB
    Start[Developer Commit] --> PR[Create Pull Request]
    PR --> CodeQuality[Code Quality Check]
    CodeQuality --> Tests[Run Tests]
    Tests --> Security[Security Scan]
    Security --> Build[Build Artifacts]
    Build --> PRReview{PR Approved?}
    
    PRReview -->|Yes| Merge[Merge to Main]
    PRReview -->|No| FixIssues[Fix Issues]
    FixIssues --> PR
    
    Merge --> DeployStaging[Deploy to Staging]
    DeployStaging --> E2E[E2E Tests]
    E2E --> PerfTest[Performance Tests]
    PerfTest --> StagingValidation{Staging OK?}
    
    StagingValidation -->|Yes| ProdApproval{Manual Approval}
    StagingValidation -->|No| Rollback[Rollback Staging]
    Rollback --> Investigate[Investigate]
    
    ProdApproval -->|Approved| DeployProd[Deploy to Production]
    ProdApproval -->|Rejected| End[End]
    
    DeployProd --> ProdMonitor[Monitor Production]
    ProdMonitor --> ProdHealth{Health Check}
    
    ProdHealth -->|Pass| Success[Deployment Success]
    ProdHealth -->|Fail| ProdRollback[Rollback Production]
    
    Success --> End
    ProdRollback --> Investigate
    Investigate --> End
    
    style Start fill:#90EE90
    style Success fill:#90EE90
    style ProdRollback fill:#FF6B6B
    style Rollback fill:#FF6B6B
    style ProdApproval fill:#FFD700
```

---

## 2. Frontend Workflow Detailed Flow

### 2.1 Frontend CI/CD Complete Pipeline

```mermaid
graph TB
    subgraph "Code Quality"
        A1[ESLint Check] --> A2[Prettier Format]
        A2 --> A3[TypeScript Check]
        A3 --> A4{Quality Pass?}
    end
    
    subgraph "Testing"
        B1[Unit Tests] --> B2[Integration Tests]
        B2 --> B3[Coverage Report]
        B3 --> B4{Coverage > 80%?}
    end
    
    subgraph "Build"
        C1[Install Dependencies] --> C2[Build Production]
        C2 --> C3[Bundle Analysis]
        C3 --> C4{Size < 2MB?}
    end
    
    subgraph "Security"
        D1[npm Audit] --> D2[SAST Scan]
        D2 --> D3[License Check]
        D3 --> D4{Security OK?}
    end
    
    subgraph "Deploy Staging"
        E1[Upload to CDN] --> E2[Invalidate Cache]
        E2 --> E3[Smoke Tests]
        E3 --> E4{Staging OK?}
    end
    
    subgraph "E2E Testing"
        F1[Run Playwright] --> F2[Cross-Browser]
        F2 --> F3[Visual Regression]
        F3 --> F4{E2E Pass?}
    end
    
    subgraph "Deploy Production"
        G1[Manual Approval] --> G2[Deploy to CDN]
        G2 --> G3[Invalidate Cache]
        G3 --> G4[Health Check]
        G4 --> G5{Production OK?}
    end
    
    A4 -->|Pass| B1
    A4 -->|Fail| Fail[Fail Pipeline]
    B4 -->|Pass| C1
    B4 -->|Fail| Fail
    C4 -->|Pass| D1
    C4 -->|Fail| Fail
    D4 -->|Pass| E1
    D4 -->|Fail| Fail
    E4 -->|Pass| F1
    E4 -->|Fail| Fail
    F4 -->|Pass| G1
    F4 -->|Fail| Fail
    G5 -->|Pass| Success[Success]
    G5 -->|Fail| Rollback[Rollback]
    
    style Success fill:#90EE90
    style Fail fill:#FF6B6B
    style Rollback fill:#FFD700
```

### 2.2 Frontend Performance Testing Flow

```mermaid
sequenceDiagram
    participant Dev as Developer
    participant GH as GitHub Actions
    participant Build as Build Agent
    participant Lighthouse as Lighthouse CI
    participant CDN as Staging CDN
    participant Reporter as Report Generator
    
    Dev->>GH: Push Code
    GH->>Build: Trigger Build
    Build->>Build: npm install
    Build->>Build: npm run build
    Build->>CDN: Deploy to Staging
    
    GH->>Lighthouse: Run Performance Tests
    Lighthouse->>CDN: Load Application
    Lighthouse->>Lighthouse: Measure Core Web Vitals
    Lighthouse->>Lighthouse: Calculate Scores
    Lighthouse->>Reporter: Send Results
    
    Reporter->>Reporter: Compare with Baseline
    Reporter->>Reporter: Generate Report
    Reporter->>GH: Post Results
    
    alt Performance Regression
        GH->>Dev: Alert via PR Comment
        GH->>GH: Block Merge
    else Performance OK
        GH->>Dev: Approve
    end
```

---

## 3. Backend Microservices Workflow

### 3.1 Multi-Service Build Pipeline

```mermaid
graph TB
    subgraph "Change Detection"
        A1[Git Diff Analysis] --> A2[Build Dependency Graph]
        A2 --> A3[Determine Build Order]
    end
    
    subgraph "Service 1: Email Service"
        S1A[Lint Code] --> S1B[Run Tests]
        S1B --> S1C[Build Image]
        S1C --> S1D[Scan Image]
    end
    
    subgraph "Service 2: Quote Service"
        S2A[Lint Code] --> S2B[Run Tests]
        S2B --> S2C[Build Image]
        S2C --> S2D[Scan Image]
    end
    
    subgraph "Service 3: Inventory Service"
        S3A[Lint Code] --> S3B[Run Tests]
        S3B --> S3C[Build Image]
        S3C --> S3D[Scan Image]
    end
    
    subgraph "Integration Tests"
        I1[Start Test Containers] --> I2[Run Integration Tests]
        I2 --> I3[API Contract Tests]
        I3 --> I4[Service Communication Tests]
    end
    
    subgraph "Deployment"
        D1[Update K8s Manifests] --> D2[Apply to Staging]
        D2 --> D3[Health Checks]
        D3 --> D4{All Healthy?}
    end
    
    A3 --> S1A
    A3 --> S2A
    A3 --> S3A
    
    S1D --> I1
    S2D --> I1
    S3D --> I1
    
    I4 --> D1
    
    D4 -->|Yes| Success[Deploy Complete]
    D4 -->|No| Rollback[Rollback Changes]
    
    style Success fill:#90EE90
    style Rollback fill:#FF6B6B
```

### 3.2 Service Dependency Matrix

```mermaid
graph LR
    subgraph "External"
        ERP[ERP System]
        Email[Email Server]
        Vendor[Vendor APIs]
    end
    
    subgraph "Core Services"
        API[API Gateway]
        Email_Svc[Email Service]
        Quote_Svc[Quote Service]
        Inv_Svc[Inventory Service]
        Cust_Svc[Customer Service]
        Appr_Svc[Approval Service]
        PO_Svc[PO Service]
    end
    
    subgraph "Data Services"
        Analytics[Analytics Service]
        Doc[Document Service]
        Notif[Notification Service]
    end
    
    ERP --> Inv_Svc
    Email --> Email_Svc
    Vendor --> PO_Svc
    
    API --> Email_Svc
    API --> Quote_Svc
    API --> Inv_Svc
    API --> Cust_Svc
    
    Quote_Svc --> Inv_Svc
    Quote_Svc --> Cust_Svc
    Quote_Svc --> Appr_Svc
    
    PO_Svc --> Quote_Svc
    PO_Svc --> Inv_Svc
    PO_Svc --> Notif
    
    Email_Svc --> Analytics
    Quote_Svc --> Doc
    PO_Svc --> Doc
```

---

## 4. Security Scanning Pipeline

### 4.1 Comprehensive Security Workflow

```mermaid
graph TB
    Start[Code Commit] --> ParallelScan{Parallel Security Scans}
    
    subgraph "Dependency Scanning"
        D1[npm audit] --> D2[Snyk Scan]
        D2 --> D3[GitHub Advisory Check]
        D3 --> D4{Vulnerabilities?}
    end
    
    subgraph "Static Analysis"
        S1[CodeQL Analysis] --> S2[Semgrep Rules]
        S2 --> S3[Custom Rules]
        S3 --> S4{Issues Found?}
    end
    
    subgraph "Secret Scanning"
        SS1[GitLeaks Scan] --> SS2[TruffleHog]
        SS2 --> SS3[Custom Patterns]
        SS3 --> SS4{Secrets Found?}
    end
    
    subgraph "Container Scanning"
        C1[Build Image] --> C2[Trivy Scan]
        C2 --> C3[Base Image Check]
        C3 --> C4{CVEs Found?}
    end
    
    subgraph "License Compliance"
        L1[Extract Licenses] --> L2[Check Compatibility]
        L2 --> L3[Policy Validation]
        L3 --> L4{Compliant?}
    end
    
    ParallelScan --> D1
    ParallelScan --> S1
    ParallelScan --> SS1
    ParallelScan --> C1
    ParallelScan --> L1
    
    D4 -->|Critical| Block[Block Merge]
    D4 -->|Low/Med| Report[Create Issue]
    S4 -->|Critical| Block
    S4 -->|Low/Med| Report
    SS4 -->|Found| Block
    SS4 -->|None| Continue
    C4 -->|Critical| Block
    C4 -->|Low/Med| Report
    L4 -->|Non-compliant| Block
    L4 -->|Compliant| Continue
    
    Continue --> DAST[DAST Scan on Staging]
    Report --> DAST
    
    DAST --> DASTResult{DAST Results}
    DASTResult -->|Pass| Success[Security Approved]
    DASTResult -->|Fail| Block
    
    Block --> Alert[Alert Security Team]
    Alert --> End[Block Deployment]
    Success --> End2[Approve Deployment]
    
    style Block fill:#FF6B6B
    style Success fill:#90EE90
```

### 4.2 Vulnerability Management Flow

```mermaid
sequenceDiagram
    participant Scan as Security Scanner
    participant GH as GitHub Actions
    participant DB as Advisory DB
    participant Issue as Issue Tracker
    participant Dev as Developer
    participant Sec as Security Team
    
    Scan->>DB: Check for CVEs
    DB->>Scan: Return Vulnerabilities
    
    alt Critical Vulnerability
        Scan->>GH: Block Pipeline
        GH->>Issue: Create Critical Issue
        Issue->>Sec: Alert Security Team
        Issue->>Dev: Assign to Developer
        Sec->>Dev: Review & Prioritize
        Dev->>Dev: Fix Vulnerability
        Dev->>GH: Submit Fix PR
        GH->>Scan: Re-scan
        Scan->>GH: Verify Fix
    else Medium/Low Vulnerability
        Scan->>Issue: Create Issue
        Issue->>Dev: Add to Backlog
        Dev->>Dev: Schedule Fix
    end
```

---

## 5. Release Management Flow

### 5.1 Complete Release Pipeline

```mermaid
graph TB
    Start[Create Release Tag] --> Validate[Validate Version]
    Validate --> Changelog[Generate Changelog]
    
    subgraph "Build Artifacts"
        B1[Build Frontend] --> B2[Build Backend Services]
        B2 --> B3[Create Distribution Packages]
        B3 --> B4[Generate Checksums]
        B4 --> B5[Sign Artifacts]
    end
    
    Changelog --> B1
    
    subgraph "Testing"
        T1[Full Test Suite] --> T2[E2E Tests]
        T2 --> T3[Performance Tests]
        T3 --> T4[Security Scan]
    end
    
    B5 --> T1
    
    T4 --> CreateRelease[Create GitHub Release]
    CreateRelease --> DeployStaging[Deploy to Staging]
    
    DeployStaging --> StagingTests{Staging Validation}
    
    StagingTests -->|Pass| Approval{Manual Approval}
    StagingTests -->|Fail| Investigate[Investigate Issues]
    
    Approval -->|Approved| DeployProd[Deploy to Production]
    Approval -->|Rejected| End1[Cancel Release]
    
    DeployProd --> Monitor[Monitor Production]
    Monitor --> HealthCheck{Health Check}
    
    HealthCheck -->|Pass| Notify[Notify Stakeholders]
    HealthCheck -->|Fail| Rollback[Rollback Release]
    
    Notify --> PostRelease[Post-Release Tasks]
    PostRelease --> UpdateDocs[Update Documentation]
    UpdateDocs --> CreateMilestone[Create Next Milestone]
    CreateMilestone --> End2[Release Complete]
    
    Rollback --> Investigate
    Investigate --> End1
    
    style End2 fill:#90EE90
    style End1 fill:#FF6B6B
    style Rollback fill:#FFD700
```

### 5.2 Semantic Versioning Flow

```mermaid
graph LR
    subgraph "Commit Analysis"
        A[Analyze Commits] --> B{Commit Type}
    end
    
    B -->|fix:| Patch[Increment Patch]
    B -->|feat:| Minor[Increment Minor]
    B -->|BREAKING CHANGE| Major[Increment Major]
    
    Patch --> Version[v1.0.X]
    Minor --> Version2[v1.X.0]
    Major --> Version3[vX.0.0]
    
    Version --> Tag[Create Tag]
    Version2 --> Tag
    Version3 --> Tag
    
    Tag --> Release[Trigger Release]
    
    style Patch fill:#90EE90
    style Minor fill:#FFD700
    style Major fill:#FF6B6B
```

---

## 6. Agent Interaction Diagram

### 6.1 Agent Communication Flow

```mermaid
graph TB
    subgraph "Coordination Layer"
        Orchestrator[Workflow Orchestrator]
    end
    
    subgraph "CI Agents"
        Frontend[Frontend CI Agent]
        Backend[Backend CI Agent]
        Quality[Code Quality Agent]
    end
    
    subgraph "Testing Agents"
        E2E[E2E Testing Agent]
        Perf[Performance Agent]
        Security[Security Agent]
    end
    
    subgraph "Deployment Agents"
        Deploy[Deployment Agent]
        DB[Database Migration Agent]
        Infra[Infrastructure Agent]
    end
    
    subgraph "Automation Agents"
        Deps[Dependency Agent]
        Docs[Documentation Agent]
        Release[Release Agent]
        Monitor[Monitoring Agent]
    end
    
    subgraph "Shared Resources"
        Cache[Cache Storage]
        Registry[Container Registry]
        Artifacts[Artifact Storage]
        Secrets[Secret Manager]
    end
    
    Orchestrator --> Frontend
    Orchestrator --> Backend
    Orchestrator --> Quality
    
    Frontend --> E2E
    Backend --> E2E
    Quality --> Security
    
    E2E --> Perf
    Security --> Deploy
    Perf --> Deploy
    
    Deploy --> DB
    Deploy --> Infra
    
    Backend --> Registry
    Frontend --> Artifacts
    
    Deps --> Frontend
    Deps --> Backend
    
    Docs --> Frontend
    Docs --> Backend
    
    Release --> Deploy
    Monitor --> Deploy
    
    Frontend -.-> Cache
    Backend -.-> Cache
    Deploy -.-> Secrets
    DB -.-> Secrets
    Infra -.-> Secrets
```

### 6.2 Data Flow Between Agents

```mermaid
sequenceDiagram
    participant Dev as Developer
    participant Orch as Orchestrator
    participant CI as CI Agent
    participant Test as Test Agent
    participant Sec as Security Agent
    participant Deploy as Deploy Agent
    participant Monitor as Monitor Agent
    
    Dev->>Orch: Push Code
    Orch->>CI: Trigger Build
    CI->>CI: Build Artifacts
    CI->>Test: Pass Artifacts
    
    par Parallel Testing
        Test->>Test: Run Unit Tests
        Test->>Test: Run Integration Tests
        Sec->>Sec: Security Scan
    end
    
    Test->>Orch: Test Results
    Sec->>Orch: Security Results
    
    alt Tests & Security Pass
        Orch->>Deploy: Deploy to Staging
        Deploy->>Deploy: Update Environment
        Deploy->>Test: Trigger E2E Tests
        Test->>Test: Run E2E Suite
        Test->>Orch: E2E Results
        
        Orch->>Deploy: Deploy to Production
        Deploy->>Monitor: Start Monitoring
        Monitor->>Orch: Health Status
        Orch->>Dev: Deployment Success
    else Tests or Security Fail
        Orch->>Dev: Pipeline Failed
    end
```

---

## 7. Environment Flow

### 7.1 Multi-Environment Deployment

```mermaid
graph TB
    Dev[Development] --> Feature[Feature Branch]
    Feature --> PR[Pull Request]
    PR --> CodeReview{Code Review}
    
    CodeReview -->|Approved| Merge[Merge to Main]
    CodeReview -->|Changes Requested| Feature
    
    Merge --> CI[CI Pipeline]
    CI --> Staging[Staging Environment]
    
    Staging --> StagingTests[Automated Tests]
    StagingTests --> UAT[User Acceptance Testing]
    UAT --> Approval{Approve Production?}
    
    Approval -->|Yes| Prod[Production Environment]
    Approval -->|No| Investigate[Investigate Issues]
    
    Prod --> Monitor[Production Monitoring]
    Monitor --> Healthy{System Healthy?}
    
    Healthy -->|Yes| Live[Live Traffic]
    Healthy -->|No| Incident[Incident Response]
    
    Incident --> Rollback[Rollback Decision]
    Rollback --> Staging
    
    Investigate --> Feature
    
    style Dev fill:#E3F2FD
    style Staging fill:#FFF9C4
    style Prod fill:#C8E6C9
    style Incident fill:#FF6B6B
```

### 7.2 Blue-Green Deployment Strategy

```mermaid
sequenceDiagram
    participant LB as Load Balancer
    participant Blue as Blue Environment (Current)
    participant Green as Green Environment (New)
    participant Monitor as Monitoring
    participant Users as Users
    
    Note over Blue: Currently Serving 100% Traffic
    
    Monitor->>Green: Deploy New Version
    Green->>Green: Start Services
    Green->>Monitor: Health Check
    Monitor->>Monitor: Validate Health
    
    Monitor->>LB: Route 10% to Green
    Users->>LB: Traffic
    LB->>Blue: 90% Traffic
    LB->>Green: 10% Traffic
    
    Monitor->>Monitor: Monitor Metrics
    
    alt Metrics Look Good
        Monitor->>LB: Route 50% to Green
        LB->>Blue: 50% Traffic
        LB->>Green: 50% Traffic
        
        Monitor->>Monitor: Continue Monitoring
        
        Monitor->>LB: Route 100% to Green
        LB->>Green: 100% Traffic
        
        Monitor->>Blue: Decommission
        Note over Green: Now Primary Environment
    else Issues Detected
        Monitor->>LB: Route 100% back to Blue
        LB->>Blue: 100% Traffic
        Monitor->>Green: Investigate Issues
    end
```

---

## 8. Monitoring & Alerting Flow

### 8.1 Continuous Monitoring Architecture

```mermaid
graph TB
    subgraph "Application Layer"
        Frontend[Frontend App]
        Backend[Backend Services]
        DB[Databases]
    end
    
    subgraph "Metrics Collection"
        Prometheus[Prometheus]
        Logs[Log Aggregation]
        Traces[Distributed Tracing]
    end
    
    subgraph "Analysis"
        Alerting[Alert Manager]
        Dashboard[Grafana Dashboards]
        ML[ML Anomaly Detection]
    end
    
    subgraph "Notification"
        Slack[Slack]
        Email[Email]
        PagerDuty[PagerDuty]
        Ticket[Ticket System]
    end
    
    Frontend --> Prometheus
    Backend --> Prometheus
    DB --> Prometheus
    
    Frontend --> Logs
    Backend --> Logs
    
    Backend --> Traces
    
    Prometheus --> Alerting
    Logs --> Alerting
    Traces --> Alerting
    
    Prometheus --> Dashboard
    Logs --> Dashboard
    Traces --> Dashboard
    
    Alerting --> ML
    ML --> Alerting
    
    Alerting --> Slack
    Alerting --> Email
    Alerting --> PagerDuty
    Alerting --> Ticket
    
    Dashboard --> Slack
```

### 8.2 Incident Response Flow

```mermaid
graph TB
    Alert[Alert Triggered] --> Severity{Severity Level}
    
    Severity -->|Critical| Page[Page On-Call]
    Severity -->|High| Slack[Slack Alert]
    Severity -->|Medium| Email[Email Alert]
    Severity -->|Low| Ticket[Create Ticket]
    
    Page --> Acknowledge[Acknowledge Alert]
    Slack --> Acknowledge
    
    Acknowledge --> Investigate[Investigate Issue]
    Investigate --> RootCause{Root Cause Found?}
    
    RootCause -->|Yes| Fix{Can Fix Quickly?}
    RootCause -->|No| Escalate[Escalate to Team]
    
    Fix -->|Yes| Deploy[Deploy Fix]
    Fix -->|No| Rollback[Rollback Changes]
    
    Escalate --> TeamInvestigate[Team Investigation]
    TeamInvestigate --> Fix
    
    Deploy --> Validate[Validate Fix]
    Rollback --> Validate
    
    Validate --> Resolved{Issue Resolved?}
    
    Resolved -->|Yes| Document[Document Incident]
    Resolved -->|No| Investigate
    
    Document --> PostMortem[Post-Mortem]
    PostMortem --> Improvements[Implement Improvements]
    Improvements --> End[Close Incident]
    
    style Alert fill:#FF6B6B
    style End fill:#90EE90
```

---

## 9. Cost Optimization Flow

### 9.1 Resource Optimization Strategy

```mermaid
graph TB
    Monitor[Monitor Usage] --> Analyze[Analyze Costs]
    
    subgraph "Optimization Areas"
        Cache[Optimize Caching]
        Parallel[Reduce Parallel Jobs]
        Runner[Right-size Runners]
        Schedule[Optimize Schedules]
    end
    
    Analyze --> Cache
    Analyze --> Parallel
    Analyze --> Runner
    Analyze --> Schedule
    
    Cache --> Review[Review Changes]
    Parallel --> Review
    Runner --> Review
    Schedule --> Review
    
    Review --> Implement[Implement Changes]
    Implement --> Measure[Measure Impact]
    Measure --> Compare{Cost Reduced?}
    
    Compare -->|Yes| Document[Document Changes]
    Compare -->|No| Revert[Revert Changes]
    
    Document --> Monitor
    Revert --> Monitor
    
    style Compare fill:#FFD700
    style Document fill:#90EE90
```

---

## 10. Workflow Execution Timeline

### 10.1 Typical PR to Production Timeline

```mermaid
gantt
    title CI/CD Pipeline Timeline
    dateFormat  HH:mm
    axisFormat %H:%M
    
    section Code Quality
    ESLint & Prettier       :a1, 00:00, 2m
    TypeScript Check        :a2, after a1, 1m
    
    section Testing
    Unit Tests              :b1, after a2, 5m
    Integration Tests       :b2, after b1, 3m
    Coverage Report         :b3, after b2, 1m
    
    section Build
    Install Dependencies    :c1, after b3, 3m
    Build Production        :c2, after c1, 4m
    Bundle Analysis         :c3, after c2, 1m
    
    section Security
    Dependency Scan         :d1, after c3, 2m
    SAST Analysis           :d2, after d1, 3m
    Container Scan          :d3, after d2, 2m
    
    section Deploy Staging
    Upload to CDN           :e1, after d3, 2m
    Smoke Tests             :e2, after e1, 2m
    
    section E2E Tests
    Run Test Suite          :f1, after e2, 10m
    Visual Regression       :f2, after f1, 3m
    
    section Deploy Production
    Manual Approval         :g1, after f2, 0m
    Deploy to CDN           :g2, after g1, 2m
    Health Check            :g3, after g2, 1m
```

---

## Document Control

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | December 2025 | DevOps Team | Initial visual diagrams |

**Status:** Final  
**Related Documents:** WORKFLOW_AND_AGENTS_DESIGN.md

---

**End of Document**
