'use client';

import React, { useEffect, useCallback, useState } from 'react';
import { useTranslations } from 'next-intl';
import { debounce } from 'lodash';
import ChatRoomItem from './ChatRoomItem';
import UserSearchItem from './UserSearchItem';
import './styles/ChatRoomList.css';

export default function ChatRoomsList({ currentUserId, locale, rooms, loading, setRooms, setActiveRoom: handleSetActiveRoom }) {  const t = useTranslations('ChatRoom');
  const [search, setSearch] = useState('');
  const [tagResults, setTagResults] = useState([]);
  const [tagSearchLoading, setTagSearchLoading] = useState(false);
  const [loadingRooms, setLoadingRooms] = useState(true);
  const [searchResults, setSearchResults] = useState([]);

  useEffect(() => {
    const savedRaw = localStorage.getItem('chatSearch');
    if (!savedRaw) return;
  
    try {
      const saved = JSON.parse(savedRaw);
      const now = Date.now();
      const twoHours = 2 * 60 * 60 * 1000;
  
      if (now - saved.timestamp < twoHours) {
        setSearch(saved.value);
        handleSearchChange({ target: { value: saved.value } }); // виклик пошуку
      } else {
        localStorage.removeItem('chatSearch');
      }
    } catch {
      localStorage.removeItem('chatSearch');
    }
  }, []);
  
  
  useEffect(() => {
    fetchRooms('');
  }, []);

  useEffect(() => {
    localStorage.setItem('chatSearch', JSON.stringify({
      value: search,
      timestamp: Date.now()
    }));  }, [search]);
  
  useEffect(() => {
    if (!search.startsWith('@')) {
      fetchRooms(search);
    }
  }, [search]);


const fetchRooms = useCallback(debounce((searchTerm) => {
  setLoadingRooms(true);
  const url = new URL('http://localhost:5000/api/chat/chat-rooms');
  if (searchTerm) url.searchParams.append('search', searchTerm);
  
  fetch(url, { credentials: 'include' })
    .then(res => res.ok ? res.json() : Promise.reject(new Error('Failed to load rooms')))
    .then(data => {
      const sorted = data.sort((a, b) => {
        if (!a.lastMessage) return 1;
        if (!b.lastMessage) return -1;
        return new Date(b.lastMessage.createdAt) - new Date(a.lastMessage.createdAt);
      });
      setSearchResults(searchTerm ? sorted : []);
      if (!searchTerm) setRooms(sorted);
    })
    .catch(console.error)
    .finally(() => setLoadingRooms(false));
}, 500), []);
  

const handleSearchChange = async (e) => {
  const query = e.target.value;
  setSearch(query);

  if (query.startsWith('@')) {
    const tag = query.slice(1);
    if (tag.length > 2) {
      setTagSearchLoading(true);
      try {
        const res = await fetch(`http://localhost:5000/api/chat/chat-rooms/search-user?tag=${tag}`, {
          credentials: 'include'
        });

        const data = await res.json();
        if (res.ok && Array.isArray(data)) {
          setTagResults(data);
        } else {
          setTagResults([]);
        }
      } catch (error) {
        console.error('Error searching user by tag:', error);
        setTagResults([]);
      } finally {
        setTagSearchLoading(false);
      }
    } else {
      setTagResults([]);
    }
  } else {
    setTagResults([]);
    fetchRooms(query);
  }
};


  
const handleCreateChatWithUser = async (user) => {
  try {
    const res = await fetch('http://localhost:5000/api/chat/chat-rooms', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      credentials: 'include',
      body: JSON.stringify({
        partnerId: user.id,
        theme: `${currentUserId}_${user.id}` // або будь-який унікальний theme
      })
    });

    if (!res.ok) {
      throw new Error('Failed to create chat room');
    }

    const data = await res.json();

    // Оновлюємо список кімнат (не обов’язково)
    setRooms(prev => [data, ...prev]);

    // Відкриваємо чат
    handleSetActiveRoom(data);
  } catch (err) {
    console.error('❌ Error creating chat room:', err);
  }
};


  const visibleRooms = search ? searchResults : rooms;

  if (loading) return <p className="loading-text">{t('Loading')}</p>;

  return (
    <div className="chat-rooms-list">
      <input
        type="text"
        placeholder={t('Search')}
        className="search-input"
        value={search}
        onChange={handleSearchChange}
        aria-label={t('Search')}
      />

      <div className="chat-list">
      {tagResults.map(result => {
        if (result.type === 'room') {
          return (
            <ChatRoomItem
              key={result.roomId}
              room={{
                id: result.roomId,
                participants: result.participants,
                lastMessage: result.lastMessage || null,
              }}
              currentUserId={currentUserId}
              locale={locale}
              onSelect={() =>
                handleSetActiveRoom(
                  {
                    id: result.roomId,
                    participants: result.participants,
                    lastMessage: result.lastMessage || null,
                  },
                  result.lastMessage?.id || null
                )
              }
            />
          );
        }

        if (result.type === 'user') {
          return (
            <UserSearchItem
              key={result.user.id}
              user={result.user}
              onClick={() => handleCreateChatWithUser(result.user)}
            />
          );
        }

        return null;
      })}


        {loadingRooms ? (
          <p className="loading-text">{t('Loading')}</p>
        ) : search.startsWith('@') ? (
          tagResults.length === 0 && !tagSearchLoading ? (
            <p className="no-rooms-text">{t('No chat rooms')}</p>
          ) : null
        ) : visibleRooms.length > 0 ? (
          visibleRooms.map(room => {
            const highlightId = search ? room.lastMessage?.id : null;
            return (
              <ChatRoomItem
                key={room.id}
                room={room}
                currentUserId={currentUserId}
                locale={locale}
                onSelect={() => handleSetActiveRoom(room, highlightId)}
              />
            );
          })
        ) : (
          <p className="no-rooms-text">{t('No chat rooms')}</p>
        )}

      </div>
    </div>
  );
}
