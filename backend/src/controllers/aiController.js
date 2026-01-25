const fetch = require('node-fetch');
const prisma = require('../prismaClient');

const removeQuotes = require('../utils/removeQuotes');
const isMessageValid = require('../utils/isMessageValid');

// ===== Виправлення повідомлення =====
exports.improveMessage = async (req, res) => {
  const { content } = req.body;
  const apiKey = process.env.OPENAI_API_KEY;

  if (!apiKey) {
    return res.status(500).json({ error: 'OPENAI_API_KEY is not set' });
  }

  if (!content || typeof content !== 'string' || content.trim().length === 0) {
    return res.status(400).json({ error: 'Invalid or empty content' });
  }

  // === 🧹 Відсіювання як в analyzeMessage ===
  const cleaned = content.trim().toLowerCase();

  const garbageRegex = /^(\p{P}|\p{S}|\s)*$/u;
  if (cleaned.length < 3 || garbageRegex.test(cleaned)) {
    return res.status(400).json({ error: 'Message is too short or invalid for improvement' });
  }

  const commonUseless = ['ok', 'okay', 'hmm', 'uh', 'yo', 'a', 'b', 'nope'];
  if (commonUseless.includes(cleaned)) {
    return res.status(400).json({ error: 'Message is not meaningful for improvement' });
  }

  const repeatedChar = /^([a-zA-Zа-яА-ЯёЁ0-9.,!?])\1{2,}$/u;
  if (repeatedChar.test(cleaned)) {
    return res.status(400).json({ error: 'Message is repeated single character' });
  }

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
            content:
              'You are a helpful assistant that improves the grammar, clarity, and tone of English sentences without changing their meaning.',
          },
          {
            role: 'user',
            content: `Please improve this English sentence grammatically and stylistically without changing its meaning:\n"${content}"`,
          },
        ],
        temperature: 0.6,
        max_tokens: 100,
      }),
    });

    if (!response.ok) {
      const errorBody = await response.text();
      console.error('OpenAI API error body:', errorBody);
      return res.status(502).json({ error: 'OpenAI API error', detail: errorBody });
    }

    const data = await response.json();
    let improved = data.choices?.[0]?.message?.content?.trim();

    if (!improved) {
      throw new Error('No valid response from OpenAI');
    }

    const removeQuotes = (text) => {
      return text.trim().replace(/^["'“”‘’«»„‚‹›](.*?)[“”‘’"'\«»„‚‹›]$/, '$1');
    };

    improved = removeQuotes(improved);
    res.json({ improved });
  } catch (err) {
    console.error('Improve API error:', err);
    res.status(500).json({ error: 'Failed to improve message' });
  }
};

// ===== Аналіз повідомлення (граматика) =====
exports.analyzeMessage = async (req, res) => {
  const { message, messageId } = req.body;
  const apiKey = process.env.OPENAI_API_KEY;

  if (!apiKey) {
    return res.status(500).json({ error: 'OPENAI_API_KEY is not set' });
  }

  if (!message || typeof message !== 'string' || message.trim().length === 0) {
    return res.status(400).json({ error: 'Invalid or empty message' });
  }

  if (!isMessageValid(message)) {
    return res.status(400).json({ error: 'Message is not valid for analysis' });
  }

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
            content:
              "You are a language tutor. When given an English sentence with a possible mistake, respond with a JSON object containing:\n" +
              "- 'corrected': the corrected version of the sentence\n" +
              "- 'explanation': a short grammar explanation (1–2 sentences)\n" +
              "- 'type': one of the following: 'tense', 'article', 'preposition', 'verb_agreement', 'word_order', 'plural', 'spelling', 'other'"
          },
          {
            role: 'user',
            content: `Analyze this sentence: "${message}"`
          }
        ],
        temperature: 0.4,
        max_tokens: 300,
      }),
    });

    if (!response.ok) {
      const errorBody = await response.text();
      console.error('OpenAI API error body:', errorBody);
      return res.status(502).json({ error: 'OpenAI API error', detail: errorBody });
    }

    const data = await response.json();
    const content = data.choices?.[0]?.message?.content?.trim();

    let parsed;
    try {
      parsed = JSON.parse(content);
    } catch (err) {
      console.error('Failed to parse AI response:', content);
      return res.status(500).json({ error: 'Failed to parse AI response', raw: content });
    }

    let { corrected, explanation, type } = parsed;

    if (!corrected || !explanation || !type) {
      return res.status(400).json({ error: 'Incomplete AI response', raw: parsed });
    }

    // Очистити лапки
    corrected = removeQuotes(corrected);

    // Перевірка типу помилки
    const validTypes = ['tense', 'article', 'preposition', 'verb_agreement', 'word_order', 'plural', 'spelling', 'other'];
    if (!validTypes.includes(type)) {
      return res.status(400).json({ error: 'Invalid correction type', type, raw: parsed });
    }

    // Зберегти у БД, якщо передано messageId
    if (messageId) {
      await prisma.corrections.create({
        data: {
          original: message,
          corrected,
          explanation,
          type,
          messageId,
        },
      });
    }

    res.json({ corrected, explanation, type });
  } catch (err) {
    console.error('AnalyzeMessage API error:', err);
    res.status(500).json({ error: 'Failed to analyze message' });
  }
};
