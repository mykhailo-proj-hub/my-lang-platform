'use client';

import React, { useState, useEffect, startTransition  } from 'react';
import Split from 'react-split';
import { useParams, useSearchParams, useRouter } from 'next/navigation';
import { useTranslations } from 'next-intl';
import { useAuth } from '@/context/AuthContext';
import { getSocket } from '@/../socket'; // Імпортуємо сокет для реального часу
import ChatRoomsList from './components/ChatRoomsList';
import Chat from './components/Chat';
import NewChat from './components/NewChat';
import { toggleRoom } from './components/ToggleRoom';
import ProtectedRoute from '@/components/ProtectedRoute';
import styles from './page.module.css';
import './components/styles/Split.css';

export default function ChatRoomsPage() {
  const { user, loading } = useAuth();
  const currentUserId = user?.id;
  const { locale } = useParams();
  const searchParams = useSearchParams();
  const router = useRouter();
  const t = useTranslations('ChatRoom');
  const [activeRoom, setActiveRoom] = useState(null);
  const [rooms, setRooms] = useState([]);
  const [theme, setTheme] = useState('');
  const [creating, setCreating] = useState(false);

  useEffect(() => {
    const socket = getSocket();
    if (!user || !socket) return;

    const handleNewMessageForRoomList = (msg) => {
      setRooms(prevRooms => {
        const roomExists = prevRooms.some(r => r.id === msg.roomId);
        if (!roomExists) return prevRooms;

        return prevRooms.map(r => {
          if (r.id === msg.roomId) {
            const isUnread = r.id !== activeRoom?.id && msg.sender.id !== currentUserId;
            return {
              ...r,
              lastMessage: { ...msg, senderId: msg.sender.id },
              unreadCount: isUnread ? (r.unreadCount || 0) + 1 : r.unreadCount,
            };
          }
          return r;
        }).sort((a, b) => {
            if (!a.lastMessage) return 1;
            if (!b.lastMessage) return -1;
            return new Date(b.lastMessage.createdAt) - new Date(a.lastMessage.createdAt);
        });
      });
    };

    const handleNewRoom = (room) => {
      setRooms(prevRooms => [room, ...prevRooms]);
      const socket = getSocket();
      if (socket) {
        socket.emit('joinRoom', room.id);
      }
    };

    const handleMessagesRead = ({ roomId }) => {
      setRooms(prevRooms =>
        prevRooms.map(r => {
          if (r.id === roomId && r.lastMessage?.senderId === currentUserId) {
            return { ...r, lastMessage: { ...r.lastMessage, status: 'Read' } };
          }
          return r;
        })
      );
    };

    socket.on('newMessage', handleNewMessageForRoomList);
    socket.on('newChat', handleNewRoom);
    socket.on('messagesRead', handleMessagesRead);

    return () => {
      socket.off('newMessage', handleNewMessageForRoomList);
      socket.off('newChat', handleNewRoom);
      socket.off('messagesRead', handleMessagesRead);
    };
  }, [activeRoom?.id, currentUserId, user, setRooms]);

  useEffect(() => {
    const roomId = searchParams.get('roomId');
    if (!roomId || isNaN(parseInt(roomId))) {
      console.warn('❌ Невалідний roomId', roomId);
      return;
    }
    if (!loading && user && roomId && (!activeRoom || activeRoom.id !== parseInt(roomId))) {
      const roomFromList = rooms.find(r => r.id === parseInt(roomId));
      if (roomFromList) {
          setActiveRoom(roomFromList);
      } else {
        fetch(`http://localhost:5000/api/chat/chat-rooms/${roomId}`, {
          credentials: 'include'
        })
          .then(res => res.ok ? res.json() : Promise.reject(new Error('Failed to load full room')))
          .then(data => {
            setActiveRoom(data);
          })
          .catch(err => console.error('❌ Failed to load full room:', err));
      }
    }
  }, [searchParams, loading, user, rooms, activeRoom]);
  
  const closeRoom = () => {
    router.replace(`/${locale}/chat-rooms`);
    startTransition(() => {
      setActiveRoom(null);
    });
  };
  
  const toggleRoom = (room, highlightedMessageId = null) => {
    if (!room || (activeRoom && activeRoom.id === room.id)) {
      closeRoom();
      return;
    }
  
    // Обнулення непрочитаних
    setRooms(prev =>
      prev.map(r => r.id === room.id ? { ...r, unreadCount: 0 } : r)
    );
  
    const roomWithHighlight = highlightedMessageId
      ? { ...room, highlightedMessageId }
      : room;
  
    setActiveRoom(roomWithHighlight);
    router.push(`/${locale}/chat-rooms?roomId=${room.id}`);
  };
  

  if (loading || !user) {
    return <div>Loading...</div>;
  }
  
  return (
    <ProtectedRoute>
      <main className={styles.container}>
        <Split
          className="split"
          sizes={[60, 40]}
          minSize={[450, 450]}
          gutterSize={6}
        >
          <div className={styles.leftPanel}>
          <ChatRoomsList
            currentUserId={currentUserId}
            locale={locale}
            rooms={rooms}
            setRooms={setRooms}
            setActiveRoom={toggleRoom}
          />
          </div>

          <div className={styles.rightPanel}>
            {console.log('Rendering Chat component with activeRoom:', activeRoom, 'currentUserId:', currentUserId, 'locale:', locale)}
            {activeRoom && currentUserId ? (
              <Chat
              key={activeRoom.id}
              room={activeRoom}
              currentUserId={currentUserId}
              locale={locale}
              highlightedMessageId={activeRoom.highlightedMessageId}
              onClose={closeRoom}
            />
            ) : (
              <NewChat
                theme={theme}
                setTheme={setTheme}
                creating={creating}
                setCreating={setCreating}
              />
            )}

          </div>
        </Split>
      </main>
    </ProtectedRoute>
  );
}