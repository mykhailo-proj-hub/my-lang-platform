'use client';

import React from 'react';
import '../styles/AvatarCircle.css';

export default function AvatarCircle({ username = '', avatar = null, size = 45 }) {
  const getInitials = (name = '') => {
    const parts = name.trim().split(/\s+/).filter(Boolean);
    const first = parts[0]?.charAt(0).toUpperCase() || '';
    const second = parts[1]?.charAt(0).toUpperCase() || '';
    return first + second;
  };

  return avatar ? (
    <img
      src={avatar}
      alt={username}
      className="avatar"
      style={{ width: size, height: size }}
    />
  ) : (
    <div
      className="avatar"
      style={{ width: size, height: size }}
    >
      {username && username.trim() !== '' ? getInitials(username) : '👤'}
    </div>
  );
}
