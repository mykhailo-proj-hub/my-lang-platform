// controllers/chatController.js

const prisma = require('../prismaClient');

/**
 * GET /api/chat-rooms
 * Повертає всі кімнати, в яких бере участь поточний користувач,
 * з останнім повідомленням та списком учасників.
 */
exports.listChatRooms = async (req, res) => {
  try {
    const userId = req.user.id;
    const { search } = req.query;

    const baseWhere = {
      room_users: {
        some: { userId }
      }
    };

    const rooms = await prisma.chat_rooms.findMany({
      where: baseWhere,
      include: {
        room_users: {
          include: {
            user: {
              select: { id: true, username: true, avatar: true }
            }
          }
        },
        messages: {
          orderBy: { createdAt: 'desc' },
          include: {
            sender: {
              select: { id: true, username: true, avatar: true }
            }
          }
        },
        _count: {
          select: {
            messages: {
              where: {
                status: 'Sent',
                senderId: { not: userId }
              }
            }
          }
        }
      }
    });

    const filteredRooms = rooms
      .map(room => {
        const participants = room.room_users.map(ru => ru.user);

        // 🔎 Пошук підходящого повідомлення
        let lastRelevantMessage = null;
        if (search) {
          const lowerSearch = search.toLowerCase();
          lastRelevantMessage = room.messages.find(m =>
            m.content.toLowerCase().includes(lowerSearch)
          );
        }

        const fallbackMessage = room.messages[0] || null;
        const lastMessage = lastRelevantMessage || fallbackMessage;

        // 🔍 Якщо пошук є, і немає збігу ні в повідомленнях, ні в учасниках — виключаємо кімнату
        if (search) {
          const userMatch = participants.some(p =>
            p.username.toLowerCase().includes(search.toLowerCase())
          );
          if (!lastRelevantMessage && !userMatch) {
            return null;
          }
        }

        return {
          id: room.id,
          theme: room.theme,
          participants,
          lastMessage,
          unreadCount: room._count.messages || 0
        };
      })
      .filter(Boolean);

    return res.json(filteredRooms);
  } catch (err) {
    console.error('listChatRooms error:', err);
    return res.status(500).json({ error: err.message || "Internal server error" });
  }
};


/**
 * POST /api/chat-rooms
 * Створює нову кімнату з поточним користувачем і (опційно) партнером.
 * Тіло запиту: { theme: string, partnerId?: number }
 */
// avatar!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
exports.createChatRoom = async (req, res, io) => {
  const { theme, partnerId } = req.body;
  const userId = req.user.id;

  if (!theme && !partnerId) {
    return res.status(400).json({ error: "Не вказано тему або користувача для приватного чату" });
  }

  try {
    // 🔄 Якщо partnerId не вказаний — спроба знайти відкриту кімнату
    if (!partnerId) {
      const existing = await prisma.chat_rooms.findFirst({
        where: {
          theme,
          isOpen: true,
          room_users: {
            some: { userId: { not: userId } } // Щоб не приєднуватись до власної кімнати
          }
        },
        include: {
          room_users: {
            include: { user: true }
          }
        }
      });

      if (existing) {
        // Додаємо користувача в існуючу кімнату
        await prisma.room_users.create({
          data: {
            userId,
            roomId: existing.id
          }
        });

        const participants = [...existing.room_users.map(ru => ru.user), req.user];

        const updatedRoom = {
          id: existing.id,
          theme: existing.theme,
          participants,
          lastMessage: null,
          unreadCount: 0
        };

        // Закриваємо кімнату
        await prisma.chat_rooms.update({
          where: { id: existing.id },
          data: { isOpen: false }
        });

        participants.forEach(p => {
          io.to(`user_${p.id}`).emit('newChat', updatedRoom);
        });

        return res.status(201).json(updatedRoom);
      }
    }

    // 🆕 Якщо не знайдено — створюємо нову кімнату
    const connectUsers = [{ id: userId }];
    if (partnerId) {
      if (partnerId === userId) {
        return res.status(400).json({ error: "Неможливо створити чат із самим собою" });
      }
      connectUsers.push({ id: partnerId });
    }

    const room = await prisma.chat_rooms.create({
      data: {
        theme: theme || null,
        isOpen: !partnerId, // відкритий тільки якщо це створення по темі
        room_users: {
          create: connectUsers.map(u => ({ user: { connect: { id: u.id } } }))
        }
      },
      include: {
        room_users: {
          include: { user: true }
        }
      }
    });

    const participants = room.room_users.map(ru => ({
      id: ru.user.id,
      username: ru.user.username,
      avatar: ru.user.avatar || null
    }));

    const newRoomData = {
      id: room.id,
      theme: room.theme,
      participants,
      lastMessage: null,
      unreadCount: 0
    };

    participants.forEach(p => {
      io.to(`user_${p.id}`).emit('newChat', newRoomData);
    });

    res.status(201).json(newRoomData);
  } catch (err) {
    console.error("createChatRoom error:", err);
    res.status(500).json({ error: "Не вдалося створити чат-кімнату" });
  }
};


