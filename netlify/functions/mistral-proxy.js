// Netlify Function to proxy Mistral AI API requests
// This keeps your API key secure on the server side

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

        // Get API key from environment variable (set in Netlify dashboard)
        const apiKey = process.env.MISTRAL_API_KEY;
        
        if (!apiKey) {
            return {
                statusCode: 500,
                headers,
                body: JSON.stringify({ error: 'API key not configured' })
            };
        }

        const response = await fetch('https://api.mistral.ai/v1/chat/completions', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${apiKey}`
            },
            body: JSON.stringify({
                model: 'mistral-large-latest',
                messages: [
                    {
                        role: 'system',
                        content: 'You are a helpful English vocabulary tutor. Provide clear, concise definitions and natural example sentences. Respond ONLY in JSON format.'
                    },
                    {
                        role: 'user',
                        content: `Provide a BRIEF academic definition (1 concise sentence, max 20 words) and ONE academic example sentence that USES BOTH "${word}" AND the linking word "${linkingWord || 'however'}" in the SAME sentence.

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

Format as JSON: {"definition": "...", "example": "..."}`
                    }
                ],
                temperature: 0.3,
                max_tokens: 200
            })
        });

        if (!response.ok) {
            const errorText = await response.text();
            console.error('Mistral API error:', errorText);
            return {
                statusCode: response.status,
                headers,
                body: JSON.stringify({ error: 'Failed to fetch from Mistral API' })
            };
        }

        const data = await response.json();
        
        return {
            statusCode: 200,
            headers,
            body: JSON.stringify(data)
        };

    } catch (error) {
        console.error('Function error:', error);
        return {
            statusCode: 500,
            headers,
            body: JSON.stringify({ error: 'Internal server error' })
        };
    }
};
