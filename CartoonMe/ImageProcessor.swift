// ImageProcessor.swift
import Foundation
import UIKit

// Extension to resize UIImage to fit within a max pixel count (unchanged from your previous version)
extension UIImage {
    func resizedToFit(maxPixelCount: Int) -> UIImage? {
        let currentPixelCount = Int(size.width * size.height)
        if currentPixelCount <= maxPixelCount && currentPixelCount > 0 {
            return self
        }
        guard size.height > 0 else {
            print("Warning: Image height is zero.")
            return nil
        }
        let aspectRatio = size.width / size.height
        guard aspectRatio > 0 else {
            print("Warning: Image aspect ratio is zero or negative.")
            return nil
        }
        let newHeight = floor(sqrt(CGFloat(maxPixelCount) / aspectRatio))
        let newWidth = floor(newHeight * aspectRatio)
        let newSize = CGSize(width: newWidth, height: newHeight)
        guard newSize.width > 0 && newSize.height > 0 else {
            print("Warning: Calculated new size has zero width or height. Original: \(self.size), MaxPixels: \(maxPixelCount)")
            return UIGraphicsGetImageFromCurrentImageContext()
        }
        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        defer { UIGraphicsEndImageContext() }
        self.draw(in: CGRect(origin: .zero, size: newSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

class ImageProcessor {
    private let stabilityApiKey: String = {
        if let key = ProcessInfo.processInfo.environment["STABILITY_API_KEY"] {
            return key
        } else {
            print("Warning: STABILITY_API_KEY not set in environment. Using fallback (insecure) key. Please set this environment variable for security and proper functioning.")
            return "YOUR_FALLBACK_API_KEY" // Replace or handle error
        }
    }()
    
    private let endpoint = "https://api.stability.ai/v2beta/stable-image/control/structure"

    private struct CartoonThemeParameters {
        let controlStrength: Double
        let outputFormat: String
        let positivePromptEnhancers: String
        let negativePrompt: String
    }

    func cartoonify(image: UIImage,
                    theme: String,
                    customControlStrength: Double? = nil,
                    completion: @escaping (UIImage?) -> Void) {
        
        let maxPixelCount = 4 * 1024 * 1024

        guard let resizedImage = image.resizedToFit(maxPixelCount: maxPixelCount) else {
            print("Error: Failed to resize image or image is invalid.")
            completion(nil)
            return
        }
        
        guard let imageData = resizedImage.jpegData(compressionQuality: 0.9) else {
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
        
        var body = Data()
        
        let themeParams = getCartoonStyleDetails(for: theme)
        let finalControlStrength = customControlStrength ?? themeParams.controlStrength
        // MODIFIED: generateBasePrompt now includes age and specific feature preservation
        let basePrompt = generateBasePrompt()
        let fullPrompt = "\(basePrompt) \(themeParams.positivePromptEnhancers)"

        // 1. Prompt
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"prompt\"\r\n\r\n".data(using: .utf8)!)
        body.append(fullPrompt.data(using: .utf8)!)
        body.append("\r\n".data(using: .utf8)!)
        
        // 2. Image (Control Image)
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"control_image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        // 3. Control Strength
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"control_strength\"\r\n\r\n".data(using: .utf8)!)
        body.append(String(format: "%.2f", finalControlStrength).data(using: .utf8)!)
        body.append("\r\n".data(using: .utf8)!)
        
        // 4. Output Format
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"output_format\"\r\n\r\n".data(using: .utf8)!)
        body.append(themeParams.outputFormat.data(using: .utf8)!)
        body.append("\r\n".data(using: .utf8)!)
        
        // 5. Negative Prompt
        if !themeParams.negativePrompt.isEmpty {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"negative_prompt\"\r\n\r\n".data(using: .utf8)!)
            body.append(themeParams.negativePrompt.data(using: .utf8)!)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        print("🚀 Initiating Cartoonify Request to: \(url)")
        print("🎨 Theme: \(theme)")
        print("📜 Prompt: \(fullPrompt)") // This will now show the enhanced base prompt
        if !themeParams.negativePrompt.isEmpty {
            print("🚫 Negative Prompt: \(themeParams.negativePrompt)")
        }
        print("💪 Control Strength: \(String(format: "%.2f", finalControlStrength))")
        print("🖼️ Output Format: \(themeParams.outputFormat)")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ API Request Error: \(error.localizedDescription)")
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Error: Invalid HTTP response")
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            print("STATUS: \(httpResponse.statusCode)")
            if let allHeaders = httpResponse.allHeaderFields as? [String: String] {
                 print("HEADERS: \(allHeaders)")
            }

            guard let data = data else {
                print("❌ Error: No data in response")
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            if httpResponse.statusCode == 200 {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        if let imageBase64 = json["image"] as? String,
                           let imageDataDecoded = Data(base64Encoded: imageBase64),
                           let processedImage = UIImage(data: imageDataDecoded) {
                            print("✅ Image processed and decoded successfully.")
                            DispatchQueue.main.async { completion(processedImage) }
                        } else if let finishReason = json["finish_reason"] as? String, finishReason != "SUCCESS" {
                             print("⚠️ Generation not successful. Finish Reason: \(finishReason)")
                             if let errors = json["errors"] as? [String] {
                                 print("Error Details: \(errors.joined(separator: ", "))")
                             }
                             DispatchQueue.main.async { completion(nil) }
                        } else {
                            print("❌ Error: Could not parse image from JSON response or 'image' key missing.")
                            if let responseString = String(data: data, encoding: .utf8) { print("Raw JSON response: \(responseString)")}
                            DispatchQueue.main.async { completion(nil) }
                        }
                    } else {
                         print("❌ Error: Failed to deserialize JSON response (not a dictionary).")
                         if let responseString = String(data: data, encoding: .utf8) { print("Raw response: \(responseString)")}
                         DispatchQueue.main.async { completion(nil) }
                    }
                } catch {
                    print("❌ Error: JSON deserialization error: \(error.localizedDescription)")
                    if let responseString = String(data: data, encoding: .utf8) { print("Raw data causing error: \(responseString)")}
                    DispatchQueue.main.async { completion(nil) }
                }
            } else {
                print("❌ API Error: Status Code \(httpResponse.statusCode)")
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Error Response Body: \(responseString)")
                    do {
                        if let jsonError = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                            let errorName = jsonError["name"] as? String ?? "Unknown Error"
                            let errorMessage = (jsonError["errors"] as? [String])?.first ?? "No specific message."
                            print("Parsed API Error: [\(errorName)] \(errorMessage)")
                        }
                    } catch { /* Silent catch */ }
                }
                DispatchQueue.main.async { completion(nil) }
            }
        }
        task.resume()
    }

    /// Generates the base part of the prompt focused on likeness, age, and specific features.
    private func generateBasePrompt() -> String {
        return """
        High-quality, detailed cartoon transformation of the subject in the provided image. \
        Faithfully preserve the subject's distinct facial features, expression, and overall likeness, ensuring the cartoon is instantly recognizable as the same individual from the photo. \
        The generated image should depict the person as the same age as in the photo. \
        Retain any facial hair, such as beards or mustaches, exactly as they appear. \
        Maintain the original hairstyle and hair color accurately. \
        The style should be applied consistently across the entire image, including background if visible.
        """.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
    }
    
    // getCartoonStyleDetails remains unchanged from your previous version,
    // as its positivePromptEnhancers will be appended to the new, more detailed basePrompt.
    private func getCartoonStyleDetails(for theme: String) -> CartoonThemeParameters {
        let baseNegative = "photorealistic, 3D render, photography, hyperrealistic, deformed, disfigured, ugly, bad anatomy, extra limbs, missing limbs, fused fingers, too many fingers, mutated hands, poorly drawn hands, poorly drawn face, blurry, pixelated, grainy, low resolution, low quality, watermark, signature, text, words, jpeg artifacts, noise, tiling, out of frame, cropped, inaccurate age, different hairstyle, wrong hair color, missing facial hair, different facial hair." // Added some negatives related to the new instructions

        switch theme.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) {
        case "studio ghibli":
            return CartoonThemeParameters(
                controlStrength: 0.6,
                outputFormat: "png",
                positivePromptEnhancers: "Lush, painterly, and enchanting illustration in the style of Studio Ghibli. Whimsical, nostalgic atmosphere. Soft, warm lighting, often golden hour or gentle daylight. Beautifully detailed natural backgrounds or charming, slightly rustic architecture. Expressive, large eyes with a gentle quality. Watercolor textures, subtle cel-shading. Art by Hayao Miyazaki, Joe Hisaishi inspired mood.",
                negativePrompt: baseNegative + " harsh shadows, overly saturated colors, modern anime, digital art look, photo, dark, scary."
            )
            
        case "disney":
            return CartoonThemeParameters(
                controlStrength: 0.65,
                outputFormat: "jpeg",
                positivePromptEnhancers: "Classic Disney animation style. Polished, clean visuals. Expressive characters with large, emotive eyes and well-defined features. Smooth, clean outlines. Vibrant, warm, and appealing color palette. Dynamic poses if applicable. Think classic Disney renaissance or modern expressive 2D Disney style.",
                negativePrompt: baseNegative + " anime, manga, gritty, dark, horror, too realistic, flat colors, unexpressive."
            )
            
        case "anime style":
            return CartoonThemeParameters(
                controlStrength: 0.65,
                outputFormat: "jpeg",
                positivePromptEnhancers: "Vibrant and dynamic contemporary anime art style. Sharp, clean lines. Expressive characters with large, detailed, and often colorful eyes. Dynamic cell shading, bold color choices, and impactful lighting. Stylized hair. Could be shonen, shojo, or slice-of-life anime aesthetic. High detail, professional anime illustration.",
                negativePrompt: baseNegative + " western cartoon, Disney, 3D, photorealistic, chibi, super deformed, sketch, unfinished."
            )

        case "comic book":
            return CartoonThemeParameters(
                controlStrength: 0.7,
                outputFormat: "jpeg",
                positivePromptEnhancers: "Dynamic American comic book art style. Bold ink lines, dramatic shading (cross-hatching, cel shading). Vibrant or moody color palette depending on the genre (e.g. superhero, noir). Expressive characters, action poses. Ben Day dots if retro. Modern comic illustration.",
                negativePrompt: baseNegative + " anime, manga, disney, photorealistic, painterly, soft, muted."
            )
        case "realistic cartoon":
            return CartoonThemeParameters(
                controlStrength: 0.75,
                outputFormat: "png",
                positivePromptEnhancers: "Subtly stylized cartoon version of the photo. Clean lines, smooth shading, naturalistic but simplified features. Focus on retaining character and expression with a touch of artistic flair. Appealing, well-lit, high-quality illustration. Not overly exaggerated.",
                negativePrompt: baseNegative + " overtly cartoonish, chibi, anime, disney, flat, abstract, painterly, sketch."
            )
            
        default:
            print("Warning: Theme '\(theme)' not explicitly defined. Using default cartoon parameters.")
            return CartoonThemeParameters(
                controlStrength: 0.7,
                outputFormat: "jpeg",
                positivePromptEnhancers: "A beautiful, high-quality modern digital cartoon style. Clean lines, vibrant colors, appealing character design with expressive eyes. Smooth shading and highlights. Professional illustration quality.",
                negativePrompt: baseNegative + " sketch, messy, unfinished, too simplistic, abstract."
            )
        }
    }
}
