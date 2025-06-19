const express = require('express');
const chatController = require('../controllers/chatController');
const authenticate = require('../middleware/authMiddleware');

module.exports = function(io) {
  const router = express.Router();

// Пошук за тегом
router.get('/chat-rooms/search-user', authenticate, chatController.searchUserByTag);

// Список чатів
router.get('/chat-rooms', authenticate, chatController.listChatRooms);

// Створення кімнати
router.post('/chat-rooms', authenticate, (req, res) =>
  chatController.createChatRoom(req, res, io)
);

// Повідомлення кімнати
router.get('/chat-rooms/:roomId/messages', authenticate, chatController.listMessages);

// Зміна статусу повідомлення
router.post('/chat-rooms/:roomId/change_message_status', authenticate, (req, res) =>
  chatController.changeMessageStatus(req, res, io)
);

// Деталі кімнати
router.get('/chat-rooms/:roomId', authenticate, chatController.getChatRoomById);

  return router;
};
