// Opportunity service - API calls for opportunity operations
import { fetchApi } from './api';
import { Opportunity } from '../types';

export const opportunityService = {
  /**
   * Get opportunity details by opportunity number
   */
  async getOpportunityDetails(opportunityNumber: string): Promise<Opportunity> {
    return fetchApi<Opportunity>(`/opportunities/${opportunityNumber}`);
  },

  /**
   * List all opportunities with optional filtering
   */
  async listOpportunities(params?: {
    customerId?: number;
    stage?: string;
    isClosed?: boolean;
    limit?: number;
  }): Promise<Opportunity[]> {
    const queryParams = new URLSearchParams();
    
    if (params?.customerId) {
      queryParams.append('customer_id', params.customerId.toString());
    }
    if (params?.stage) {
      queryParams.append('stage', params.stage);
    }
    if (params?.isClosed !== undefined) {
      queryParams.append('is_closed', params.isClosed.toString());
    }
    if (params?.limit) {
      queryParams.append('limit', params.limit.toString());
    }
    
    const endpoint = queryParams.toString() 
      ? `/opportunities/?${queryParams.toString()}`
      : '/opportunities/';
    
    return fetchApi<Opportunity[]>(endpoint);
  },
};
