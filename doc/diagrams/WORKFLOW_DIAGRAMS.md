# Workflow and Process Diagrams
## Heavy Machinery Dealer Management System

This document contains workflow diagrams, sequence diagrams, and process flows that illustrate key business operations in the system.

---

## 1. Email Processing Workflow

Shows the end-to-end flow of processing an incoming customer email.

```mermaid
flowchart TD
    Start([Email Arrives]) --> FetchEmail[Fetch Email from Server]
    FetchEmail --> StoreRaw[Store Raw Email in MongoDB]
    StoreRaw --> ExtractFeatures[Extract Features<br/>Subject, Body, Sender, Attachments]
    
    ExtractFeatures --> CallML{Call ML Model<br/>for Classification}
    
    CallML -->|High Confidence >90%| AutoClassify[Auto-Classify]
    CallML -->|Medium Confidence 70-90%| FlagReview[Auto-Classify + Flag for Review]
    CallML -->|Low Confidence <70%| ManualQueue[Send to Manual Review Queue]
    
    AutoClassify --> CalculatePriority[Calculate Priority Score]
    FlagReview --> CalculatePriority
    
    CalculatePriority --> GetCustomerHistory[Get Customer History<br/>Purchase History, Credit Status]
    GetCustomerHistory --> ApplyRules[Apply Priority Rules<br/>Urgency Keywords, Deal Value]
    
    ApplyRules --> DeterminePriority{Priority Score}
    
    DeterminePriority -->|High Priority 8-10| FindTopRep[Find Best Available<br/>Sales Rep]
    DeterminePriority -->|Medium Priority 5-7| RoundRobin[Assign via<br/>Round Robin]
    DeterminePriority -->|Low Priority 1-4| QueueAssign[Add to Queue<br/>for Next Available]
    
    FindTopRep --> AssignRep[Assign to Sales Rep]
    RoundRobin --> AssignRep
    QueueAssign --> AssignRep
    
    AssignRep --> StoreMetadata[Store Assignment in PostgreSQL]
    StoreMetadata --> PublishEvent[Publish EmailClassified Event]
    
    PublishEvent --> SendNotification[Send Mobile/Email<br/>Notification to Rep]
    SendNotification --> UpdateDashboard[Update Dashboard]
    
    UpdateDashboard --> End([Process Complete])
    
    ManualQueue --> ManualReview[Manual Review by Admin]
    ManualReview --> FeedbackLoop[Store Feedback for<br/>Model Retraining]
    FeedbackLoop --> CalculatePriority
    
    style CallML fill:#FFB6C1,stroke:#FF69B4,stroke-width:2px
    style CalculatePriority fill:#87CEEB,stroke:#4682B4,stroke-width:2px
    style SendNotification fill:#90EE90,stroke:#228B22,stroke-width:2px
    style ManualQueue fill:#FFD700,stroke:#FFA500,stroke-width:2px
```

---

## 2. Quote Generation Workflow

Shows the complete process of creating and sending a quote to a customer.

