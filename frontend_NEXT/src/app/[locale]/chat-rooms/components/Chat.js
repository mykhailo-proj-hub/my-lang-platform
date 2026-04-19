'use client';

import React, { useEffect, useState, useRef } from 'react';
import { useTranslations } from 'next-intl';
import { toast } from 'react-hot-toast';
import { FiArrowLeft, FiSmile, FiPaperclip, FiSend, FiInfo } from 'react-icons/fi';
import AvatarCircle from '@/components/AvatarCircle';
import ImprovedPreviewBar from './ImprovedPreviewBar';
import { getSocket } from '@/../socket';
import { apiUrl } from '@/lib/api';
import './styles/Chat.css';

export default function Chat({ room, currentUserId, locale, onClose, highlightedMessageId }) {
  // console.log('Chat component rendered with room:', room, 'currentUserId:', currentUserId, 'locale:', locale);
  const t = useTranslations('ChatRoom');
  const [messages, setMessages] = useState([]);
  const [input, setInput] = useState('');
  const [improveEnabled, setImproveEnabled] = useState(() => {
    if (typeof window !== 'undefined') {
      const savedState = localStorage.getItem('improveEnabled');
      return savedState !== null ? JSON.parse(savedState) : true;
    }
    return true;
  });
  const [preview, setPreview] = useState(null);
  const [showAIModal, setShowAIModal] = useState(false);

  useEffect(() => {
    const socket = getSocket();
    if (!socket || !room?.id) return;
  
    socket.emit('joinRoom', room.id);
    console.log(`📥 [Chat] joined room ${room.id}`);
  
    return () => {
      socket.emit('leaveRoom', room.id);
      console.log(`📤 [Chat] left room ${room.id}`);
    };
  }, [room.id]);

  
  useEffect(() => {
    if (typeof window !== 'undefined') {
      localStorage.setItem('improveEnabled', JSON.stringify(improveEnabled));
    }
  }, [improveEnabled]);
  
  const bottomRef = useRef(null);

  
  useEffect(() => {
    if (!room?.id) return;
    
    console.log('[LOAD MESSAGES] Triggered for room.id:', room.id);
    
    const controller = new AbortController();
    
    fetch(apiUrl(`/api/chat/chat-rooms/${room.id}/messages`), {
      credentials: 'include',
      signal: controller.signal,
    })
    .then(res => {
      if (!room?.id || !room?.participants || !currentUserId) return null;
      console.log('room.id тип:', typeof room.id, 'значення:', room.id);
      if (!res.ok) throw new Error();
      return res.json();
    })
    .then(data => {
      if (!Array.isArray(data.messages)) throw new Error();
      setMessages(data.messages);
      
      // Виклик для зміни статусу повідомлень
      fetch(apiUrl(`/api/chat/chat-rooms/${room.id}/change_message_status`), {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        credentials: 'include'
      })
      .then(res => {
        if (!res.ok) throw new Error('Failed to update message status');
        return res.json();
      })
      .then(data => {
        console.log('Message status updated:', data);
      })
      .catch(err => {
        console.error('Error updating message status:', err);
      });
    })
    .catch(err => {
      if (err.name !== 'AbortError') {
        toast.error(t('errorFetch'));
        console.error('❌ Fetch failed:', err);
      }
    });
    
    return () => controller.abort(); // 💣 Аборт запиту при зміні room
  }, [room.id, t]);
  
  const highlightedRef = useRef(null);
  
  useEffect(() => {
    if (highlightedMessageId && highlightedRef.current) {
      highlightedRef.current.scrollIntoView({ behavior: 'smooth', block: 'center' });
      highlightedRef.current.classList.add('highlight');
      
      const timeout = setTimeout(() => {
        highlightedRef.current?.classList.remove('highlight');
      }, 1500);
      
      return () => clearTimeout(timeout);
    } else if (bottomRef.current) {
      bottomRef.current.scrollIntoView({ behavior: 'smooth' });
    }
  }, [messages, highlightedMessageId]);
  
  
  const handleSubmit = async (e) => {
    e.preventDefault();
    const trimmed = input.trim();
    if (!trimmed) return;
    
    if (improveEnabled) {
      try {
        const improved = await fetchImproved(trimmed);
        setPreview({ original: trimmed, improved });
      } catch (err) {
        toast.error('Помилка при покращенні');
      }
    } else {
      sendMessage(trimmed);
      setInput('');
    }
  };
  
  // Підписка на нові повідомлення при зміні кімнати
  useEffect(() => {
    if (!room?.id) return;

    const socket = getSocket();
    if (!socket) return;

    const handleNewMessage = (msg) => {
      if (msg.roomId === room.id) {
        setMessages((prev) => [...prev, msg]);
      }
    };

    socket.on('newMessage', handleNewMessage);
    
    return () => {
      socket.off('newMessage', handleNewMessage);
    };
  }, [room.id]);
  
  
  
  const sendMessage = (text) => {
    const socket = getSocket();
    if (!socket) {
      toast.error('Socket not connected');
      return;
    }
    
    const messageData = {
      content: text,
      roomId: room.id,
      senderId: currentUserId,
    };
    
    socket.emit('sendMessage', messageData);
  };
  
  const fetchImproved = async (text) => {
    try {
      // UX: швидке покращення
      const res = await fetch(apiUrl('/api/ai/improveMessage'), {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        credentials: 'include',
        body: JSON.stringify({ content: text }),
      });
      
      if (!res.ok) throw new Error('Failed to improve message');
      
      const data = await res.json();
      
      // 🎯 У фоні — збереження в corrections
      fetch(apiUrl('/api/ai/analyzeMessage'), {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        credentials: 'include',
        body: JSON.stringify({ message: text }), // або додай messageId, якщо вже є
      }).catch(err => {
        console.warn('AnalyzeMessage in background failed:', err);
      });
      
      return data.improved;
    } catch (err) {
      console.error(err);
      toast.error('Помилка під час обробки повідомлення AI');
      throw err;
    }
  };
  
  if (!room?.id || !room?.participants || !currentUserId) {
    console.warn('Chat: missing required room or user data');
    return null;
  }

  if (!room?.participants) {
    console.warn('Chat: room.participants is missing');
    return null;
  }

  const otherUser = room?.participants?.find(p => p.id !== currentUserId);
  
  return (
    <div className="chat-container">
      {/* 🧭 Header */}
      <header className="chat-header">
        <div className="chat-header-left">
        <button className="back-btn" onClick={onClose}>
          <FiArrowLeft size={20} />
        </button>
        <AvatarCircle
          username={otherUser?.username}
          avatar={otherUser?.avatar}
          size={40}
          />
        <div className="chat-header-text">
          <p className="chat-header-name">
            {otherUser?.username || 'Очікуємо співрозмовника'}
          </p>
          {/* <p className="chat-header-status">{t('online')}</p> */}
        </div>
        </div>
        <div className="chat-header-right">
                    {/* 🔁 AI toggle */}
            <div className="chat-ai-toggle">
                <label className="ai-label">
                <input
                    type="checkbox"
                    checked={improveEnabled}
                    onChange={() => setImproveEnabled(!improveEnabled)}
                    />
                {t('AI Improved')}
                </label>
                <button
                onClick={() => setShowAIModal(true)}
                className="ai-info-btn"
                title={t('AI Improved')}
                >
                <FiInfo size={16} />
                </button>
            </div>
      </div>
      </header>
  
      {/* 💬 Chat messages */}
      <div className="chat-messages">
        {messages.map(msg => (
          <div
          key={msg.id}
          ref={msg.id === highlightedMessageId ? highlightedRef : null}
          className={msg.sender.id === currentUserId ? 'chat-out' : 'chat-in'}
          >
            {msg.sender.id !== currentUserId && (
              <AvatarCircle
                username={msg.sender.username}
                avatar={msg.sender.avatar}
                size={40}
              />
            )}
            <div className="bubble">{msg.content}</div>
            {msg.sender.id === currentUserId && (
              <AvatarCircle
                username={msg.sender.username}
                avatar={msg.sender.avatar}
                size={40}
              />
            )}
          </div>
        ))}
        <div ref={bottomRef} />
      </div>
  
      {/* 💡 AI improvement preview */}
      {preview && (
        <ImprovedPreviewBar
            original={preview.original}
            improved={preview.improved}
            onSendImproved={() => {
            sendMessage(preview.improved);
            setPreview(null);
            setInput('');
            }}
            onSendOriginal={() => {
            sendMessage(preview.original);
            setPreview(null);
            setInput('');
            }}
            onClose={() => {
            setPreview(null);
            }}
        />
        )}



  
      {/* 🧾 Input */}
      <form className="chat-input-area" onSubmit={handleSubmit}>
        <button type="button" aria-label="emoji">
          <FiSmile size={20} />
        </button>
        <button type="button" aria-label="attach">
          <FiPaperclip size={20} />
        </button>
        <input
          type="text"
          value={input}
          onChange={e => setInput(e.target.value)}
          placeholder={t('message')}
        />
        <button type="submit" aria-label="send">
          <FiSend size={20} />
        </button>
        </form>

        {showAIModal && (
        <div className="modal-overlay" onClick={() => setShowAIModal(false)}>
            <div className="modal-content" onClick={(e) => e.stopPropagation()}>
            <h3>{t('AI Improved')}</h3>
            <p>
                {t('AI Improved info')}
            </p>
            <button onClick={() => setShowAIModal(false)} className="btn-primary">OK</button>
            </div>
        </div>
        )}
    </div>
  ); 
}
