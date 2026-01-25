const prisma = require('../prismaClient');

// 🔹 Аналітика чату: кількість чатів та повідомлень
exports.chatAnalytics = async (req, res) => {
  try {
    const userId = req.user.id;

    const chatsCreated = await prisma.chat_rooms.count({
      where: {
        room_users: {
          some: { userId }
        }
      }
    });

    const messagesSent = await prisma.chat_messages.count({
      where: { senderId: userId }
    });

    // Можна реалізувати точну тривалість на базі timestamps
    const averageDuration = '15 min';

    res.status(200).json({
      chatsCreated,
      messagesSent,
      averageDuration
    });
  } catch (err) {
    console.error('Chat analytics error:', err);
    res.status(500).json({ error: 'Помилка при отриманні аналітики чату' });
  }
};

// 🔹 Аналітика практики: кількість сесій, правильні/неправильні
exports.practiceStats = async (req, res) => {
  try {
    const userId = req.user.id;

    const totalSessions = await prisma.user_progress.count({
      where: { userId }
    });

    const progress = await prisma.user_progress.findMany({
      where: { userId },
      select: { score: true, total: true, date: true }
    });

    const correctAnswers = progress.reduce((acc, item) => acc + item.score, 0);
    const incorrectAnswers = progress.reduce((acc, item) => acc + (item.total - item.score), 0);

    const lastPracticeDate = progress
      .sort((a, b) => new Date(b.date) - new Date(a.date))[0]?.date
      ?.toISOString()
      ?.split('T')[0] || null;

    res.status(200).json({
      totalSessions,
      correctAnswers,
      incorrectAnswers,
      lastPracticeDate
    });
  } catch (err) {
    console.error('Practice stats error:', err);
    res.status(500).json({ error: 'Помилка при отриманні статистики практики' });
  }
};
