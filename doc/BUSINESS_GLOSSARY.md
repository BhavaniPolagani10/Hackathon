# Business Glossary
## Heavy Machinery Dealer Management System

This glossary provides business-friendly definitions of key terms, concepts, and workflows used in the Heavy Machinery Dealer Management System.

---

## A

### **Approval Chain**
A sequence of people who must review and approve a request (such as a discount or purchase order) before it can proceed. The chain typically flows from sales representative → manager → executive, depending on the amount involved.

**Example:** A 15% discount requires approval from both the sales manager and regional manager.

### **Approval Workflow**
The automated process that routes approval requests to the right people, tracks responses, sends reminders, and handles escalations when someone doesn't respond in time.

**Business Value:** Reduces approval time from days to hours by automating routing and reminders.

### **Attachment**
A file attached to an email, such as a PDF quote, machine specification sheet, or customer document.

### **Auto-Classification**
The system's ability to automatically categorize incoming emails (inquiry, service request, tender, etc.) using machine learning, without human intervention.

**Accuracy:** 92%+ of emails are correctly classified automatically.

---

## B

### **Base Model**
The standard version of a machine before adding any customizations (bucket size, tires, attachments, etc.).

**Example:** Model XL-500 is the base model; XL-500 with 2-yard bucket and solid tires is a configured version.

### **Batch Processing**
Processing multiple items together at scheduled times rather than one at a time. Used for syncing data with ERP systems or sending bulk notifications.

**Example:** Inventory levels are synced from ERP every night at midnight.

### **Business Logic**
The rules and calculations that define how the business operates, encoded in the system.

**Example:** "Discounts over 10% require manager approval" is a business rule.

---

## C

### **C4 Model**
A way of visualizing system architecture at four levels of detail: Context (big picture), Container (applications), Component (internal parts), and Code (classes and methods).

**Purpose:** Helps different audiences understand the system at the appropriate level of detail.

### **Cache**
A temporary storage area that keeps frequently accessed data in fast memory to improve response times.

**Example:** Customer information is cached for 15 minutes so repeated lookups are instant.

### **Configuration**
The specific options selected for a machine (bucket size, tire type, attachments, warranty package).

**Example:** Excavator with 1.5-yard bucket, rubber tires, hydraulic breaker attachment, 2-year warranty.

### **Customer 360 View**
A complete, unified view of everything about a customer in one place: contact info, addresses, purchase history, quotes, orders, service records, documents, and communications.

**Business Value:** Sales reps have all information at their fingertips without searching multiple systems.

---

## D

### **Dashboard**
A visual display showing key metrics, pending tasks, and important information at a glance.

**Sales Rep Dashboard:** Shows pending quotes, upcoming follow-ups, pipeline value, assigned emails.

**Manager Dashboard:** Shows team performance, deals at risk, approval queue, forecast accuracy.

### **Deal**
A sales opportunity being tracked through the pipeline from initial contact to win/loss.

**Deal Stages:** Lead → Qualified → Quote Sent → Negotiation → Won/Lost

### **Deal Pipeline**
The visual representation of all ongoing sales opportunities, organized by stage, showing progress toward closure.

**Business Value:** Provides visibility into what's coming, what's at risk, and where to focus effort.

### **Discount Approval**
The process of getting permission to offer a price reduction beyond the sales rep's authority.

**Typical Thresholds:**
- 0-5%: Auto-approved
- 6-10%: Sales manager
- 11-15%: Regional manager
- 15%+: Executive approval

---

## E

### **Email Classification**
Automatically sorting incoming emails into categories (customer inquiry, service request, tender, supplier message, spam) so they can be prioritized and routed appropriately.

**Categories:**
- **Inquiry:** Customer asking about products/pricing
- **Service:** Existing customer needing support
- **Tender:** Government/corporate bid opportunity
- **Supplier:** Message from manufacturers/vendors
- **Spam:** Irrelevant/marketing emails

### **ERP System**
Enterprise Resource Planning - The company's main business system that handles accounting, financials, inventory, and historical customer data.

**Integration:** Our system fetches customer data and inventory from ERP, doesn't duplicate it.

### **Escalation**
Automatically routing a task to a higher authority when it's overdue or needs attention.

**Example:** If a manager doesn't approve a discount within 8 hours, the request escalates to the regional manager.

### **Event**
A notification that something happened in the system, used to trigger actions in other parts of the system.

**Example:** "Quote Created" event triggers inventory reservation, pipeline update, and customer notification.

---

## F

### **Follow-up**
Contacting a customer after sending a quote to check interest, answer questions, or move the deal forward.

**Automated Follow-ups:** System sends reminders to sales reps 3 days, 7 days, and 14 days after quote is sent.

**Business Value:** Prevents deals from being forgotten and improves conversion rates.

### **Forecast**
Prediction of future sales based on current pipeline, deal probabilities, and historical patterns.

**Types:**
- **Best Case:** Sum of all high-probability deals (90%+)
- **Most Likely:** Weighted sum of all deals by probability
- **Worst Case:** Conservative estimate of likely closures
- **Committed:** Deals with signed agreements