/**
 * GET /api/chat-rooms/:roomId/messages
 * Повертає всі повідомлення з кімнати roomId (за зростанням createdAt).
 */
exports.listMessages = async (req, res) => {
  const roomId = parseInt(req.params.roomId, 10);
  const userId = req.user.id;

  // 🔒 Перевірка коректності roomId
  if (!roomId || isNaN(roomId)) {
    return res.status(400).json({ error: "Невірний roomId" });
  }

  try {
    // 🔐 Перевірка, що користувач має доступ до кімнати
    const membership = await prisma.room_users.findUnique({
      where: { userId_roomId: { userId, roomId } }
    });

    if (!membership) {
      return res.status(403).json({ error: "Доступ заборонений" });
    }

    // 📥 Отримання всіх повідомлень кімнати з відправником
    const messages = await prisma.chat_messages.findMany({
      where: { roomId },
      orderBy: { createdAt: 'asc' },
      include: {
        sender: {
          select: {
            id: true,
            username: true,
            avatar: true
          }
        }
      }
    });

    // ✅ Повертаємо структуровану відповідь
    return res.json({
      roomId,
      messages: messages.map(m => ({
        id: m.id,
        content: m.content,
        createdAt: m.createdAt,
        status: m.status,
        sender: {
          id: m.sender.id,
          username: m.sender.username,
          avatar: m.sender.avatar || null
        }
      }))
    });
  } catch (err) {
    console.error("❌ listMessages error:", err);
    return res.status(500).json({ error: "Не вдалося завантажити повідомлення" });
  }
};


exports.getChatRoomById = async (req, res) => {
  const roomId = parseInt(req.params.roomId, 10);
  const userId = req.user.id;

  if (!roomId || isNaN(roomId)) {
    return res.status(400).json({ error: 'Невірний roomId' });
  }

  try {
    const membership = await prisma.room_users.findUnique({
      where: {
        userId_roomId: {
          userId,
          roomId
        }
      }
    });

    if (!membership) {
      return res.status(403).json({ error: 'Доступ заборонено' });
    }

    const room = await prisma.chat_rooms.findUnique({
      where: { id: roomId },
      include: {
        room_users: {
          include: {
            user: {
              select: {
                id: true,
                username: true,
                avatar: true
              }
            }
          }
        }
      }
    });

    if (!room) {
      return res.status(404).json({ error: 'Кімнату не знайдено' });
    }

    const participants = room.room_users.map(ru => ru.user);

    res.json({
      id: room.id,
      theme: room.theme,
      participants
    });
  } catch (err) {
    console.error('getChatRoomById error:', err);
    res.status(500).json({ error: 'Не вдалося завантажити кімнату' });
  }
};


/**
 * POST /api/chat-rooms/:roomId/messages
 * Створює нове повідомлення в кімнаті roomId.
 * Тіло запиту: { content: string }
 */
