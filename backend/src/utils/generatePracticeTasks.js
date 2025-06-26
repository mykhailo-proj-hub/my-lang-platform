const prisma = require('../prismaClient');
const fetch = require('node-fetch');

const getShuffled = (arr) => [...arr].sort(() => 0.5 - Math.random());

const ensureTheoryExists = async (type) => {
  const existing = await prisma.correction_theory.findUnique({ where: { type } });

  if (existing && !existing.content.startsWith('This is an auto-generated placeholder')) {
    return;
  }

  const apiKey = process.env.OPENAI_API_KEY;

  try {
    const response = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${apiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'gpt-3.5-turbo',
        messages: [
          {
            role: 'system',
            content: 'You are a language tutor. You explain English grammar topics clearly for learners with basic English (A2 level).',
          },
          {
            role: 'user',
            content: `Please explain the grammar topic "${type}" in 3–5 sentences. Give it a simple title and clear description.`,
          },
        ],
        temperature: 0.5,
        max_tokens: 300,
      }),
    });

    const data = await response.json();
    const raw = data.choices?.[0]?.message?.content?.trim();
    const [titleLine, ...contentLines] = raw.split('\n').filter(Boolean);
    const title = titleLine.replace(/^#+\s*/, '').trim();
    const content = contentLines.join(' ').trim();

    await prisma.correction_theory.upsert({
      where: { type },
      update: {
        title: title || type,
        content: content || `Explanation for ${type}.`,
      },
      create: {
        type,
        title: title || type,
        content: content || `Explanation for ${type}.`,
      },
    });

    console.log(`✅ Theory for type "${type}" created or updated via AI`);
  } catch (err) {
    console.error('❌ Failed to fetch theory from OpenAI:', err);
  }
};



const generateTasksByAI = async (level) => {
  const apiKey = process.env.OPENAI_API_KEY;
  const res = await fetch('https://api.openai.com/v1/chat/completions', {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${apiKey}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      model: 'gpt-3.5-turbo',
      messages: [
        {
          role: 'system',
          content: `You are a language tutor. Generate 5 grammar practice tasks for level ${level}. Each task should include:\n- 'question': a sentence with a blank or error\n- 'options': 4 options to choose from\n- 'correct': the correct answer\n- 'explanation': grammar explanation\n- 'type': grammar type (tense, article, etc)\n\nReturn JSON array.`,
        },
      ],
      temperature: 0.5,
      max_tokens: 700,
    }),
  });

  const data = await res.json();
  const rawContent = data.choices?.[0]?.message?.content?.trim();

  // 🧹 Очистка markdown-форматування
  const cleanedContent = rawContent.replace(/^```json\s*|\s*```$/g, '').trim();
  
  try {
    return JSON.parse(cleanedContent);
  } catch (err) {
    console.error('❌ Failed to parse AI practice JSON:', rawContent);
    return [];
  }
};

const generatePracticeTasks = async (userId) => {

  const todayStart = new Date();
  todayStart.setHours(0, 0, 0, 0);

  const todayTasks = await prisma.daily_generated_tasks.findMany({
    where: {
      userId,
      date: {
        gte: todayStart,
      },
    },
    orderBy: { id: 'asc' }, // ✅ гарантує стабільний порядок завдань
  });
  if (todayTasks.length > 0) {
    const theoryMap = Object.fromEntries(
      await Promise.all(
        todayTasks.map(async (task) => {
          const theory = await prisma.correction_theory.findUnique({ where: { type: task.type } });
          return [task.id, theory];
        })
      )
    );

    const result = todayTasks.map((task) => ({
      id: task.id, // 🔍 перевіряємо, що повертається число
      type: 'multiple_choice',
      question: task.question,
      options: task.options,
      correct: task.correct,
      explanation: task.explanation,
      theory: theoryMap[task.id] || null,
      answer: task.answer ?? null,
    }));
    
    console.log('📤 Tasks returned to client:', result.map(t => t.id));
    return result;
  }
  const threeDaysAgo = new Date(Date.now() - 3 * 24 * 60 * 60 * 1000);

  const corrections = await prisma.corrections.findMany({
    where: {
      message: {
        senderId: userId,
      },
      explanation: {
        not: null,
      },
      createdAt: {
        gte: threeDaysAgo,
      },
    },
    include: {
      message: true,
    },
    orderBy: {
      createdAt: 'desc',
    },
    take: 20,
  });

  if (!corrections || corrections.length === 0) {
    console.log('🔍 No recent corrections found for user:', userId);
  
    const user = await prisma.app_users.findUnique({ where: { id: userId } });
    const level = user?.level || 'A2';
  
    let aiTasks = await generateTasksByAI(level);
    if (aiTasks.length === 0) return []
    // ✅ Фільтрація тільки валідних задач
    aiTasks = aiTasks.filter(
      (task) =>
        Array.isArray(task.options) &&
        task.options.includes(task.correct) &&
        task.question &&
        task.correct &&
        task.explanation &&
        task.type
    );
    
    const fallback = [];
    
    for (const task of aiTasks) {
      await ensureTheoryExists(task.type);
    
      const saved = await prisma.daily_generated_tasks.create({
        data: {
          userId,
          question: task.question,
          options: task.options,
          correct: task.correct,
          explanation: task.explanation,
          type: task.type,
        },
      });
    
      fallback.push({
        id: saved.id,
        type: 'multiple_choice',
        question: saved.question,
        options: saved.options,
        correct: saved.correct,
        explanation: saved.explanation,
        theory: await prisma.correction_theory.findUnique({ where: { type: saved.type } }),
        answer: null,
      });
      console.log(`✅ AI task saved: ${saved.id} (${task.type})`);
      if (fallback.length >= 5) break;
    }
    
    return fallback;
    
  }

  const shuffled = getShuffled(corrections);
  const tasks = [];

  for (const correction of shuffled) {
    const theory = await prisma.correction_theory.findUnique({ where: { type: correction.type } });
    if (!theory) continue;

    const incorrectOption = correction.original;
    const correctOption = correction.corrected;

    tasks.push({
      id: correction.id,
      type: 'multiple_choice',
      question: correction.original.replace(correctOption, '____'),
      options: getShuffled([correctOption, incorrectOption, '???', '...']),
      correct: correctOption,
      explanation: correction.explanation,
      theory,
    });

    if (tasks.length >= 5) break;
  }

  return tasks;
};

module.exports = generatePracticeTasks;
