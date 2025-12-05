import { FileIcon, FileText, Paperclip, MessageSquare } from 'lucide-react';
import { Client, Conversation } from '../types';
import './ConversationDetail.css';

interface ConversationDetailProps {
  client: Client;
  conversation: Conversation;
}

function ConversationDetail({ client, conversation }: ConversationDetailProps) {
  // Group messages by date
  const messagesByDate: { [key: string]: typeof conversation.messages } = {};
  conversation.messages.forEach((msg) => {
    if (!messagesByDate[msg.date]) {
      messagesByDate[msg.date] = [];
    }
    messagesByDate[msg.date].push(msg);
  });

  return (
    <div className="conversation-detail">
      <div className="conversation-detail-content">
        <div className="conversation-header">
          <div
            className="conversation-client-abbr"
            style={{ backgroundColor: client.abbreviationColor }}
          >
            {client.abbreviation}
          </div>
          <div className="conversation-header-info">
            <h1 className="conversation-client-name">{client.name}</h1>
            <span className="conversation-opportunity">
              Opportunity: {conversation.opportunityName} - Conversations
            </span>
          </div>
        </div>

        <div className="conversation-messages">
          {Object.entries(messagesByDate).map(([date, messages]) => (
            <div key={date} className="message-date-group">
              {messages.map((msg) => (
                <div key={msg.id} className="message-item">
                  <div className="message-avatar">
                    <svg viewBox="0 0 36 36" fill="none" xmlns="http://www.w3.org/2000/svg">
                      <circle cx="18" cy="18" r="18" fill={msg.senderType === 'user' ? '#fef3c7' : '#e5e7eb'} />
                      <circle cx="18" cy="14" r="6" fill="#9ca3af" />
                      <path d="M6 32c0-6.627 5.373-12 12-12s12 5.373 12 12" fill="#9ca3af" />
                    </svg>
                  </div>
                  <div className="message-content">
                    <div className="message-header">
                      <span className="message-sender">
                        {msg.senderName} {msg.senderType === 'user' ? '(You)' : '(Client)'}
                      </span>
                      <span className="message-time">
                        {date !== 'Today' && date !== 'Yesterday' ? date + ', ' : date === 'Yesterday' ? 'Yesterday, ' : ''}
                        {msg.timestamp}
                      </span>
                    </div>
                    <p className="message-text">{msg.message}</p>
                  </div>
                </div>
              ))}
              
              {date === 'Today' && (
                <div className="date-separator">
                  <span>Today</span>
                </div>
              )}
            </div>
          ))}

          {conversation.notes.length > 0 && (
            <div className="notes-section">
              {conversation.notes.map((note) => (
                <div key={note.id} className="note-container">
                  <div className="note-header">
                    <span className="note-icon">✦</span>
                    <span className="note-author">{note.authorName} added a note</span>
                    <span className="note-time">{note.timestamp}</span>
                  </div>
                  <div className="note-content">
                    <h4 className="note-title">{note.title}</h4>
                    <p className="note-text">{note.content}</p>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>

      <aside className="conversation-detail-sidebar">
        <button className="sidebar-action" aria-label="Notes">
          <FileIcon size={20} />
        </button>
        <button className="sidebar-action" aria-label="Documents">
          <FileText size={20} />
        </button>
        <button className="sidebar-action" aria-label="Attachments">
          <Paperclip size={20} />
        </button>
        <button className="sidebar-action active" aria-label="Comments">
          <MessageSquare size={20} />
        </button>
      </aside>
    </div>
  );
}

export default ConversationDetail;
