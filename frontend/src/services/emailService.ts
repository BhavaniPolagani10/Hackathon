// Email service - API calls for email operations
import { fetchApi } from './api';
import { EmailThread, EmailThreadWithMessages, EmailSummary } from '../types/backend';

export const emailService = {
  /**
   * Get all email threads
   */
  async getThreads(): Promise<EmailThread[]> {
    return fetchApi<EmailThread[]>('/emails/');
  },

  /**
   * Get a specific email thread with messages
   */
  async getThread(threadId: number): Promise<EmailThreadWithMessages> {
    return fetchApi<EmailThreadWithMessages>(`/emails/${threadId}`);
  },

  /**
   * Summarize an email thread using AI
   */
  async summarizeThread(threadId: number): Promise<EmailSummary> {
    return fetchApi<EmailSummary>(`/emails/${threadId}/summarize`, {
      method: 'POST',
    });
  },
};
