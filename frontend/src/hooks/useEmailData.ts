// Custom hook to fetch email threads and transform to opportunities
import { useState, useEffect } from 'react';
import { emailService } from '../services/emailService';
import { quoteService } from '../services/quoteService';
import { transformThreadToOpportunity, transformThreadToClient } from '../utils/dataTransform';
import { Opportunity, Client } from '../types';

export function useEmailData() {
  const [opportunities, setOpportunities] = useState<Opportunity[]>([]);
  const [clients, setClients] = useState<Client[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    async function fetchData() {
      try {
        setLoading(true);
        setError(null);

        // Fetch all email threads
        const threads = await emailService.getThreads();

        // Transform threads to opportunities with quote data
        // Fetch quotes in parallel for better performance
        const quotePromises = threads.map(thread => {
          if (thread.status === 'quote_generated' && thread.thread_id) {
            return quoteService.generateQuote(thread.thread_id);
          }
          return Promise.resolve(undefined);
        });

        const quoteResults = await Promise.allSettled(quotePromises);
        
        // Transform threads to opportunities with their respective quotes
        const opportunitiesData: Opportunity[] = threads.map((thread, index) => {
          const quoteResult = quoteResults[index];
          let quote;
          
          if (quoteResult.status === 'fulfilled') {
            quote = quoteResult.value;
          } else if (quoteResult.status === 'rejected') {
            console.error(`Failed to fetch quote for thread ${thread.thread_id}:`, quoteResult.reason);
          }
          
          return transformThreadToOpportunity(thread, quote);
        });

        setOpportunities(opportunitiesData);

        // Fetch detailed thread data with messages for clients view
        const clientsData: Client[] = [];
        for (const thread of threads.slice(0, 5)) { // Limit to first 5 for performance
          if (thread.thread_id) {
            try {
              const threadWithMessages = await emailService.getThread(thread.thread_id);
              const client = transformThreadToClient(threadWithMessages);
              if (client) {
                clientsData.push(client);
              }
            } catch (err) {
              console.error(`Failed to fetch thread ${thread.thread_id}:`, err);
            }
          }
        }

        setClients(clientsData);
      } catch (err) {
        console.error('Failed to fetch email data:', err);
        setError(err instanceof Error ? err.message : 'Failed to fetch data');
      } finally {
        setLoading(false);
      }
    }

    fetchData();
  }, []);

  return { opportunities, clients, loading, error };
}

export function useQuoteGeneration(threadId: number | null) {
  const [quote, setQuote] = useState<any>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const generateQuote = async () => {
    if (!threadId) return;

    try {
      setLoading(true);
      setError(null);
      const quoteData = await quoteService.generateQuote(threadId);
      setQuote(quoteData);
    } catch (err) {
      console.error('Failed to generate quote:', err);
      setError(err instanceof Error ? err.message : 'Failed to generate quote');
    } finally {
      setLoading(false);
    }
  };

  return { quote, loading, error, generateQuote };
}