```mermaid
flowchart TD
    Start([Sales Rep Initiates Quote]) --> SelectCustomer[Select Customer]
    SelectCustomer --> FetchCustomer360[Fetch Customer 360 View<br/>Address, Tax Info, History]
    
    FetchCustomer360 --> AddProducts[Add Machine Models<br/>to Quote]
    AddProducts --> ConfigureMachine[Configure Each Machine<br/>Bucket Size, Tires, Attachments]
    
    ConfigureMachine --> ValidateConfig{Validate Configuration}
    
    ValidateConfig -->|Invalid| ShowErrors[Display Validation Errors]
    ShowErrors --> ConfigureMachine
    
    ValidateConfig -->|Valid| CalculatePrice[Calculate Price<br/>Base + Configuration Cost]
    
    CalculatePrice --> ApplyDiscount{Apply Discount?}
    
    ApplyDiscount -->|No Discount| CalculateTax[Calculate Tax]
    ApplyDiscount -->|Small Discount <10%| CalculateTax
    
    ApplyDiscount -->|Large Discount >=10%| CheckApproval{Requires Approval?}
    
    CheckApproval -->|Yes| RequestApproval[Request Discount Approval]
    RequestApproval --> WaitApproval[Wait for Manager Approval]
    
    WaitApproval --> ApprovalDecision{Approved?}
    ApprovalDecision -->|Rejected| NotifyRejection[Notify Sales Rep<br/>Rejection Reason]
    NotifyRejection --> ApplyDiscount
    
    ApprovalDecision -->|Approved| CalculateTax
    CheckApproval -->|No| CalculateTax
    
    CalculateTax --> CheckStock{Check Inventory<br/>Availability}
    
    CheckStock -->|In Stock| ReserveStock[Reserve Stock<br/>for 7 Days]
    CheckStock -->|Out of Stock| EstimateDelivery[Estimate Delivery Date<br/>from Manufacturer]
    
    ReserveStock --> GeneratePDF[Generate Quote PDF<br/>Apply Template]
    EstimateDelivery --> GeneratePDF
    
    GeneratePDF --> SaveQuote[Save Quote to Database]
    SaveQuote --> UploadS3[Upload PDF to S3]
    
    UploadS3 --> SendOptions{Send to Customer?}
    
    SendOptions -->|Send Now| ComposeEmail[Compose Email Message]
    SendOptions -->|Send Later| ScheduleSend[Schedule for Later]
    SendOptions -->|Manual Send| SaveDraft[Save as Draft]
    
    ComposeEmail --> SendEmail[Send Email via<br/>Email Service]
    SendEmail --> LogActivity[Log Activity in<br/>Customer History]
    
    ScheduleSend --> LogActivity
    SaveDraft --> LogActivity
    
    LogActivity --> CreateDeal[Create/Update Deal<br/>in Pipeline]
    CreateDeal --> PublishEvent[Publish QuoteCreated Event]
    
    PublishEvent --> SetFollowUp[Set Follow-up Reminder<br/>for 3 Days]
    SetFollowUp --> End([Quote Complete])
    
    style ValidateConfig fill:#FFB6C1,stroke:#FF69B4,stroke-width:2px
    style CheckApproval fill:#FFD700,stroke:#FFA500,stroke-width:2px
    style CheckStock fill:#87CEEB,stroke:#4682B4,stroke-width:2px
    style GeneratePDF fill:#90EE90,stroke:#228B22,stroke-width:2px
```

---

## 3. Purchase Order Creation Workflow

Shows automated PO generation from an approved quote.

