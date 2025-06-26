const prisma = require('../prismaClient');
const generatePracticeTasks = require('../utils/generatePracticeTasks');

// ===== Отримання щоденних завдань для практики =====
exports.getDailyPractice = async (req, res) => {
    try {
      const userId = req.user.id;  
      const tasks = await generatePracticeTasks(userId);
      if (!tasks || tasks.length === 0) {
        console.warn('[getDailyPractice] No tasks found for user:', userId);
      }
  
      res.json({ tasks });
    } catch (err) {
      console.error('[getDailyPractice] Error:', err);
      res.status(500).json({ error: 'Failed to generate practice tasks' });
    }
  };
  
  // ===== Збереження результатів практики =====
  exports.saveResultAndArchive = async (req, res) => {
    const { score, total, taskIds } = req.body;
    const userId = req.user?.id;
  
    if (!userId || typeof score !== 'number' || typeof total !== 'number' || !Array.isArray(taskIds)) {
      return res.status(400).json({ error: 'Invalid input data' });
    }
  
    const today = new Date();
    today.setHours(0, 0, 0, 0);
  
    try {
      // 1. Зберігаємо або оновлюємо user_progress
      const userProgress = await prisma.user_progress.upsert({
        where: {
          userId_date: {
            userId,
            date: today,
          },
        },
        update: { score, total },
        create: {
          userId,
          date: today,
          score,
          total,
        },
      });
  
      // 2. Отримуємо завдання за taskIds
      const tasks = await prisma.daily_generated_tasks.findMany({
        where: {
          id: { in: taskIds },
          userId,
          answer: { not: null },
        },
      });
  
      if (tasks.length === 0) {
        return res.status(400).json({ error: 'No completed tasks to archive' });
      }
  
      // 3. Отримуємо taskId, які вже прив’язані
      const alreadyLinked = await prisma.user_progress_archive.findMany({
        where: {
          archivedTaskId: { in: taskIds },
          userProgressId: userProgress.id,
        },
        select: { archivedTaskId: true },
      });
  
      const alreadyArchivedIds = new Set(alreadyLinked.map(t => t.archivedTaskId));
      const toArchive = tasks.filter(t => !alreadyArchivedIds.has(t.id));
  
      if (toArchive.length === 0) {
        return res.json({
          success: true,
          archived: false,
          message: 'Already archived',
          score,
        });
      }
  
      // 4. Архівуємо задачі
      await prisma.archived_practice_tasks.createMany({
        data: toArchive.map(task => ({
          userId: task.userId,
          date: task.date,
          question: task.question,
          options: task.options,
          correct: task.correct,
          explanation: task.explanation,
          type: task.type,
          answer: task.answer,
        })),
      });
  
      // 5. Отримуємо тільки-но вставлені (найсвіжіші)
      const archivedNow = await prisma.archived_practice_tasks.findMany({
        where: {
          userId,
          question: { in: toArchive.map(t => t.question) },
          date: { gte: today },
        },
        orderBy: { id: 'desc' },
        take: toArchive.length,
      });
  
      // 6. Прив’язуємо до user_progress
      await prisma.user_progress_archive.createMany({
        data: archivedNow.map(task => ({
          userProgressId: userProgress.id,
          archivedTaskId: task.id,
        })),
      });
  
      return res.json({
        success: true,
        archived: archivedNow.length,
        score,
      });
    } catch (err) {
      console.error('[saveResultAndArchive] Error:', err);
      return res.status(500).json({ error: 'Failed to save and archive' });
    }
  };
  
  // ===== Збереження відповіді на окреме завдання =====
exports.savePracticeAnswer = async (req, res) => {
    const { taskId, answer } = req.body;
    const userId = req.user?.id;
    if (!userId || !taskId || typeof answer !== 'string') {
      return res.status(400).json({ error: 'Invalid input' });
    }
  
    try {
        const id = Number(taskId);  
        const updated = await prisma.daily_generated_tasks.updateMany({
        where: {
            id,
            userId,
        },
        data: { answer },
        });
  
      if (updated.count === 0) {
        return res.status(404).json({ error: 'Task not found or unauthorized' });
      }
  
      res.json({ success: true });
    } catch (err) {
      console.error('[savePracticeAnswer] Error:', err);
      res.status(500).json({ error: 'Failed to save answer' });
    }
  };

// ===== Регенація практики =====
exports.clearPractice = async (req, res) => {
  const userId = req.user?.id;
  if (!userId) return res.status(401).json({ error: 'Unauthorized' });

  const today = new Date();
  today.setHours(0, 0, 0, 0);

  try {
    await prisma.daily_generated_tasks.deleteMany({
      where: { userId, date: { gte: today } },
    });

    return res.json({ success: true });
  } catch (err) {
    console.error('[regeneratePractice] Error:', err);
    return res.status(500).json({ error: 'Failed to clear tasks' });
  }
};

