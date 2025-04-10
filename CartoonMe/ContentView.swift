//
//  ContentView.swift
//  CartoonMe
//
//  Created by Yuri Petrosyan on 10/04/2025.
//

import Foundation
// ContentView.swift
import SwiftUI

struct ContentView: View {
    let selectedTheme: Theme
    @State private var selectedImage: UIImage?
    @State private var processedImage: UIImage?
    @State private var showingImagePicker = false
    private let imageProcessor = ImageProcessor()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("CartoonMe - \(selectedTheme.name)")
                .font(.largeTitle)
                .foregroundColor(selectedTheme.color)
            
            // Original Image Preview
            if let selectedImage = selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
                    .cornerRadius(10)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 300)
                    .cornerRadius(10)
                    .overlay(Text("Pick a photo!"))
            }
            
            // Buttons
            HStack{
                Button("Choose Photo") {
                    showingImagePicker = true
                }
                .buttonStyle(.borderedProminent)
                .tint(selectedTheme.color)
                
                Button("Cartoon It!") {
                    processImage()
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .disabled(selectedImage == nil)
                
            }
            // Processed Image Preview
            if let processedImage = processedImage {
                Image(uiImage: processedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
                    .cornerRadius(10)
            }
        }
        .padding()
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $selectedImage)
        }
    }
    
    private func processImage() {
        if let image = selectedImage {
            processedImage = imageProcessor.cartoonify(image: image, theme: selectedTheme.name)
        }
    }
}

#Preview {
    ContentView(selectedTheme: Theme(name: "Studio Ghibli", color: .purple, image: "ghibli_sample"))
}
