// Quote service - API calls for quote operations
import { fetchApi } from './api';
import { QuoteWithLineItems, ProductPricing } from '../types/backend';

export const quoteService = {
  /**
   * Generate a quote from an email thread
   */
  async generateQuote(threadId: number): Promise<QuoteWithLineItems> {
    return fetchApi<QuoteWithLineItems>(`/quotes/generate?thread_id=${threadId}`, {
      method: 'POST',
    });
  },

  /**
   * Get product pricing information
   */
  async getProductPricing(productCode: string): Promise<ProductPricing> {
    return fetchApi<ProductPricing>(`/quotes/pricing/${productCode}`);
  },

  /**
   * Get PDF download URL for a quote
   */
  getQuotePdfUrl(quoteNumber: string, threadId: number): string {
    return `/quotes/${quoteNumber}/pdf?thread_id=${threadId}`;
  },
};
