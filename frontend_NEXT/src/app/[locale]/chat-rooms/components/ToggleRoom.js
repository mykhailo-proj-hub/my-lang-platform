export const toggleRoom = ({
    activeRoom,
    room,
    highlightedMessageId,
    locale,
    setActiveRoom,
    setRooms,
    router
  }) => {
    if (!room || (activeRoom && activeRoom.id === room.id)) {
      setActiveRoom(null);
  
      // ✅ очищаємо roomId з URL
      router.replace(`/${locale}/chat-rooms`);
      return;
    }
  
    // Обнуляємо непрочитані
    setRooms(prev =>
      prev.map(r => r.id === room.id ? { ...r, unreadCount: 0 } : r)
    );
  
    const roomWithHighlight = highlightedMessageId
      ? { ...room, highlightedMessageId }
      : room;
  
    setActiveRoom(roomWithHighlight);
    router.push(`/${locale}/chat-rooms?roomId=${room.id}`);
  };
  