---

## H

### **High-Level Design (HLD)**
Architecture documentation describing what the system does, how it fits together at a high level, and what business problems it solves.

**Audience:** Business stakeholders, executives, project managers, architects.

---

## I

### **Inquiry**
A customer email asking about products, pricing, or availability - represents a potential sales opportunity.

**High Priority Inquiries:**
- From existing VIP customers
- Mentioning specific machine models
- Containing "urgent" or "ASAP"
- High estimated deal value

### **Inventory Reservation**
Temporarily holding stock for a specific quote to ensure it won't be sold to someone else.

**Duration:** 7 days by default, automatically released if quote isn't converted.

**Business Value:** Prevents promising machines that aren't available.

---

## L

### **Lead**
A potential customer who has shown interest but hasn't been qualified yet.

**Qualification Criteria:**
- Has budget or financing
- Has need in near term (< 6 months)
- Has authority to buy
- Fits our target customer profile

### **Lead Time**
The time between ordering a machine from the manufacturer and receiving it.

**Typical Lead Times:**
- In-stock items: 1-3 days
- Manufacturer standard config: 4-8 weeks
- Custom configuration: 12-16 weeks

### **Line Item**
One product on a quote or purchase order. A quote can have multiple line items.

**Example:** Quote #12345 has 3 line items:
1. Excavator Model XL-500 (Qty: 2)
2. Loader Model LD-300 (Qty: 1)
3. Service Package - Gold (Qty: 3)

### **Low-Level Design (LLD)**
Technical documentation with detailed specifications, data models, APIs, and implementation details for engineers.

**Audience:** Software developers, testers, DevOps engineers.

---

## M

### **Machine Configuration**
The specific setup of a machine including all options and add-ons.

**Configuration Elements:**
- Base model (e.g., XL-500)
- Bucket size (e.g., 2-yard)
- Tire type (e.g., solid rubber)
- Attachments (e.g., hydraulic breaker)
- Warranty package (e.g., 3-year extended)

**Validation:** System checks that all options are compatible (e.g., certain buckets don't fit certain models).

### **Microservice**
A small, focused software component that does one job well and can be updated independently.

**Example Services:**
- Email Service: Handles all email processing
- Quote Service: Creates and manages quotes
- Inventory Service: Tracks stock across warehouses

**Business Value:** Allows different teams to work in parallel and makes system more reliable.

---

## P

### **Pipeline Stage**
A step in the sales process that indicates where a deal stands.

**Standard Stages:**
1. **Lead:** Initial contact
2. **Qualified:** Verified as legitimate opportunity
3. **Quote Sent:** Proposal delivered
4. **Negotiation:** Discussing terms
5. **Won:** Deal closed successfully
6. **Lost:** Deal lost to competitor or cancelled

### **Priority Score**
A number (1-10) indicating how urgent and important an email or task is.

**Scoring Factors:**
- Customer importance (existing vs new, purchase history)
- Urgency keywords ("urgent", "ASAP", "today")
- Deal size estimate
- Days since last contact
- Response deadline

**High Priority (8-10):** Immediate attention required
**Medium Priority (5-7):** Respond within 4 hours
**Low Priority (1-4):** Respond within 24 hours

### **Purchase Order (PO)**
A formal document sent to the manufacturer ordering machines for a customer.

**PO Contents:**
- Product specifications
- Quantities
- Delivery location
- Expected delivery date
- Pricing terms
- Payment terms

**Automation:** System can generate PO from approved quote in under 15 minutes vs 60-90 minutes manually.

---

## Q

### **Quote**
A formal price proposal sent to a customer detailing products, configurations, pricing, terms, and validity period.

**Quote Lifecycle:**
1. Draft → In Review → Approved → Sent → Accepted/Rejected/Expired

**Validity Period:** Typically 30 days, after which prices may change.

### **Quote Configuration**
The process of selecting and customizing products in a quote.

**Validation Rules:** System ensures incompatible options aren't selected (e.g., certain attachments can't be used together).

---

## R

### **Real-Time**
Happening immediately or within seconds, not in batches later.

**Real-Time Features:**
- Inventory availability checks
- Stock reservations
- Mobile notifications
- Dashboard updates

**Business Value:** Sales reps always have current information, never promise out-of-stock machines.

### **Reservation Expiry**
When a stock reservation automatically releases after the hold period (default 7 days).

**Notification:** Sales rep is notified 1 day before expiry to either convert the quote or extend the reservation.

---

## S

### **Sales Pipeline**
See "Deal Pipeline"

### **Service Level Agreement (SLA)**
A commitment to complete an action within a specified time.

**Approval SLAs:**
- L1 (Manager): 4 hours
- L2 (Regional Manager): 8 hours
- L3 (Executive): 24 hours

**Email Response SLA:**
- High Priority: 2 hours
- Medium Priority: 4 hours
- Low Priority: 24 hours

### **Stock Reservation**
See "Inventory Reservation"