exports.sendMessage = async (req, res, io) => {
  const roomId = parseInt(req.params.roomId, 10);
  const userId = req.user.id;
  const { content } = req.body;

  if (!roomId || !content) {
    return res.status(400).json({ error: "Невірні дані" });
  }

  try {
    const membership = await prisma.room_users.findUnique({
      where: { userId_roomId: { userId, roomId } }
    });
    if (!membership) {
      return res.status(403).json({ error: "Доступ заборонений" });
    }

    const message = await prisma.chat_messages.create({
      data: {
        content,
        room: { connect: { id: roomId } },
        sender: { connect: { id: userId } }
      },
      include: {
        sender: { select: { id: true, username: true, avatar: true } }
      }
    });

    const messageData = {
      id: message.id,
      content: message.content,
      createdAt: message.createdAt,
      status: message.status,
      roomId: message.roomId,
      sender: {
        id: message.sender.id,
        username: message.sender.username,
        avatar: message.sender.avatar || null
      }
    };

    io.to(roomId).emit('newMessage', messageData);

    res.status(201).json(messageData);
  } catch (err) {
    console.error("sendMessage error:", err);
    res.status(500).json({ error: "Не вдалося надіслати повідомлення" });
  }
};
exports.changeMessageStatus = async (req, res, io) => {
  const roomId = parseInt(req.params.roomId, 10);
  const userId = req.user.id;

  if (!roomId) {
    return res.status(400).json({ error: "Невірні дані" });
  }

  try {
    const membership = await prisma.room_users.findUnique({
      where: { userId_roomId: { userId, roomId } }
    });
    if (!membership) {
      return res.status(403).json({ error: "Доступ заборонений" });
    }

    const messagesToUpdate = await prisma.chat_messages.findMany({
        where: {
            roomId,
            senderId: { not: userId },
            status: 'Sent'
        }
    });

    if (messagesToUpdate.length > 0) {
        await prisma.chat_messages.updateMany({
            where: {
                id: { in: messagesToUpdate.map(m => m.id) }
            },
            data: {
                status: 'Read'
            }
        });

        const senderIds = [...new Set(messagesToUpdate.map(m => m.senderId))];
        senderIds.forEach(senderId => {
            io.to(`user_${senderId}`).emit('messagesRead', { roomId });
        });
    }
    
    res.status(200).json({ success: true });

  } catch (err) {
    console.error("changeMessageStatus error:", err);
    return res.status(500).json({ error: "Не вдалося оновити статус повідомлень" });
  }
};

exports.searchUserByTag = async (req, res) => {
  const { tag } = req.query;
  const userId = req.user.id;

  if (!tag || tag.trim().length < 3) {
    return res.status(400).json({ error: 'Invalid tag' });
  }

  try {
    // Крок 1: Знаходимо до 10 користувачів за userTag
    const users = await prisma.app_users.findMany({
      where: {
        userTag: {
          startsWith: tag,
          mode: 'insensitive' // щоб не залежало від регістру
        },
        id: { not: userId } // не включати самого себе
      },
      take: 10,
      select: {
        id: true,
        username: true,
        avatar: true,
        userTag: true
      }
    });

    const userIds = users.map(u => u.id);

    if (userIds.length === 0) return res.json([]);

    // Крок 2: Знаходимо кімнати, де є поточний користувач і будь-хто з результатів
    const rooms = await prisma.chat_rooms.findMany({
      where: {
        AND: [
          {
            room_users: {
              some: { userId: userId }
            }
          },
          {
            room_users: {
              some: { userId: { in: userIds } }
            }
          }
        ]
      },
      include: {
        room_users: {
          include: {
            user: {
              select: {
                id: true,
                username: true,
                avatar: true
              }
            }
          }
        },
        messages: {
          orderBy: { createdAt: 'desc' },
          take: 1,
          include: {
            sender: {
              select: {
                id: true,
                username: true,
                avatar: true
              }
            }
          }
        }
      }
    });
    

    // Крок 3: Формуємо фінальну відповідь
    const results = users.flatMap(user => {
      const matchingRooms = rooms.filter(room =>
        room.room_users.some(ru => ru.user.id === userId) &&
        room.room_users.some(ru => ru.user.id === user.id)
      );
    
      if (matchingRooms.length > 0) {
        return matchingRooms.map(room => ({
          type: 'room',
          roomId: room.id,
          participants: room.room_users.map(ru => ru.user),
          lastMessage: room.messages[0] || null
        }));
      }
    
      return {
        type: 'user',
        user
      };
    });

    res.json(results);
    
  } catch (err) {
    console.error('searchUserByTag error:', err);
    res.status(500).json({ error: 'Search failed' });
  }
};

