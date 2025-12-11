"""
PDF generation service for quotes
"""
import logging
import os
from typing import Optional
from datetime import datetime
from reportlab.lib.pagesizes import letter
from reportlab.lib import colors
from reportlab.lib.units import inch
from reportlab.platypus import SimpleDocTemplate, Table, TableStyle, Paragraph, Spacer, Image
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.enums import TA_CENTER, TA_RIGHT, TA_LEFT

from app.models import QuoteWithLineItems
from app.config import settings

logger = logging.getLogger(__name__)


class PDFService:
    """Service for generating PDF documents"""
    
    def __init__(self):
        """Initialize PDF service"""
        self.output_dir = settings.PDF_OUTPUT_DIR
        os.makedirs(self.output_dir, exist_ok=True)
    
    def generate_quote_pdf(self, quote: QuoteWithLineItems) -> str:
        """
        Generate PDF for a quote
        
        Args:
            quote: Quote with line items
            
        Returns:
            Path to generated PDF file
        """
        try:
            # Create filename
            filename = f"quote_{quote.quote_number.replace('-', '_')}.pdf"
            filepath = os.path.join(self.output_dir, filename)
            
            # Create PDF document
            doc = SimpleDocTemplate(
                filepath,
                pagesize=letter,
                rightMargin=0.75*inch,
                leftMargin=0.75*inch,
                topMargin=0.75*inch,
                bottomMargin=0.75*inch
            )
            
            # Build document content
            story = []
            styles = getSampleStyleSheet()
            
            # Add custom styles
            title_style = ParagraphStyle(
                'CustomTitle',
                parent=styles['Heading1'],
                fontSize=24,
                textColor=colors.HexColor('#1a237e'),
                spaceAfter=30,
                alignment=TA_CENTER
            )
            
            # Title
            story.append(Paragraph("QUOTATION", title_style))
            story.append(Spacer(1, 0.3*inch))
            
            # Quote information
            quote_info_data = [
                ['Quote Number:', quote.quote_number, 'Date:', quote.quote_date.strftime('%B %d, %Y')],
                ['Valid Until:', quote.valid_until.strftime('%B %d, %Y'), 'Status:', quote.status.upper()],
            ]
            
            quote_info_table = Table(quote_info_data, colWidths=[1.5*inch, 2.5*inch, 1.2*inch, 2*inch])
            quote_info_table.setStyle(TableStyle([
                ('FONTNAME', (0, 0), (0, -1), 'Helvetica-Bold'),
                ('FONTNAME', (2, 0), (2, -1), 'Helvetica-Bold'),
                ('FONTSIZE', (0, 0), (-1, -1), 10),
                ('TEXTCOLOR', (0, 0), (-1, -1), colors.black),
                ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
                ('VALIGN', (0, 0), (-1, -1), 'TOP'),
            ]))
            story.append(quote_info_table)
            story.append(Spacer(1, 0.3*inch))
            
            # Customer information
            story.append(Paragraph("<b>Customer Information:</b>", styles['Heading2']))
            customer_data = [
                ['Name:', quote.customer_name],
                ['Email:', quote.customer_email],
            ]
            if quote.customer_company:
                customer_data.append(['Company:', quote.customer_company])
            if quote.shipping_address:
                customer_data.append(['Shipping Address:', quote.shipping_address])
            
            customer_table = Table(customer_data, colWidths=[1.5*inch, 5.5*inch])
            customer_table.setStyle(TableStyle([
                ('FONTNAME', (0, 0), (0, -1), 'Helvetica-Bold'),
                ('FONTSIZE', (0, 0), (-1, -1), 10),
                ('VALIGN', (0, 0), (-1, -1), 'TOP'),
            ]))
            story.append(customer_table)
            story.append(Spacer(1, 0.3*inch))
            
            # Quote description/notes
            if quote.notes:
                story.append(Paragraph("<b>Description:</b>", styles['Heading2']))
                story.append(Paragraph(quote.notes, styles['Normal']))
                story.append(Spacer(1, 0.3*inch))
            
            # Line items
            story.append(Paragraph("<b>Items:</b>", styles['Heading2']))
            
            # Table headers
            line_items_data = [
                ['#', 'Product Code', 'Description', 'Qty', 'Unit Price', 'Total']
            ]
            
            # Add line items
            for item in quote.line_items:
                line_items_data.append([
                    str(item.line_number),
                    item.product_code,
                    item.product_name,
                    str(item.quantity),
                    f"${float(item.unit_price):,.2f}",
                    f"${float(item.line_total):,.2f}"
                ])
            
            # Create table
            line_items_table = Table(
                line_items_data,
                colWidths=[0.4*inch, 1.2*inch, 2.5*inch, 0.6*inch, 1.2*inch, 1.2*inch]
            )
            
            line_items_table.setStyle(TableStyle([
                # Header row styling
                ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#1a237e')),
                ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
                ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
                ('FONTSIZE', (0, 0), (-1, 0), 10),
                ('ALIGN', (0, 0), (-1, 0), 'CENTER'),
                
                # Data rows styling
                ('FONTNAME', (0, 1), (-1, -1), 'Helvetica'),
                ('FONTSIZE', (0, 1), (-1, -1), 9),
                ('ALIGN', (0, 1), (0, -1), 'CENTER'),
                ('ALIGN', (-2, 1), (-1, -1), 'RIGHT'),
                
                # Grid
                ('GRID', (0, 0), (-1, -1), 0.5, colors.grey),
                ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
                
                # Alternating row colors
                ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, colors.HexColor('#f5f5f5')]),
            ]))
            
            story.append(line_items_table)
            story.append(Spacer(1, 0.3*inch))
            
            # Totals
            totals_data = [
                ['Subtotal:', f"${float(quote.subtotal):,.2f}"],
                ['Tax ({:.1f}%):'.format(float(quote.tax_rate)), f"${float(quote.tax_amount):,.2f}"],
            ]
            
            if quote.shipping_amount and quote.shipping_amount > 0:
                totals_data.append(['Shipping:', f"${float(quote.shipping_amount):,.2f}"])
            
            if quote.discount_amount and quote.discount_amount > 0:
                totals_data.append(['Discount:', f"-${float(quote.discount_amount):,.2f}"])
            
            totals_data.append(['', ''])  # Spacer row
            totals_data.append(['TOTAL:', f"${float(quote.total_amount):,.2f}"])
            
            totals_table = Table(totals_data, colWidths=[5*inch, 2*inch])
            totals_table.setStyle(TableStyle([
                ('FONTNAME', (0, 0), (0, -2), 'Helvetica'),
                ('FONTNAME', (0, -1), (-1, -1), 'Helvetica-Bold'),
                ('FONTSIZE', (0, 0), (-1, -2), 10),
                ('FONTSIZE', (0, -1), (-1, -1), 12),
                ('ALIGN', (0, 0), (-1, -1), 'RIGHT'),
                ('LINEABOVE', (0, -1), (-1, -1), 2, colors.black),
                ('TEXTCOLOR', (0, -1), (-1, -1), colors.HexColor('#1a237e')),
            ]))
            
            story.append(totals_table)
            story.append(Spacer(1, 0.4*inch))
            
            # Terms and conditions
            story.append(Paragraph("<b>Payment Terms:</b>", styles['Heading3']))
            story.append(Paragraph(quote.payment_terms, styles['Normal']))
            story.append(Spacer(1, 0.2*inch))
            
            if quote.delivery_terms:
                story.append(Paragraph("<b>Delivery Terms:</b>", styles['Heading3']))
                story.append(Paragraph(quote.delivery_terms, styles['Normal']))
                story.append(Spacer(1, 0.2*inch))
            
            # Footer
            story.append(Spacer(1, 0.5*inch))
            footer_text = "Thank you for your business! This quote is valid until the date specified above."
            story.append(Paragraph(footer_text, styles['Normal']))
            
            # Build PDF
            doc.build(story)
            
            logger.info(f"Generated PDF for quote {quote.quote_number}: {filepath}")
            return filepath
            
        except Exception as e:
            logger.error(f"Error generating PDF: {e}")
            raise


# Global service instance
pdf_service = PDFService()
