//
//  ContentView.swift
//  CartoonMe
//
//  Created by Yuri Petrosyan on 10/04/2025.
//

// ContentView.swift
import SwiftUI

struct ContentView: View {
    let selectedTheme: Theme
    @State private var selectedImage: UIImage?
    @State private var processedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var isProcessing = false
    private let imageProcessor = ImageProcessor()
    
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("CartoonMe - \(selectedTheme.name)")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                
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
                        .overlay(Text("Pick a photo!").foregroundColor(.white))
                }
                
                // Buttons
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
                .disabled(selectedImage == nil || isProcessing)
                
                // Loading Spinner
                if isProcessing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .tint(.white)
                        .scaleEffect(1.5)
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
        }.alert(isPresented: $showError) {
            Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    private func processImage() {
        guard let image = selectedImage else { return }
        isProcessing = true
        // In processImage, update the completion:
        imageProcessor.cartoonify(image: image, theme: selectedTheme.name) { result in
            DispatchQueue.main.async {
                if let result = result {
                    self.processedImage = result
                } else {
                    self.errorMessage = "Failed to process the image. Please try again."
                    self.showError = true
                }
                self.isProcessing = false
            }
        }
    }
    
}
#Preview {
    ContentView(selectedTheme: Theme(name: "Studio Ghibli", color: .purple, image: "ghibli_sample", logo: ""))
}