```mermaid
flowchart TD
    Start([Trigger: Customer Accepts Quote]) --> FetchQuote[Fetch Quote Details<br/>Line Items, Configurations]
    FetchQuote --> FetchCustomer[Fetch Customer Details<br/>Shipping Address, Tax Info]
    
    FetchCustomer --> CheckInventory{Check Stock<br/>Availability}
    
    CheckInventory -->|All in Stock| UseInventory[Use Existing Stock]
    CheckInventory -->|Partial Stock| SplitOrder[Split: Stock + Manufacturer]
    CheckInventory -->|No Stock| OrderAll[Order All from Manufacturer]
    
    UseInventory --> InitPO[Initialize Purchase Order]
    SplitOrder --> InitPO
    OrderAll --> InitPO
    
    InitPO --> AddLineItems[Add Line Items<br/>Product Codes, Quantities]
    AddLineItems --> AddSpecs[Add Machine Specifications<br/>Configuration Details]
    
    AddSpecs --> CalculateCost[Calculate PO Cost<br/>Supplier Pricing]
    CalculateCost --> AddDelivery[Add Delivery Details<br/>Location, Expected Date]
    
    AddDelivery --> ValidatePO{Validate PO<br/>Completeness}
    
    ValidatePO -->|Missing Info| RequestInfo[Request Missing Information<br/>from Sales Rep]
    RequestInfo --> AddDelivery
    
    ValidatePO -->|Complete| CheckAmount{PO Amount}
    
    CheckAmount -->|< $50000| AutoApprove[Auto-Approve]
    CheckAmount -->|$50000 - $200000| RequestManagerApproval[Request Manager Approval]
    CheckAmount -->|> $200000| RequestExecutiveApproval[Request Executive Approval]
    
    RequestManagerApproval --> WaitApproval[Wait for Approval]
    RequestExecutiveApproval --> WaitApproval
    
    WaitApproval --> ApprovalStatus{Approved?}
    
    ApprovalStatus -->|Rejected| NotifyRep[Notify Sales Rep]
    NotifyRep --> End1([PO Cancelled])
    
    ApprovalStatus -->|Approved| AutoApprove
    
    AutoApprove --> GeneratePOPDF[Generate PO PDF<br/>Supplier-Specific Format]
    GeneratePOPDF --> StorePDF[Store PDF in S3]
    
    StorePDF --> DetermineSubmission{Submission Method}
    
    DetermineSubmission -->|API Available| CallSupplierAPI[Submit via Supplier API]
    DetermineSubmission -->|Email Only| SendPOEmail[Send PO via Email]
    DetermineSubmission -->|Manual Process| FlagManual[Flag for Manual Submission]
    
    CallSupplierAPI --> WaitConfirmation[Wait for Confirmation]
    SendPOEmail --> WaitConfirmation
    FlagManual --> NotifyManual[Notify Procurement Team]
    
    WaitConfirmation --> ReceiveConfirmation{Confirmation<br/>Received?}
    
    ReceiveConfirmation -->|Yes| StorePONumber[Store Supplier PO Number]
    ReceiveConfirmation -->|No After 2 Hours| SendReminder[Send Reminder]
    SendReminder --> WaitConfirmation
    
    StorePONumber --> UpdateInventory[Update Inventory System<br/>On-Order Quantity]
    NotifyManual --> UpdateInventory
    
    UpdateInventory --> CreateTracking[Create Order Tracking Record]
    CreateTracking --> SetReminders[Set Delivery Reminders]
    
    SetReminders --> PublishEvent[Publish POCreated Event]
    PublishEvent --> NotifyStakeholders[Notify All Stakeholders<br/>Sales Rep, Customer, Warehouse]
    
    NotifyStakeholders --> End([PO Process Complete])
    
    style CheckInventory fill:#FFB6C1,stroke:#FF69B4,stroke-width:2px
    style ValidatePO fill:#87CEEB,stroke:#4682B4,stroke-width:2px
    style CheckAmount fill:#FFD700,stroke:#FFA500,stroke-width:2px
    style GeneratePOPDF fill:#90EE90,stroke:#228B22,stroke-width:2px
```

---

## 4. Approval Workflow State Machine

Shows the state transitions in the approval process.

```mermaid
stateDiagram-v2
    [*] --> Draft: Create Request
    
    Draft --> PendingApproval: Submit for Approval
    Draft --> Cancelled: Cancel Request
    
    PendingApproval --> L1_Review: Auto-Route to L1
    
    L1_Review --> L2_Review: L1 Approves<br/>(Amount > $50K)
    L1_Review --> Approved: L1 Approves<br/>(Amount <= $50K)
    L1_Review --> Rejected: L1 Rejects
    L1_Review --> OnHold: L1 Requests More Info
    
    OnHold --> L1_Review: Info Provided
    OnHold --> Cancelled: Timeout (7 days)
    
    L2_Review --> L3_Review: L2 Approves<br/>(Amount > $150K)
    L2_Review --> Approved: L2 Approves<br/>(Amount <= $150K)
    L2_Review --> Rejected: L2 Rejects
    L2_Review --> OnHold: L2 Requests More Info
    
    L3_Review --> Approved: L3 Approves
    L3_Review --> Rejected: L3 Rejects
    L3_Review --> OnHold: L3 Requests More Info
    
    PendingApproval --> Expired: No Action<br/>(48 hours)
    
    Approved --> [*]: Process Complete
    Rejected --> Draft: Modify & Resubmit
    Expired --> Draft: Resubmit
    Cancelled --> [*]: Process Cancelled
    
    note right of L1_Review
        First Level: Sales Manager
        SLA: 4 hours
        Auto-escalate if no response
    end note
    
    note right of L2_Review
        Second Level: Regional Manager
        SLA: 8 hours
        Can delegate to peer
    end note
    
    note right of L3_Review
        Third Level: Executive
        SLA: 24 hours
        Final decision
    end note
```

