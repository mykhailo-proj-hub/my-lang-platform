const { Server } = require('socket.io');
const db = require('./prismaClient'); // шлях залежить від структури

function initializeSocket(server) {
  const io = new Server(server, {
    cors: {
      origin: 'http://localhost:3000',
      credentials: true
    }
  });
  
  // Налаштування CORS для Socket.IO
  io.on('error', (err) => {
    console.error('Socket.IO error:', err);
  });

  // Обробка підключення клієнтів
  io.on('connection', (socket) => {
    console.log('🔌 Client connected:', socket.id);
    const userId = Number(socket.handshake.query.userId);

    if (userId) {
      socket.join(`user_${userId}`);
      console.log(`🟢 User ${userId} joined their personal room`);
    }

    // Приєднання до кімнати
    socket.on('joinRoom', (roomId) => {
      socket.join(roomId);
      console.log(`🟢 Joined room ${roomId}`);
    });
      // Вихід з кімнати
    socket.on('leaveRoom', (roomId) => {
      socket.leave(roomId);
      console.log(`🔴 Socket ${socket.id} вийшов з кімнати ${roomId}`);
    });
    // Отримання повідомлення від клієнта
    socket.on('sendMessage', async (message) => {
      try {
        const savedMessage = await db.chat_messages.create({
          data: {
            content: message.content,
            roomId: message.roomId,
            senderId: message.senderId,
          },
          include: {
            sender: {
              select: { id: true, username: true, avatar: true }
            }
          }
        });

        const messageData = {
          id: savedMessage.id,
          content: savedMessage.content,
          createdAt: savedMessage.createdAt,
          status: savedMessage.status,
          roomId: savedMessage.roomId,
          sender: {
            id: savedMessage.sender.id,
            username: savedMessage.sender.username,
            avatar: savedMessage.sender.avatar || null
          }
        };

        io.to(message.roomId).emit('newMessage', messageData);
      } catch (error) {
        console.error('Error saving message:', error);
      }
    });
    // Обробка відключення клієнта
    socket.on('disconnect', () => {
      console.log('❌ Client disconnected:', socket.id);
    });
  });

  return io;
}

module.exports = initializeSocket;