---

## T

### **Tender**
A formal request from government or large corporations asking suppliers to submit proposals for a contract.

**Tender Response Process:**
1. Identify tender opportunity (email classification)
2. Review requirements and deadline
3. Assemble response team
4. Gather documents (technical, commercial, legal)
5. Submit before deadline
6. Wait for award decision

**Typical Timeline:** 2-4 weeks from announcement to submission deadline.

**Business Value:** System helps prepare responses faster with document templates and checklists.

---

## W

### **Warehouse**
A physical location where machines are stored. Dealers typically have multiple warehouses across different cities/regions.

**Multi-Warehouse Management:** System tracks inventory at each location and shows where stock is available.

### **Workflow**
A defined sequence of steps to complete a business process.

**Example Workflow - Quote Approval:**
1. Sales rep creates quote with discount
2. System checks discount percentage
3. If >10%, routes to manager
4. Manager reviews and approves/rejects
5. If approved, sales rep is notified
6. Quote can be sent to customer

**Automation:** Workflow engine handles routing, reminders, and escalations automatically.

---

## Business Process Summaries

### **Email-to-Quote Process**
1. Customer sends inquiry email
2. System classifies and prioritizes automatically
3. Assigns to best available sales rep
4. Rep receives mobile notification
5. Rep opens email and views customer history
6. Rep creates quote with validated configuration
7. System calculates price with applicable discounts
8. If large discount, routes for approval
9. Once approved, generates professional PDF
10. Sends quote to customer via email
11. Sets automatic follow-up reminders

**Time Savings:** From 4-6 hours to 30 minutes

### **Quote-to-Order Process**
1. Customer accepts quote (email or phone)
2. Sales rep converts quote to order
3. System checks inventory availability
4. If in stock, reserves inventory
5. If not in stock, generates PO to manufacturer
6. PO routes for approval based on amount
7. Once approved, sends PO to manufacturer
8. Receives confirmation and delivery date
9. Notifies customer of delivery date
10. Updates deal pipeline to "Won"
11. Calculates commission

**Time Savings:** From 2-3 days to same day

### **Tender Response Process**
1. Tender announcement email received
2. System identifies as tender (high priority)
3. Notifies tender response team
4. Team evaluates opportunity
5. If pursuing, creates tender record
6. System loads similar past tender documents
7. Team assembles response using templates
8. Compliance checklist ensures all requirements met
9. Executive reviews and approves
10. Submit through appropriate channel
11. Track submission and await results

**Time Savings:** From 40-60 hours to 20-30 hours

---

## Key Performance Indicators (KPIs)

### **Email Management**
- **Email Response Time:** Average time from email arrival to first response
- **Classification Accuracy:** Percentage of emails correctly categorized
- **Routing Accuracy:** Percentage of emails assigned to appropriate rep

**Targets:**
- High-priority response: < 2 hours
- Classification accuracy: > 92%
- Routing accuracy: > 95%

### **Quote Management**
- **Quote Generation Time:** Time to create and send quote
- **Quote-to-Order Conversion:** Percentage of quotes that become orders
- **Configuration Error Rate:** Quotes with invalid configurations

**Targets:**
- Generation time: < 30 minutes
- Conversion rate: > 25%
- Error rate: < 2%

### **Sales Pipeline**
- **Pipeline Velocity:** Average days from lead to close
- **Pipeline Value:** Total value of all open deals
- **Win Rate:** Percentage of qualified opportunities won
- **Forecast Accuracy:** Actual sales vs forecasted sales

**Targets:**
- Velocity: < 45 days
- Win rate: > 30%
- Forecast accuracy: +/- 10%

### **Purchase Orders**
- **PO Creation Time:** Time from order decision to PO submission
- **PO Accuracy:** Percentage of POs without errors
- **Order Confirmation Time:** Time to receive manufacturer confirmation

**Targets:**
- Creation time: < 15 minutes
- Accuracy: > 98%
- Confirmation time: < 4 hours

---

## Common Questions

**Q: What happens if the ML model misclassifies an email?**
A: Sales reps can manually correct the classification. These corrections are stored and used to retrain the model, improving accuracy over time.

**Q: How long does inventory stay reserved?**
A: 7 days by default. Can be extended if needed. System sends reminder 1 day before expiry.

**Q: Can customers see the system?**
A: Customers receive quotes and communications via email. The system is primarily for internal dealer use. A customer portal could be added in the future.

**Q: What if a manager doesn't approve in time?**
A: After the SLA period (4 hours for managers), the approval request automatically escalates to the next level.

**Q: How does the system handle multiple warehouses?**
A: It checks all warehouses when looking for stock and shows options with estimated delivery times based on location.

**Q: What happens to quotes when products go out of stock?**
A: Existing quotes with reservations are protected. New quotes can still be created but show manufacturer lead time instead of immediate availability.

---

**Document Control:**
- Version: 1.0
- Last Updated: 2025-11-24
- Audience: Business stakeholders, new users, non-technical team members
- Purpose: Business terminology reference
