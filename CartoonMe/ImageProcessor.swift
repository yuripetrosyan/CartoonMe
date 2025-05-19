// ImageProcessor.swift
import UIKit

class ImageProcessor {
    private let replicateAPIKey = "hahaha"
    
    
    private let modelVersion = "hahaha"
    
    func cartoonify(image: UIImage, theme: String, completion: @escaping (UIImage?) -> Void) {
        // Step 1: Convert the image to JPEG data
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Error: Failed to convert image to JPEG data")
            completion(nil)
            return
        }
        
        // Step 2: Submit the prediction
        let url = URL(string: "https://api.replicate.com/v1/predictions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(replicateAPIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Prepare the input: image and prompt for the style
        let json: [String: Any] = [
            "version": modelVersion,
            "input": [
                "image": "data:image/jpeg;base64,\(imageData.base64EncodedString())",
                "prompt": getPrompt(for: theme)
            ]
        ]
        
        guard let requestBody = try? JSONSerialization.data(withJSONObject: json) else {
            print("Error: Failed to serialize JSON request body")
            completion(nil)
            return
        }
        request.httpBody = requestBody
        
        print("Submitting prediction to Replicate with model: \(modelVersion), theme: \(theme)")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
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
            
            guard let data = data,
                  let jsonResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                print("Error: Invalid response data: \(String(data: data ?? Data(), encoding: .utf8) ?? "No data")")
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            print("API Response: \(jsonResponse)")
            
            guard let predictionID = jsonResponse["id"] as? String else {
                print("Error: No prediction ID in response")
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            // Step 3: Poll for the result
            self.pollForResult(predictionID: predictionID, completion: completion)
        }.resume()
    }
    
    private func pollForResult(predictionID: String, completion: @escaping (UIImage?) -> Void) {
        let url = URL(string: "https://api.replicate.com/v1/predictions/\(predictionID)")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(replicateAPIKey)", forHTTPHeaderField: "Authorization")
        
        print("Polling for prediction result: \(predictionID)")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Polling Error: \(error.localizedDescription)")
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Error: Invalid HTTP response during polling")
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            print("Polling Response Status Code: \(httpResponse.statusCode)")
            
            guard let data = data,
                  let jsonResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                print("Error: Invalid polling response data: \(String(data: data ?? Data(), encoding: .utf8) ?? "No data")")
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            print("Polling Response: \(jsonResponse)")
            
            guard let status = jsonResponse["status"] as? String else {
                print("Error: No status in polling response")
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            if status == "succeeded" {
                // Handle output as an array of strings
                if let outputArray = jsonResponse["output"] as? [String], !outputArray.isEmpty {
                    let outputURL = outputArray[0] // Take the first URL
                    print("Output URL: \(outputURL)")
                    if let outputData = try? Data(contentsOf: URL(string: outputURL)!) {
                        if let processedImage = UIImage(data: outputData) {
                            print("Successfully processed image")
                            DispatchQueue.main.async { completion(processedImage) }
                        } else {
                            print("Error: Failed to convert output data to UIImage")
                            DispatchQueue.main.async { completion(nil) }
                        }
                    } else {
                        print("Error: Failed to download image from output URL")
                        DispatchQueue.main.async { completion(nil) }
                    }
                } else {
                    print("Error: No output URL in response or output is not an array")
                    DispatchQueue.main.async { completion(nil) }
                }
            } else if status == "failed" {
                print("Error: Prediction failed - \(jsonResponse["error"] ?? "No error message")")
                DispatchQueue.main.async { completion(nil) }
            } else {
                // Keep polling every 1 second
                print("Prediction status: \(status), continuing to poll...")
                DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                    self.pollForResult(predictionID: predictionID, completion: completion)
                }
            }
        }.resume()
    }
    
    private func getPrompt(for theme: String) -> String {
        switch theme {
        case "Studio Ghibli":
            return "Transform this image into a Studio Ghibli cartoon style, with soft pastel colors, detailed backgrounds, and a whimsical, hand-drawn look"
        case "Classic Cartoon":
            return "Transform this image into a Classic Cartoon style, with bold black outlines, flat vibrant colors, and a retro 2D look"
        case "Anime Style":
            return "Transform this image into an Anime Style, with sharp lines, vibrant colors, large expressive eyes, and dynamic shading"
        case "Disney":
            return "Transform this image into a Disney cartoon style, with smooth 2D animation, warm colors, and a magical, polished look"
        default:
            return "Transform this image into a \(theme) cartoon style, with vibrant colors and smooth shading"
        }
    }
    
    
    
}