---

## 5. Sales Pipeline Process Flow

Shows how deals progress through the sales pipeline.

```mermaid
flowchart TD
    Start([New Lead]) --> QualifyLead{Qualify Lead}
    
    QualifyLead -->|Not Qualified| Disqualify[Mark as Disqualified<br/>Record Reason]
    Disqualify --> Archive1([Archive])
    
    QualifyLead -->|Qualified| CreateDeal[Create Deal in Pipeline]
    CreateDeal --> GatherReq[Gather Requirements<br/>Call/Meeting with Customer]
    
    GatherReq --> LogActivity1[Log Activity]
    LogActivity1 --> PrepareQuote[Prepare Quote]
    
    PrepareQuote --> SendQuote[Send Quote to Customer]
    SendQuote --> SetFollowUp1[Set Follow-up Reminder<br/>3 Days]
    
    SetFollowUp1 --> WaitResponse[Wait for Customer Response]
    
    WaitResponse --> CustomerResponse{Customer Response}
    
    CustomerResponse -->|No Response| FollowUp1[Follow-up Call/Email]
    FollowUp1 --> FollowUpAttempts{Follow-up<br/>Attempts}
    
    FollowUpAttempts -->|< 3 Attempts| WaitResponse
    FollowUpAttempts -->|>= 3 Attempts| MarkLost[Mark as Lost<br/>Reason: No Response]
    
    CustomerResponse -->|Interested| Negotiate[Enter Negotiation Phase]
    CustomerResponse -->|Not Interested| MarkLost
    
    Negotiate --> LogActivity2[Log Negotiation Notes]
    LogActivity2 --> CheckTerms{Terms Agreed?}
    
    CheckTerms -->|Need Revision| ReviseQuote[Revise Quote]
    ReviseQuote --> SendQuote
    
    CheckTerms -->|Price Issue| Discount{Offer Discount?}
    Discount -->|Yes| RequestDiscount[Request Discount Approval]
    RequestDiscount --> WaitDiscountApproval[Wait for Approval]
    
    WaitDiscountApproval --> DiscountDecision{Approved?}
    DiscountDecision -->|Rejected| MarkLost
    DiscountDecision -->|Approved| ReviseQuote
    
    Discount -->|No| CheckCompetitor{Lost to<br/>Competitor?}
    CheckCompetitor -->|Yes| MarkLost
    CheckCompetitor -->|No| WaitResponse
    
    CheckTerms -->|Agreed| FinalQuote[Send Final Quote]
    FinalQuote --> WaitSignature[Wait for Customer Signature]
    
    WaitSignature --> SignatureReceived{Signature<br/>Received?}
    
    SignatureReceived -->|No After 7 Days| FollowUp2[Follow-up]
    FollowUp2 --> WaitSignature
    
    SignatureReceived -->|Yes| MarkWon[Mark Deal as Won]
    
    MarkWon --> CalculateCommission[Calculate Commission]
    CalculateCommission --> CreatePO[Create Purchase Order]
    
    CreatePO --> NotifyWarehouse[Notify Warehouse<br/>for Delivery Planning]
    NotifyWarehouse --> SetDelivery[Schedule Delivery Date]
    
    SetDelivery --> UpdateCRM[Update CRM with Deal Details]
    UpdateCRM --> GenerateReport[Generate Sales Report]
    
    GenerateReport --> End([Deal Complete])
    
    MarkLost --> RecordReason[Record Loss Reason<br/>Competitor/Price/Timing]
    RecordReason --> AnalyzeLoss[Analyze for Insights]
    AnalyzeLoss --> Archive2([Archive Deal])
    
    style QualifyLead fill:#FFB6C1,stroke:#FF69B4,stroke-width:2px
    style Negotiate fill:#87CEEB,stroke:#4682B4,stroke-width:2px
    style MarkWon fill:#90EE90,stroke:#228B22,stroke-width:3px
    style MarkLost fill:#FFD700,stroke:#FFA500,stroke-width:2px
```

