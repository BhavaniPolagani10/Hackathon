import { Client } from '../types';

// Note: opportunityCount represents only active opportunities (excludes closed ones)
// The associatedOpportunities array may contain all opportunities including closed ones
export const clients: Client[] = [
  {
    id: '1',
    name: 'Innovate Corp',
    abbreviation: 'IC',
    abbreviationColor: '#3b82f6',
    opportunityCount: 2, // 2 active: Proposal + Needs Analysis (excludes Closed - Won)
    opportunityLabel: 'Active Opportunities',
    industry: 'Technology',
    location: 'San Francisco, CA',
    website: 'innovatecorp.com',
    associatedOpportunities: [
      {
        id: 'opp-1',
        name: 'Innovate Corp Software Upgrade',
        stage: 'Proposal',
        value: 250000,
        probability: 75,
      },
      {
        id: 'opp-2',
        name: 'Q3 Infrastructure Overhaul',
        stage: 'Needs Analysis',
        value: 150000,
        probability: 40,
      },
      {
        id: 'opp-3',
        name: 'Global Tech Expansion',
        stage: 'Closed - Won',
        value: 500000,
        signedDate: 'Mar 15',
      },
    ],
    keyContacts: [
      {
        id: 'contact-1',
        name: 'Johnathan Doe',
        title: 'Chief Technology Officer',
        avatarColor: '#e5e7eb',
      },
      {
        id: 'contact-2',
        name: 'Jane Smith',
        title: 'VP of Operations',
        avatarColor: '#e5e7eb',
      },
    ],
    conversations: [
      {
        id: 'conv-1',
        opportunityId: 'opp-1',
        opportunityName: 'Software Upgrade',
        messages: [
          {
            id: 'msg-1',
            sender: 'Alex Williams (You)',
            senderType: 'user',
            content: 'Initial discovery call completed. Client is reviewing the detailed proposal for the new enterprise software suite. Follow up scheduled for next Tuesday.',
            timestamp: '10:42 AM',
          },
          {
            id: 'msg-2',
            sender: 'Johnathan Doe (Client)',
            senderType: 'client',
            content: 'Hi Alex, the proposal looks great. We have a few questions from our technical team. Can we set up a quick call tomorrow?',
            timestamp: 'Yesterday, 3:15 PM',
          },
          {
            id: 'msg-3',
            sender: 'Alex Williams (You)',
            senderType: 'user',
            content: 'Of course, Johnathan. I\'ve sent over a calendar invite for 2 PM. Looking forward to it.',
            timestamp: '9:05 AM',
          },
          {
            id: 'msg-4',
            sender: 'Alex Williams (You)',
            senderType: 'user',
            content: 'Need to prep for the technical questions. Will loop in Sarah from engineering for the 2 PM call.',
            timestamp: '9:06 AM',
            isNote: true,
            noteTitle: 'Internal Note',
          },
        ],
      },
    ],
  },
  {
    id: '2',
    name: 'Quantum Solutions',
    abbreviation: 'QS',
    abbreviationColor: '#f59e0b',
    opportunityCount: 1,
    opportunityLabel: 'Active Opportunity',
    industry: 'Finance',
    location: 'New York, NY',
    website: 'quantumsolutions.io',
    associatedOpportunities: [
      {
        id: 'opp-4',
        name: 'Financial Platform Modernization',
        stage: 'Proposal',
        value: 350000,
        probability: 60,
      },
    ],
    keyContacts: [
      {
        id: 'contact-3',
        name: 'Michael Chen',
        title: 'CTO',
        avatarColor: '#e5e7eb',
      },
    ],
  },
  {
    id: '3',
    name: 'Apex Industries',
    abbreviation: 'AI',
    abbreviationColor: '#3b82f6',
    opportunityCount: 1,
    opportunityLabel: 'Active Opportunity',
    industry: 'Manufacturing',
    location: 'Detroit, MI',
    website: 'apexindustries.com',
    associatedOpportunities: [
      {
        id: 'opp-5',
        name: 'Supply Chain Optimization',
        stage: 'Discovery',
        value: 200000,
        probability: 30,
      },
    ],
    keyContacts: [
      {
        id: 'contact-4',
        name: 'Sarah Johnson',
        title: 'Director of Operations',
        avatarColor: '#e5e7eb',
      },
    ],
  },
  {
    id: '4',
    name: 'Global Tech',
    abbreviation: 'GT',
    abbreviationColor: '#10b981',
    opportunityCount: 1,
    opportunityLabel: 'Closed Opportunity',
    industry: 'Technology',
    location: 'Austin, TX',
    website: 'globaltech.com',
    associatedOpportunities: [
      {
        id: 'opp-6',
        name: 'Enterprise Software Implementation',
        stage: 'Closed - Won',
        value: 750000,
        signedDate: 'Feb 20',
      },
    ],
    keyContacts: [
      {
        id: 'contact-5',
        name: 'David Lee',
        title: 'CEO',
        avatarColor: '#e5e7eb',
      },
      {
        id: 'contact-6',
        name: 'Emily Brown',
        title: 'CIO',
        avatarColor: '#e5e7eb',
      },
    ],
  },
];
