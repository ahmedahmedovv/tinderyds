// Netlify Function to proxy OpenAI API requests
// This keeps your API key secure on the server side

// Simple in-memory cache (resets on function cold start)
const cache = new Map();
const CACHE_TTL = 1000 * 60 * 60; // 1 hour

exports.handler = async (event, context) => {
    // Enable CORS
    const headers = {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'Content-Type',
        'Access-Control-Allow-Methods': 'POST, OPTIONS'
    };

    // Handle preflight requests
    if (event.httpMethod === 'OPTIONS') {
        return {
            statusCode: 200,
            headers,
            body: ''
        };
    }

    // Only allow POST requests
    if (event.httpMethod !== 'POST') {
        return {
            statusCode: 405,
            headers,
            body: JSON.stringify({ error: 'Method not allowed' })
        };
    }

    try {
        const { word, linkingWord, linkingWordsPrompt } = JSON.parse(event.body);
        
        if (!word) {
            return {
                statusCode: 400,
                headers,
                body: JSON.stringify({ error: 'Word is required' })
            };
        }

        // Check cache first
        const cacheKey = `${word}:${linkingWord || 'default'}`;
        const cached = cache.get(cacheKey);
        if (cached && Date.now() - cached.timestamp < CACHE_TTL) {
            console.log('Cache hit for word:', word);
            return {
                statusCode: 200,
                headers,
                body: JSON.stringify(cached.data)
            };
        }

        // Get API key from environment variable (set in Netlify dashboard)
        const apiKey = process.env.OPENAI_API_KEY;
        
        if (!apiKey) {
            console.error('OPENAI_API_KEY environment variable is not set');
            return {
                statusCode: 500,
                headers,
                body: JSON.stringify({ error: 'API key not configured' })
            };
        }

        const systemPrompt = 'You are a helpful English vocabulary tutor. Provide clear, concise definitions and natural example sentences. Respond ONLY in JSON format.';

        const userPrompt = `Provide a BRIEF academic definition (1 concise sentence, max 20 words) and ONE academic example sentence that USES BOTH "${word}" AND the linking word "${linkingWord || 'however'}" in the SAME sentence.

CRITICAL INSTRUCTION: 
- Create a SINGLE coherent academic sentence (max 25 words) that naturally incorporates BOTH words
- The sentence must demonstrate the logical function of the linking word in relation to "${word}"
- If the linking word shows CONTRAST (however, nevertheless, although) - show opposition or unexpected relationship
- If the linking word shows ADDITION (furthermore, moreover, in addition) - add related information
- If the linking word shows CAUSE/EFFECT (therefore, consequently, thus) - show a result or consequence
- If the linking word shows SEQUENCE (subsequently, eventually, initially) - show time progression
- If the linking word shows EXAMPLE (for example, for instance) - illustrate with a specific case

The sentence must be grammatically correct and the linking word must connect ideas WITHIN the same sentence as "${word}".

${linkingWordsPrompt ? 'Available linking words: ' + linkingWordsPrompt + '.' : ''}

Format as JSON: {"definition": "...", "example": "..."}`;

        console.log('Sending request to OpenAI for word:', word);
        const startTime = Date.now();

        let response;
        try {
            // Use OpenAI Chat Completions API with gpt-4o-mini (faster than Responses API)
            response = await fetch('https://api.openai.com/v1/chat/completions', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${apiKey}`
                },
                body: JSON.stringify({
                    model: 'gpt-4o-mini',
                    messages: [
                        {
                            role: 'system',
                            content: systemPrompt
                        },
                        {
                            role: 'user',
                            content: userPrompt
                        }
                    ],
                    temperature: 0.3,
                    max_tokens: 150
                })
            });
        } catch (fetchError) {
            console.error('Fetch error:', fetchError);
            return {
                statusCode: 502,
                headers,
                body: JSON.stringify({ error: 'Failed to connect to OpenAI API', details: fetchError.message })
            };
        }

        const responseText = await response.text();
        const duration = Date.now() - startTime;
        console.log(`OpenAI response received in ${duration}ms, status:`, response.status);

        if (!response.ok) {
            console.error('OpenAI API error:', response.status, responseText);
            return {
                statusCode: response.status,
                headers,
                body: JSON.stringify({ error: 'Failed to fetch from OpenAI API', details: responseText })
            };
        }

        let data;
        try {
            data = JSON.parse(responseText);
        } catch (parseError) {
            console.error('JSON parse error:', parseError);
            return {
                statusCode: 500,
                headers,
                body: JSON.stringify({ error: 'Invalid JSON from OpenAI API', details: responseText.substring(0, 200) })
            };
        }
        
        // Log full response structure for debugging
        console.log('Full response:', JSON.stringify(data, null, 2).substring(0, 1000));
        
        // Extract content from Chat Completions API format
        const choice = data.choices?.[0];
        const message = choice?.message;
        const content = message?.content || '';
        const finishReason = choice?.finish_reason;
        const refusal = message?.refusal;
        
        if (!content) {
            console.error('Empty content. finish_reason:', finishReason);
            console.error('Refusal:', refusal);
            console.error('Message:', JSON.stringify(message));
            console.error('Full response:', JSON.stringify(data));
        }
        
        // Handle refusal case
        if (refusal) {
            console.error('Model refused to generate content:', refusal);
        }
        
        const transformedData = {
            output_text: content
        };
        
        // Store in cache
        cache.set(cacheKey, {
            data: transformedData,
            timestamp: Date.now()
        });
        
        console.log('Transformed data:', JSON.stringify(transformedData).substring(0, 200));
        
        return {
            statusCode: 200,
            headers,
            body: JSON.stringify(transformedData)
        };

    } catch (error) {
        console.error('Function error:', error);
        return {
            statusCode: 500,
            headers,
            body: JSON.stringify({ error: 'Internal server error', details: error.message, stack: error.stack })
        };
    }
};
