import Foundation

class MistralService {
    static let shared = MistralService()
    
    private let apiURL = "https://api.mistral.ai/v1/chat/completions"
    private var apiKey: String {
        // In production, this should be stored in Keychain or fetched from your backend
        // For now, you need to add your API key here or use a secure method
        return UserDefaults.standard.string(forKey: "mistral_api_key") ?? ""
    }
    
    func fetchWordContent(for word: String) async throws -> WordContent {
        guard !apiKey.isEmpty else {
            throw MistralError.noAPIKey
        }
        
        let linkingWords = [
            "however", "therefore", "furthermore", "moreover", "nevertheless",
            "consequently", "in contrast", "similarly", "on the other hand",
            "as a result", "in addition", "whereas", "although", "despite",
            "thus", "hence", "accordingly", "subsequently", "indeed"
        ]
        
        let prompt = """
        You are an English vocabulary assistant for Turkish YDS (Foreign Language Exam) preparation.
        
        For the word "\(word)", provide:
        1. A brief academic definition (max 20 words)
        2. Two connected academic example sentences using appropriate linking words
        
        Use these linking words naturally: \(linkingWords.joined(separator: ", "))
        
        Return ONLY a JSON object in this exact format:
        {
          "definition": "brief academic definition",
          "example1": "First sentence with a linking word.",
          "example2": "Second connected sentence with a linking word."
        }
        
        The examples should be academic/formal and demonstrate sophisticated usage suitable for YDS exam preparation.
        """
        
        let requestBody: [String: Any] = [
            "model": "mistral-large-latest",
            "messages": [
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.7,
            "max_tokens": 300
        ]
        
        guard let url = URL(string: apiURL) else {
            throw MistralError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw MistralError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw MistralError.apiError("HTTP \(httpResponse.statusCode)")
        }
        
        let apiResponse = try JSONDecoder().decode(MistralAPIResponse.self, from: data)
        
        guard let content = apiResponse.choices.first?.message.content else {
            throw MistralError.noContent
        }
        
        // Extract JSON from content (it might be wrapped in markdown code blocks)
        let jsonString = extractJSON(from: content)
        
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw MistralError.decodingError
        }
        
        return try JSONDecoder().decode(WordContent.self, from: jsonData)
    }
    
    private func extractJSON(from string: String) -> String {
        // Remove markdown code blocks if present
        var cleaned = string
        if cleaned.hasPrefix("```json") {
            cleaned = String(cleaned.dropFirst(7))
        } else if cleaned.hasPrefix("```") {
            cleaned = String(cleaned.dropFirst(3))
        }
        if cleaned.hasSuffix("```") {
            cleaned = String(cleaned.dropLast(3))
        }
        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

enum MistralError: Error, LocalizedError {
    case noAPIKey
    case invalidURL
    case invalidResponse
    case apiError(String)
    case noContent
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .noAPIKey:
            return "API key not configured. Please add your Mistral API key in Settings."
        case .invalidURL:
            return "Invalid API URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .apiError(let message):
            return "API Error: \(message)"
        case .noContent:
            return "No content received from API"
        case .decodingError:
            return "Failed to parse response"
        }
    }
}

struct MistralAPIResponse: Codable {
    let choices: [Choice]
}

struct Choice: Codable {
    let message: Message
}

struct Message: Codable {
    let content: String
}
