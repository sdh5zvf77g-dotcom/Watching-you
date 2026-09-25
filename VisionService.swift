import Foundation
import UIKit

enum VisionError: LocalizedError {
    case noAPIKey
    case invalidImage
    case networkError(String)
    case apiError(String)
    
    var errorDescription: String? {
        switch self {
        case .noAPIKey:
            return "OpenAI API key is missing. Tap the key icon to add it."
        case .invalidImage:
            return "Could not process the image."
        case .networkError(let msg):
            return "Network error: \(msg)"
        case .apiError(let msg):
            return "API error: \(msg)"
        }
    }
}

class VisionService {
    
    func describeImage(_ image: UIImage, apiKey: String) async throws -> String {
        guard !apiKey.isEmpty else {
            throw VisionError.noAPIKey
        }
        
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            throw VisionError.invalidImage
        }
        
        let base64Image = imageData.base64EncodedString()
        
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "model": "gpt-4o",
            "messages": [
                [
                    "role": "system",
                    "content": "You are a calm, observant narrator. Describe what you see in the image in 1-3 clear, natural sentences, as if you are studying or reporting the scene. Be precise, neutral, and vivid. Do not start with \"I see\" or \"The image shows\"."
                ],
                [
                    "role": "user",
                    "content": [
                        ["type": "text", "text": "Describe this scene."],
                        [
                            "type": "image_url",
                            "image_url": [
                                "url": "data:image/jpeg;base64,\(base64Image)"
                            ]
                        ]
                    ]
                ]
            ],
            "max_tokens": 300
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw VisionError.networkError("Invalid response")
            }
            
            if httpResponse.statusCode != 200 {
                if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let error = errorJson["error"] as? [String: Any],
                   let message = error["message"] as? String {
                    throw VisionError.apiError(message)
                }
                throw VisionError.apiError("Status code \(httpResponse.statusCode)")
            }
            
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let choices = json["choices"] as? [[String: Any]],
                  let first = choices.first,
                  let message = first["message"] as? [String: Any],
                  let content = message["content"] as? String else {
                throw VisionError.apiError("Unexpected response format")
            }
            
            return content.trimmingCharacters(in: .whitespacesAndNewlines)
            
        } catch let error as VisionError {
            throw error
        } catch {
            throw VisionError.networkError(error.localizedDescription)
        }
    }
}
