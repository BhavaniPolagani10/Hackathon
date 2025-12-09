"""PDF generation service for quotes"""
from reportlab.lib.pagesizes import letter
from reportlab.lib import colors
from reportlab.lib.units import inch
from reportlab.platypus import SimpleDocTemplate, Table, TableStyle, Paragraph, Spacer, Image
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.enums import TA_CENTER, TA_RIGHT, TA_LEFT
from io import BytesIO
from datetime import datetime
from typing import Dict


class PDFGenerator:
    """Generate professional PDF quotes"""
    
    @staticmethod
    def generate_quote_pdf(quote_data: Dict) -> BytesIO:
        """Generate a PDF for the quote"""
        buffer = BytesIO()
        doc = SimpleDocTemplate(buffer, pagesize=letter, 
                               rightMargin=0.5*inch, leftMargin=0.5*inch,
                               topMargin=0.5*inch, bottomMargin=0.5*inch)
        
        # Container for the 'Flowable' objects
        elements = []
        styles = getSampleStyleSheet()
        
        # Custom styles
        title_style = ParagraphStyle(
            'CustomTitle',
            parent=styles['Heading1'],
            fontSize=24,
            textColor=colors.HexColor('#1a5490'),
            spaceAfter=30,
            alignment=TA_CENTER
        )
        
        heading_style = ParagraphStyle(
            'CustomHeading',
            parent=styles['Heading2'],
            fontSize=14,
            textColor=colors.HexColor('#1a5490'),
            spaceAfter=12,
            spaceBefore=12
        )
        
        # Title
        elements.append(Paragraph("QUOTATION", title_style))
        elements.append(Spacer(1, 0.2*inch))
        
        # Quote information
        # Helper function for valid_until formatting
        def format_valid_until(valid_until_data):
            if isinstance(valid_until_data, str):
                return valid_until_data
            elif isinstance(valid_until_data, datetime):
                return valid_until_data.strftime('%B %d, %Y')
            else:
                return datetime.now().strftime('%B %d, %Y')
        
        quote_info_data = [
            ['Quote Number:', quote_data['quote_number']],
            ['Date:', datetime.now().strftime('%B %d, %Y')],
            ['Valid Until:', format_valid_until(quote_data.get('valid_until'))],
            ['Status:', quote_data['status'].upper()],
        ]
        
        quote_info_table = Table(quote_info_data, colWidths=[2*inch, 4*inch])
        quote_info_table.setStyle(TableStyle([
            ('ALIGN', (0, 0), (0, -1), 'RIGHT'),
            ('ALIGN', (1, 0), (1, -1), 'LEFT'),
            ('FONTNAME', (0, 0), (0, -1), 'Helvetica-Bold'),
            ('FONTSIZE', (0, 0), (-1, -1), 10),
            ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
        ]))
        
        elements.append(quote_info_table)
        elements.append(Spacer(1, 0.3*inch))
        
        # Customer information
        elements.append(Paragraph("Customer Information", heading_style))
        
        customer_data = [
            ['Customer Name:', quote_data['customer_name']],
            ['Company:', quote_data.get('customer_company', 'N/A')],
            ['Email:', quote_data['customer_email']],
            ['Shipping Address:', quote_data.get('shipping_address', 'To be provided')],
        ]
        
        customer_table = Table(customer_data, colWidths=[2*inch, 5*inch])
        customer_table.setStyle(TableStyle([
            ('ALIGN', (0, 0), (0, -1), 'RIGHT'),
            ('ALIGN', (1, 0), (1, -1), 'LEFT'),
            ('FONTNAME', (0, 0), (0, -1), 'Helvetica-Bold'),
            ('FONTSIZE', (0, 0), (-1, -1), 10),
            ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
        ]))
        
        elements.append(customer_table)
        elements.append(Spacer(1, 0.3*inch))
        
        # Products table
        elements.append(Paragraph("Products & Pricing", heading_style))
        
        # Table header
        product_data = [['Item', 'Description', 'Qty', 'Unit Price', 'Total']]
        
        # Add products
        for idx, product in enumerate(quote_data['products']):
            product_data.append([
                str(idx + 1),
                product['name'],
                str(product['quantity']),
                f"${product['unit_price']:,.2f}",
                f"${product['total_price']:,.2f}"
            ])
        
        # Calculate column widths
        col_widths = [0.5*inch, 3.5*inch, 0.7*inch, 1.3*inch, 1.3*inch]
        
        product_table = Table(product_data, colWidths=col_widths)
        product_table.setStyle(TableStyle([
            # Header
            ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#1a5490')),
            ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
            ('ALIGN', (0, 0), (-1, 0), 'CENTER'),
            ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
            ('FONTSIZE', (0, 0), (-1, 0), 11),
            ('BOTTOMPADDING', (0, 0), (-1, 0), 12),
            
            # Body
            ('ALIGN', (0, 1), (0, -1), 'CENTER'),
            ('ALIGN', (2, 1), (2, -1), 'CENTER'),
            ('ALIGN', (3, 1), (-1, -1), 'RIGHT'),
            ('FONTNAME', (0, 1), (-1, -1), 'Helvetica'),
            ('FONTSIZE', (0, 1), (-1, -1), 10),
            ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, colors.HexColor('#f0f0f0')]),
            ('GRID', (0, 0), (-1, -1), 0.5, colors.grey),
            ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
            ('BOTTOMPADDING', (0, 1), (-1, -1), 8),
            ('TOPPADDING', (0, 1), (-1, -1), 8),
        ]))
        
        elements.append(product_table)
        elements.append(Spacer(1, 0.2*inch))
        
        # Summary table
        summary_data = [
            ['Subtotal:', f"${quote_data['subtotal']:,.2f}"],
            ['Tax (8%):', f"${quote_data['tax']:,.2f}"],
            ['Shipping:', f"${quote_data['shipping_cost']:,.2f}"],
            ['TOTAL:', f"${quote_data['total']:,.2f}"],
        ]
        
        summary_table = Table(summary_data, colWidths=[5.5*inch, 1.8*inch])
        summary_table.setStyle(TableStyle([
            ('ALIGN', (0, 0), (0, -1), 'RIGHT'),
            ('ALIGN', (1, 0), (1, -1), 'RIGHT'),
            ('FONTNAME', (0, 0), (-1, 2), 'Helvetica'),
            ('FONTNAME', (0, 3), (-1, 3), 'Helvetica-Bold'),
            ('FONTSIZE', (0, 0), (-1, -1), 11),
            ('FONTSIZE', (0, 3), (-1, 3), 13),
            ('TEXTCOLOR', (0, 3), (-1, 3), colors.HexColor('#1a5490')),
            ('LINEABOVE', (0, 3), (-1, 3), 2, colors.HexColor('#1a5490')),
            ('BOTTOMPADDING', (0, 0), (-1, -1), 8),
        ]))
        
        elements.append(summary_table)
        elements.append(Spacer(1, 0.3*inch))
        
        # Delivery information
        if quote_data.get('estimated_delivery'):
            elements.append(Paragraph("Delivery Information", heading_style))
            delivery_data = [
                ['Estimated Delivery:', quote_data['estimated_delivery']],
                ['Urgency:', quote_data.get('urgency', 'Medium').upper()],
            ]
            if quote_data.get('delivery_deadline'):
                delivery_data.append(['Requested Deadline:', quote_data['delivery_deadline']])
            
            delivery_table = Table(delivery_data, colWidths=[2*inch, 5*inch])
            delivery_table.setStyle(TableStyle([
                ('ALIGN', (0, 0), (0, -1), 'RIGHT'),
                ('ALIGN', (1, 0), (1, -1), 'LEFT'),
                ('FONTNAME', (0, 0), (0, -1), 'Helvetica-Bold'),
                ('FONTSIZE', (0, 0), (-1, -1), 10),
                ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
            ]))
            elements.append(delivery_table)
            elements.append(Spacer(1, 0.2*inch))
        
        # Notes
        if quote_data.get('notes'):
            elements.append(Paragraph("Notes", heading_style))
            notes_style = ParagraphStyle('Notes', parent=styles['Normal'], fontSize=9)
            elements.append(Paragraph(quote_data['notes'], notes_style))
            elements.append(Spacer(1, 0.2*inch))
        
        # Terms and Conditions
        if quote_data.get('terms_and_conditions'):
            elements.append(Paragraph("Terms & Conditions", heading_style))
            terms_style = ParagraphStyle('Terms', parent=styles['Normal'], fontSize=8, leading=10)
            # Split terms into paragraphs
            terms_text = quote_data['terms_and_conditions'].replace('\n', '<br/>')
            elements.append(Paragraph(terms_text, terms_style))
        
        # Build PDF
        doc.build(elements)
        
        buffer.seek(0)
        return buffer
