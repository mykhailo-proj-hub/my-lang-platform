const fetch = require('node-fetch');

exports.improveMessage = async (req, res) => {
  const { content } = req.body;
  const apiKey = process.env.OPENAI_API_KEY;

  if (!apiKey) {
    return res.status(500).json({ error: 'OPENAI_API_KEY is not set' });
  }

  if (!content || typeof content !== 'string' || content.trim().length === 0) {
    return res.status(400).json({ error: 'Invalid or empty content' });
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
    const improved = data.choices?.[0]?.message?.content?.trim();

    if (!improved) {
      throw new Error('No valid response from OpenAI');
    }

    res.json({ improved });
  } catch (err) {
    console.error('Improve API error:', err);
    res.status(500).json({ error: 'Failed to improve message' });
  }
};
