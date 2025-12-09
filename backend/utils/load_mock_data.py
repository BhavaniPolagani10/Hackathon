"""Load mock email data into the database"""
import asyncio
import sys
from pathlib import Path

# Add parent directory to path
sys.path.insert(0, str(Path(__file__).parent.parent))

from app.database import AsyncSessionLocal, init_db
from app.models import Email
from datetime import datetime, timedelta


MOCK_EMAILS = [
    {
        "subject": "Inquiry about CAT 320 Excavator",
        "from_email": "john.martinez@constructionpro.com",
        "from_name": "John Martinez",
        "to_email": "sarah.johnson@heavyequipdealer.com",
        "to_name": "Sarah Johnson",
        "body": """Hi,

I saw your advertisement for heavy equipment and I'm interested in learning more about CAT 320 excavators for our upcoming highway project. Could you send me some information?

Thanks,
John Martinez
Construction Pro Inc.""",
        "date": datetime.now() - timedelta(days=5)
    },
    {
        "subject": "RE: Quotation #Q-2025-1201 - CAT 320 Excavator",
        "from_email": "m.thompson@thompsonexcavating.com",
        "from_name": "Mark Thompson",
        "to_email": "lisa.anderson@heavyequipdealer.com",
        "to_name": "Lisa Anderson",
        "body": """Lisa,

Thank you for the quotation. We need 2 CAT 320 Next Gen Hydraulic Excavators with the following specs:
- 42" bucket
- Standard tracks
- AC cabin
- Rear camera

We need these delivered to our Chicago site by January 15, 2026. This is urgent as we have a major project starting.

Our shipping address is:
Thompson Excavating, 1234 Industrial Blvd, Chicago, IL 60601

Please confirm the price for 2 units and delivery timeline.

Best regards,
Mark Thompson
Thompson Excavating""",
        "date": datetime.now() - timedelta(days=3)
    },
    {
        "subject": "URGENT: Need Mini Excavator ASAP",
        "from_email": "t.russo@russolandscaping.com",
        "from_name": "Tony Russo",
        "to_email": "sarah.johnson@heavyequipdealer.com",
        "to_name": "Sarah Johnson",
        "body": """Sarah,

URGENT REQUEST - Our mini excavator broke down and we need a replacement immediately. 

Requirements:
- Kubota KX040-4 Mini Excavator or similar
- Must be in stock
- Need delivery by Monday (3 days)
- Ship to: Russo Landscaping, 234 Garden Way, Atlanta, GA 30301

We'll wire payment today if you can confirm immediate availability.

Tony Russo
Russo Landscaping""",
        "date": datetime.now() - timedelta(days=1)
    },
    {
        "subject": "Quote Request - Wheel Loader Fleet",
        "from_email": "s.baker@bakerquarry.com",
        "from_name": "Susan Baker",
        "to_email": "mike.thompson@heavyequipdealer.com",
        "to_name": "Mike Thompson",
        "body": """Mike,

We're looking to purchase 3 Komatsu WA380-8 Wheel Loaders for our quarry operations.

Specifications needed:
- Quantity: 3 units
- Extended Warranty (5 years)
- Delivery within 6-8 weeks
- Ship to: Baker Quarry Operations, 5678 Quarry Road, Denver, CO 80201

Please provide your best fleet pricing and confirm delivery timeline.

We're ready to proceed quickly if the pricing is competitive.

Susan Baker
Baker Quarry Operations""",
        "date": datetime.now() - timedelta(days=2)
    },
    {
        "subject": "Bulldozer Purchase - Trade-In Available",
        "from_email": "f.martinez@martinezgrading.com",
        "from_name": "Frank Martinez",
        "to_email": "david.brown@heavyequipdealer.com",
        "to_name": "David Brown",
        "body": """David,

We're interested in purchasing a new CAT D5 LGP Bulldozer. We also have a 2018 CAT D4K2 with 2,500 hours that we'd like to trade in.

Details:
- New Equipment: CAT D5 LGP Bulldozer
- Trade-in: 2018 CAT D4K2 (2,500 hours, excellent condition)
- Delivery: Can wait 30-45 days
- Location: Martinez Grading Inc., 789 Hilltop Road, Phoenix, AZ 85001

Please provide pricing with and without the trade-in value.

Frank Martinez
Martinez Grading Inc.""",
        "date": datetime.now() - timedelta(days=4)
    },
    {
        "subject": "Multi-Location Fleet Order",
        "from_email": "a.collins@nationalbuild.com",
        "from_name": "Andrew Collins",
        "to_email": "mike.thompson@heavyequipdealer.com",
        "to_name": "Mike Thompson",
        "body": """Mike,

We're planning a significant equipment purchase across our 5 regional locations:

Requirements:
- Dallas: 2x CAT 320 Excavators
- Phoenix: 1x CAT 320 Excavator
- Denver: 2x CAT D6 Bulldozers
- Seattle: 1x Wheel Loader 980M
- Atlanta: 2x CAT 320 Excavators

Total: 8 units

We need:
- Competitive fleet pricing
- Staggered delivery over 90 days
- Extended warranties on all units

This is a major purchase for us and we're comparing multiple vendors. Please provide your best pricing and delivery schedule.

Andrew Collins
VP Operations
National Build Corp""",
        "date": datetime.now() - timedelta(hours=12)
    }
]


async def load_mock_emails():
    """Load mock emails into database"""
    print("Initializing database...")
    await init_db()
    
    print("Loading mock email data...")
    async with AsyncSessionLocal() as session:
        for email_data in MOCK_EMAILS:
            # Check if email already exists
            from sqlalchemy import select
            result = await session.execute(
                select(Email).where(Email.subject == email_data["subject"])
            )
            existing = result.scalar_one_or_none()
            
            if existing:
                print(f"Skipping existing email: {email_data['subject']}")
                continue
            
            # Create new email (it will be auto-analyzed on creation via API)
            email = Email(
                status="new",
                **email_data
            )
            session.add(email)
            print(f"Added email: {email_data['subject']}")
        
        await session.commit()
    
    print(f"\nLoaded {len(MOCK_EMAILS)} mock emails successfully!")
    print("\nYou can now:")
    print("1. View emails at: http://localhost:8000/emails/")
    print("2. Analyze emails by sending POST to: http://localhost:8000/emails/{id}/analyze")
    print("3. Generate quotes at: http://localhost:8000/quotes/from-email/{email_id}")


if __name__ == "__main__":
    asyncio.run(load_mock_emails())