---

## 6. Inventory Stock Reservation Sequence

Detailed sequence showing stock reservation during quote creation.

```mermaid
sequenceDiagram
    participant SR as Sales Rep
    participant QS as Quote Service
    participant IS as Inventory Service
    participant DB as PostgreSQL
    participant Cache as Redis
    participant MQ as RabbitMQ
    
    SR->>QS: Create quote with products
    QS->>QS: Validate customer & products
    
    loop For each line item
        QS->>IS: Check stock availability
        IS->>Cache: Check cached inventory
        
        alt Cache hit
            Cache-->>IS: Return cached data
        else Cache miss
            IS->>DB: Query inventory
            DB-->>IS: Return inventory data
            IS->>Cache: Update cache (TTL 5 min)
        end
        
        IS->>IS: Calculate available qty
        IS-->>QS: Return availability status
        
        alt Stock available
            QS->>IS: Reserve stock request
            IS->>DB: Start transaction
            IS->>DB: Lock inventory row
            IS->>DB: Check qty_available >= requested
            
            alt Sufficient stock
                IS->>DB: Create reservation record
                IS->>DB: Update qty_reserved += requested
                IS->>DB: Update qty_available -= requested
                IS->>DB: Commit transaction
                IS->>Cache: Invalidate inventory cache
                IS->>MQ: Publish StockReserved event
                IS-->>QS: Reservation successful
            else Insufficient stock
                IS->>DB: Rollback transaction
                IS-->>QS: Reservation failed
                QS->>QS: Mark line item as back-order
            end
        else Stock not available
            QS->>QS: Query manufacturer lead time
            QS->>QS: Add lead time to quote
        end
    end
    
    QS->>QS: Calculate total price
    QS->>DB: Save quote
    QS->>MQ: Publish QuoteCreated event
    QS-->>SR: Quote created successfully
    
    Note over IS,MQ: Background: Reservation expires after 7 days
    
    MQ->>IS: Schedule reservation expiry check
    IS->>DB: Query expired reservations
    
    loop For each expired reservation
        IS->>DB: Start transaction
        IS->>DB: Release reservation
        IS->>DB: Update qty_reserved -= released
        IS->>DB: Update qty_available += released
        IS->>DB: Commit transaction
        IS->>Cache: Invalidate cache
        IS->>MQ: Publish StockReleased event
    end
```

---

## 7. Tender Management Process

Shows the workflow for responding to tender requests.

