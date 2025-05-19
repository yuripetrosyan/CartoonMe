//
//  ContentView.swift
//  CartoonMe
//
//  Created by Yuri Petrosyan on 10/04/2025.
//

// ContentView.swift
import SwiftUI
import PhotosUI
// If needed, add @testable import CartoonMe for test targets


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
            Color.black.ignoresSafeArea()
            ScrollView{
            VStack(spacing: 28) {
                // Title
                HStack(spacing: 12) {
                    if let logo = selectedTheme.logo, !logo.isEmpty {
                        Image(logo)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 36, height: 36)
                    }
                    Text(selectedTheme.name)
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                }
                .padding(.top, 16)
                // Image Preview Card
                ZStack {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .frame(height: 260)
                        .shadow(color: .black.opacity(0.18), radius: 16, x: 0, y: 8)
                    if let selectedImage = selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 220)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    } else {
                        VStack(spacing: 8) {
                            Image(systemName: "photo")
                                .font(.system(size: 44, weight: .light))
                                .foregroundColor(.white.opacity(0.7))
                            Text("Pick a photo")
                                .foregroundColor(.white.opacity(0.7))
                                .font(.headline)
                        }
                    }
                }
                .padding(.horizontal, 24)
                // Action Buttons Card
                ZStack {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.10), radius: 10, x: 0, y: 4)
                    HStack(spacing: 18) {
                        Button(action: { showingImagePicker = true }) {
                            HStack {
                                Image(systemName: "plus.circle")
                                Text("Choose Photo")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 18)
                            .background(
                                Capsule().fill(selectedTheme.color.opacity(0.7))
                            )
                        }
                        Button(action: { processImage() }) {
                            HStack {
                                Image(systemName: "wand.and.stars")
                                Text("Cartoon It!")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 18)
                            .background(
                                Capsule().fill(Color.green.opacity(selectedImage == nil || isProcessing ? 0.3 : 0.7))
                            )
                        }
                        .disabled(selectedImage == nil || isProcessing)
                    }
                    .padding(.vertical, 8)
                }
                .padding(.horizontal, 24)
                // Loading Spinner
                if isProcessing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .tint(.white)
                        .scaleEffect(1.5)
                }
                // Processed Image Preview
                if let processedImage = processedImage {
                    ZStack {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .frame(height: 220)
                            .shadow(color: .black.opacity(0.18), radius: 16, x: 0, y: 8)
                        Image(uiImage: processedImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 180)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .padding(.horizontal, 24)
                }
                Spacer()
            }
        }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $selectedImage)
            }
        }
        .alert(isPresented: $showError) {
            Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    private func processImage() {
        guard let image = selectedImage else { return }
        isProcessing = true
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
