'use client';

import React from 'react';
import './styles/ChatRoomItem.css';

export default function UserSearchItem({ user, onClick }) {
  return (
    <div className="chat-item-content" onClick={onClick}>
      <div className="chat-item-left">
        <div className="avatar">{getInitials(user.username)}</div>

        <div className="chat-item-text">
          <p className="chat-username">{user.username}</p>
          <p className="chat-preview">@{user.userTag}</p>
        </div>
      </div>
    </div>
  );
}

function getInitials(name) {
    if (!name) return 'U';
    const words = name.trim().split(' ');
    return words.length > 1
      ? (words[0][0] + words[1][0]).toUpperCase()
      : name.slice(0, 2).toUpperCase();
  }
  