```mermaid
flowchart TD
    Start([Tender Email Received]) --> ClassifyEmail[Email Classified as Tender]
    ClassifyEmail --> HighPriority[Marked High Priority]
    
    HighPriority --> NotifyTeam[Notify Tender Response Team]
    NotifyTeam --> CreateTender[Create Tender Record in System]
    
    CreateTender --> ExtractDetails[Extract Tender Details<br/>Deadline, Requirements, Docs]
    ExtractDetails --> CheckDeadline{Sufficient Time<br/>to Respond?}
    
    CheckDeadline -->|< 3 Days| EscalateUrgent[Escalate to Management<br/>Urgent Decision]
    CheckDeadline -->|>= 3 Days| AssignTeam[Assign Response Team]
    
    EscalateUrgent --> GoNoGo{Decision to<br/>Participate?}
    GoNoGo -->|No| DeclineParticipation[Decline Participation<br/>Send Polite Decline]
    DeclineParticipation --> End1([Tender Closed])
    
    GoNoGo -->|Yes| AssignTeam
    
    AssignTeam --> CheckLibrary[Search Document Library<br/>Similar Past Tenders]
    CheckLibrary --> FoundTemplate{Template<br/>Found?}
    
    FoundTemplate -->|Yes| LoadTemplate[Load Template Documents]
    FoundTemplate -->|No| CreateFromScratch[Start from Scratch]
    
    LoadTemplate --> CreateChecklist[Create Compliance Checklist<br/>Required Documents]
    CreateFromScratch --> CreateChecklist
    
    CreateChecklist --> GatherDocs[Gather Required Documents]
    GatherDocs --> ParallelTasks[Parallel Tasks Begin]
    
    ParallelTasks --> TechSpec[Technical Specifications<br/>Product Details]
    ParallelTasks --> Commercial[Commercial Terms<br/>Pricing, Payment]
    ParallelTasks --> Legal[Legal Documents<br/>Certificates, Compliance]
    ParallelTasks --> Financial[Financial Documents<br/>Company Profile, References]
    
    TechSpec --> ReviewTech[Technical Review]
    Commercial --> ReviewCommercial[Commercial Review]
    Legal --> ReviewLegal[Legal Review]
    Financial --> ReviewFinancial[Finance Review]
    
    ReviewTech --> ConsolidateDocs[Consolidate All Documents]
    ReviewCommercial --> ConsolidateDocs
    ReviewLegal --> ConsolidateDocs
    ReviewFinancial --> ConsolidateDocs
    
    ConsolidateDocs --> FinalReview[Final Review Against Checklist]
    FinalReview --> CheckComplete{All Requirements<br/>Met?}
    
    CheckComplete -->|Missing Items| IdentifyGaps[Identify Gaps]
    IdentifyGaps --> FillGaps[Fill Missing Information]
    FillGaps --> FinalReview
    
    CheckComplete -->|Complete| ExecutiveApproval[Submit for Executive Approval]
    ExecutiveApproval --> ApprovalDecision{Approved?}
    
    ApprovalDecision -->|Needs Changes| MakeChanges[Make Requested Changes]
    MakeChanges --> ExecutiveApproval
    
    ApprovalDecision -->|Approved| GenerateFinal[Generate Final Submission Package]
    GenerateFinal --> QualityCheck[Quality Check<br/>Formatting, Signatures]
    
    QualityCheck --> SubmitTender{Submission Method}
    
    SubmitTender -->|Online Portal| UploadPortal[Upload to Tender Portal]
    SubmitTender -->|Email| SendEmail[Send via Email]
    SubmitTender -->|Physical| PrintShip[Print & Ship Documents]
    
    UploadPortal --> ConfirmSubmission[Confirm Submission Receipt]
    SendEmail --> ConfirmSubmission
    PrintShip --> ConfirmSubmission
    
    ConfirmSubmission --> StoreRecord[Store Complete Record<br/>for Future Reference]
    StoreRecord --> SetReminder[Set Reminder for Result Date]
    
    SetReminder --> WaitResult[Wait for Tender Result]
    WaitResult --> ResultReceived{Result Received?}
    
    ResultReceived -->|Won| RecordWin[Record as Won<br/>Celebrate Success]
    ResultReceived -->|Lost| RecordLoss[Record as Lost<br/>Analyze Reasons]
    ResultReceived -->|No Result After Deadline| FollowUpResult[Follow Up on Status]
    
    RecordWin --> UpdateLibrary[Update Document Library<br/>Save Winning Proposal]
    RecordLoss --> UpdateLibrary
    
    UpdateLibrary --> End([Tender Process Complete])
    FollowUpResult --> WaitResult
    
    style CheckDeadline fill:#FFB6C1,stroke:#FF69B4,stroke-width:2px
    style CheckComplete fill:#87CEEB,stroke:#4682B4,stroke-width:2px
    style RecordWin fill:#90EE90,stroke:#228B22,stroke-width:3px
    style RecordLoss fill:#FFD700,stroke:#FFA500,stroke-width:2px
```

