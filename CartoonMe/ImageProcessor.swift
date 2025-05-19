// ImageProcessor.swift
import Foundation
import UIKit

class ImageProcessor {
    // Load API key from environment variable for security
    private let stabilityApiKey: String = {
        if let key = ProcessInfo.processInfo.environment["STABILITY_API_KEY"] {
            return key
        } else {
            print("Warning: STABILITY_API_KEY not set in environment. Using fallback (insecure) key.")
            return "YOUR_FALLBACK_API_KEY" // Replace with a safe fallback or handle error
        }
    }()
    
    // Use the control/structure endpoint for better face/structure preservation
    private let endpoint = "https://api.stability.ai/v2beta/stable-image/control/structure"
    
    /// Processes an image using Stable Image Control Structure API
    /// - Parameters:
    ///   - image: The UIImage to process
    ///   - theme: The cartoon style/theme
    ///   - controlStrength: The control image strength (0.5-0.8 recommended)
    ///   - completion: Completion handler with the processed UIImage or nil
    func cartoonify(image: UIImage, theme: String, controlStrength: Double = 0.7, completion: @escaping (UIImage?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Error: Failed to convert image to JPEG data")
            completion(nil)
            return
        }
        
        guard let url = URL(string: endpoint) else {
            print("Error: Invalid endpoint URL")
            completion(nil)
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(stabilityApiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Prepare multipart form data
        var body = Data()
        // Prompt
        let prompt = getCartoonPrompt(for: theme)
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"prompt\"\r\n\r\n".data(using: .utf8)!)
        body.append(prompt.data(using: .utf8)!)
        body.append("\r\n".data(using: .utf8)!)
        // Control image
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"control.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        // Control strength
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"control_strength\"\r\n\r\n".data(using: .utf8)!)
        body.append(String(controlStrength).data(using: .utf8)!)
        body.append("\r\n".data(using: .utf8)!)
        // Output format
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"output_format\"\r\n\r\n".data(using: .utf8)!)
        body.append("jpeg".data(using: .utf8)!)
        body.append("\r\n".data(using: .utf8)!)
        // Negative prompt (optional, but recommended)
        let negativePrompt = "photographic, photo, worst quality, bad eyes, bad anatomy, comics, cropped, cross-eyed, ugly, deformed, glitch, mutated, watermark, worst quality, unprofessional, jpeg artifacts, low quality"
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"negative_prompt\"\r\n\r\n".data(using: .utf8)!)
        body.append(negativePrompt.data(using: .utf8)!)
        body.append("\r\n".data(using: .utf8)!)
        // End boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        // Send request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("API Request Error: \(error.localizedDescription)")
                DispatchQueue.main.async { completion(nil) }
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Error: Invalid HTTP response")
                DispatchQueue.main.async { completion(nil) }
                return
            }
            print("API Response Status Code: \(httpResponse.statusCode)")
            guard let data = data else {
                print("Error: No data in response")
                DispatchQueue.main.async { completion(nil) }
                return
            }
            // Parse response
            if httpResponse.statusCode == 200 {
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let imageBase64 = json["image"] as? String,
                   let imageData = Data(base64Encoded: imageBase64),
                   let processedImage = UIImage(data: imageData) {
                    DispatchQueue.main.async { completion(processedImage) }
                } else {
                    print("Error: Could not parse image from response")
                    DispatchQueue.main.async { completion(nil) }
                }
            } else {
                print("Response body: \(String(data: data, encoding: .utf8) ?? "N/A")")
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let errorMsg = json["error"] as? String {
                    print("API Error: \(errorMsg)")
                } else {
                    print("Unknown API error")
                }
                DispatchQueue.main.async { completion(nil) }
            }
        }
        task.resume()
    }

    // Explicit prompt for face preservation and style
    private func getCartoonPrompt(for theme: String) -> String {
        let baseInstruction = "Cartoon portrait of the person in the provided image, preserving their unique facial features and likeness. Style: "
        switch theme {
        case "Studio Ghibli":
            return baseInstruction + "Studio Ghibli inspired, beautiful expressive eyes, detailed, soft pastel colors, whimsical, hand-drawn aesthetic."
        case "Classic Cartoon":
            return baseInstruction + "Classic 2D cartoon style (e.g., Looney Tunes, early Hanna-Barbera), bold outlines, vibrant flat colors, expressive, retro aesthetic."
        case "Anime Style":
            return baseInstruction + "Anime style, large expressive eyes, sharp lines, vibrant colors, dynamic shading, capturing the person's characteristics."
        case "Disney":
            return baseInstruction + "Disney animation style, capturing the person's features, polished look, warm colors, expressive."
        default:
            return baseInstruction + "\(theme) style, beautiful big cartoon eyes, highly detailed, vibrant colors, smooth shading, based on the provided image's subject."
        }
    }
}
