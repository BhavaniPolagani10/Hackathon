import { Conversation } from '../types';
import './ConversationView.css';

interface ConversationViewProps {
  conversation: Conversation;
  clientName: string;
}

function ConversationView({ conversation, clientName }: ConversationViewProps) {
  // Group messages by date
  const groupedMessages = conversation.messages.reduce((groups, message) => {
    const dateKey = message.timestamp.includes('Yesterday') ? 'Yesterday' : 
                     message.timestamp.includes('AM') || message.timestamp.includes('PM') ? 'Today' : message.timestamp;
    
    if (!groups[dateKey]) {
      groups[dateKey] = [];
    }
    groups[dateKey].push(message);
    return groups;
  }, {} as Record<string, typeof conversation.messages>);

  return (
    <div className="conversation-view">
      <div className="conversation-header">
        <h1 className="conversation-title">{clientName}</h1>
        <p className="conversation-subtitle">Opportunity: {conversation.opportunityName} - Conversations</p>
      </div>

      <div className="conversation-messages">
        {Object.entries(groupedMessages).map(([dateKey, messages]) => (
          <div key={dateKey} className="message-group">
            {dateKey !== 'Today' && (
              <div className="date-separator">
                <span className="date-label">{dateKey}</span>
              </div>
            )}
            
            {messages.map((message) => (
              <div key={message.id} className="message-wrapper">
                {message.isNote ? (
                  <div className="internal-note-wrapper">
                    <div className="note-header">
                      <svg 
                        width="16" 
                        height="16" 
                        viewBox="0 0 16 16" 
                        fill="none" 
                        xmlns="http://www.w3.org/2000/svg"
                        className="note-icon"
                      >
                        <path 
                          d="M8 1a.75.75 0 0 1 .75.75v6.5h6.5a.75.75 0 0 1 0 1.5h-6.5v6.5a.75.75 0 0 1-1.5 0v-6.5h-6.5a.75.75 0 0 1 0-1.5h6.5v-6.5A.75.75 0 0 1 8 1Z" 
                          fill="currentColor"
                        />
                      </svg>
                      <span className="note-sender">{message.sender} added a note</span>
                      <span className="note-timestamp">{message.timestamp}</span>
                    </div>
                    <div className="internal-note">
                      <div className="note-title">{message.noteTitle}</div>
                      <div className="note-content">{message.content}</div>
                    </div>
                  </div>
                ) : (
                  <div className="message">
                    <div className="message-avatar">
                      <svg viewBox="0 0 36 36" fill="none" xmlns="http://www.w3.org/2000/svg">
                        <circle cx="18" cy="18" r="18" fill="#d1d5db"/>
                        <circle cx="18" cy="14" r="6" fill="#9ca3af"/>
                        <path d="M6 32c0-6.627 5.373-12 12-12s12 5.373 12 12" fill="#9ca3af"/>
                      </svg>
                    </div>
                    <div className="message-content">
                      <div className="message-header">
                        <span className="message-sender">{message.sender}</span>
                        <span className="message-timestamp">{message.timestamp}</span>
                      </div>
                      <p className="message-text">{message.content}</p>
                    </div>
                  </div>
                )}
              </div>
            ))}
          </div>
        ))}
      </div>
    </div>
  );
}

export default ConversationView;