---

## 8. Customer Follow-up Automation

Shows the automated follow-up system workflow.

```mermaid
flowchart TD
    Start([Quote Sent to Customer]) --> CreateFollowUp[Create Follow-up Task<br/>Scheduled for Day 3]
    CreateFollowUp --> StoreTask[Store in Task Queue]
    
    StoreTask --> Wait[Wait for Scheduled Time]
    Wait --> CheckQuoteStatus{Quote Status?}
    
    CheckQuoteStatus -->|Accepted| CancelFollowUp[Cancel Follow-up<br/>Deal Won]
    CheckQuoteStatus -->|Rejected| CancelFollowUp
    CheckQuoteStatus -->|Pending| CheckActivity{Customer Activity<br/>Since Quote?}
    
    CancelFollowUp --> End1([Follow-up Cancelled])
    
    CheckActivity -->|Has Responded| UpdateTask[Update Follow-up Note<br/>with Last Activity]
    CheckActivity -->|No Activity| StandardFollowUp[Standard Follow-up]
    
    UpdateTask --> CheckResponse{Response Type}
    CheckResponse -->|Question| AnswerQuestion[Prepare Answer Template]
    CheckResponse -->|Price Concern| PriceDiscussion[Suggest Price Discussion]
    CheckResponse -->|Competitor Mention| CompetitorAnalysis[Prepare Competitive Analysis]
    
    AnswerQuestion --> NotifyRep[Notify Sales Rep with Context]
    PriceDiscussion --> NotifyRep
    CompetitorAnalysis --> NotifyRep
    StandardFollowUp --> NotifyRep
    
    NotifyRep --> RepAction{Rep Takes Action?}
    
    RepAction -->|Within 2 Hours| LogContact[Log Contact Attempt]
    RepAction -->|No Action After 4 Hours| EscalateManager[Escalate to Manager]
    
    EscalateManager --> ManagerReview[Manager Reviews]
    ManagerReview --> ManagerDecision{Manager Decision}
    
    ManagerDecision -->|Reassign| AssignOtherRep[Assign to Another Rep]
    ManagerDecision -->|Rep Contacted| LogContact
    
    AssignOtherRep --> NotifyRep
    
    LogContact --> ContactResult{Contact Result}
    
    ContactResult -->|Customer Interested| ScheduleNextFollowUp[Schedule Next Follow-up<br/>Based on Customer Preference]
    ContactResult -->|Customer Not Ready| ScheduleLaterFollowUp[Schedule Later Follow-up<br/>30 Days]
    ContactResult -->|Cannot Reach| IncrementAttempts[Increment Failed Attempts]
    
    IncrementAttempts --> CheckAttempts{Failed Attempts}
    CheckAttempts -->|< 5| RetrySchedule[Retry Schedule<br/>Next Day Different Time]
    CheckAttempts -->|>= 5| MarkLostContact[Mark Deal Lost<br/>Reason: Cannot Contact]
    
    RetrySchedule --> Wait
    
    ScheduleNextFollowUp --> StoreTask
    ScheduleLaterFollowUp --> StoreTask
    
    MarkLostContact --> End2([Deal Closed Lost])
    
    ScheduleNextFollowUp --> End3([Follow-up Scheduled])
    ScheduleLaterFollowUp --> End3
    
    style CheckActivity fill:#FFB6C1,stroke:#FF69B4,stroke-width:2px
    style RepAction fill:#87CEEB,stroke:#4682B4,stroke-width:2px
    style ContactResult fill:#90EE90,stroke:#228B22,stroke-width:2px
    style EscalateManager fill:#FFD700,stroke:#FFA500,stroke-width:2px
```

---

**Document Control:**
- Version: 1.0
- Last Updated: 2025-11-24
- Diagram Format: Mermaid
- Purpose: Business Process Documentation
