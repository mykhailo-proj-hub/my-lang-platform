'use client';

import React from 'react';
import { useTranslations } from 'next-intl';
import AvatarCircle from '@/components/AvatarCircle';
import './styles/ChatRoomItem.css';


export default function ChatRoomItem({ room, currentUserId, locale, unreadCount, onSelect }) {
  const t = useTranslations('ChatRoom');
  const otherUser = room.participants.find(p => p.id !== currentUserId);
  const lastMsg = room.lastMessage;

  const formatTime = (date) => {
    const now = new Date();
    const messageDate = new Date(date);

    const isToday = now.toDateString() === messageDate.toDateString();
    if (isToday) {
      return new Intl.DateTimeFormat(locale, { hour: '2-digit', minute: '2-digit' }).format(messageDate);
    }

    const yesterday = new Date(now);
    yesterday.setDate(now.getDate() - 1);
    const isYesterday = yesterday.toDateString() === messageDate.toDateString();
    if (isYesterday) {
      return t('yesterday');
    }

    const weekAgo = new Date(now);
    weekAgo.setDate(now.getDate() - 7);
    if (messageDate > weekAgo) {
      return new Intl.DateTimeFormat(locale, { weekday: 'short' }).format(messageDate);
    }

    return new Intl.DateTimeFormat(locale, { day: '2-digit', month: '2-digit', year: 'numeric' }).format(messageDate);
  };

  const timeStr = lastMsg?.createdAt ? formatTime(lastMsg.createdAt) : '';

  return (
    <div
      className="chat-item-link"
      onClick={onSelect}
      role="button"
      tabIndex={0}
      onKeyDown={(e) => (e.key === 'Enter' || e.key === ' ') && onSelect()}
    >     
      <div className="chat-item-content">
        {/* Лівий блок */}
        <div className="chat-item-left">
          <AvatarCircle username={otherUser?.username} avatar={otherUser?.avatar}/>
          <div className="chat-item-text">
            <p className="chat-username">{otherUser?.username || 'Очікуємо співрозмовника'}</p>
            <p className="chat-preview">
              {lastMsg?.content
                ? lastMsg.content.length > 20
                  ? `${lastMsg.content.slice(0, 20)}…`
                  : lastMsg.content
                : t('No messages yet')}
            </p>
          </div>
        </div>

        {/* Правий блок */}
        <div className="chat-item-right">
          {timeStr && <span className="chat-time">{timeStr}</span>}
          {lastMsg && (
            <span
              className={`unread-badge ${
                currentUserId !== lastMsg.senderId && lastMsg.status === 'Sent' ? 'highlight' : ''
              }`}
            >
              {currentUserId === lastMsg.senderId && lastMsg.status === 'Sent' && '✔'}
              {currentUserId === lastMsg.senderId && lastMsg.status === 'Read' && '✔✔'}
              {currentUserId !== lastMsg.senderId && unreadCount == 0 && null}
              {currentUserId !== lastMsg.senderId && unreadCount !== 0 && (unreadCount > 99 ? '99+' : unreadCount)}
            </span>
          )}
        </div>
    </div>
    </div>
    );
}
