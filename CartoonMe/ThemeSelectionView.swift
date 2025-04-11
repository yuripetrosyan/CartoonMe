//
//  ContentView.swift
//  CartoonMe
//
//  Created by Yuri Petrosyan on 10/04/2025.
//
// ThemeSelectionView.swift
import SwiftUI

struct ThemeSelectionView: View {
    // Sample themes (you can expand this)
    let themes = [
        Theme(name: "Studio Ghibli", color: .purple, image: "ghibli_sample"),
        Theme(name: "Classic Cartoon", color: .blue, image: "cartoon_sample"),
        Theme(name: "Anime Style", color: .pink, image: "anime_sample"),
        Theme(name: "Studio Ghibli", color: .purple, image: "ghibli_sample"),
        Theme(name: "Classic Cartoon", color: .blue, image: "cartoon_sample"),
        Theme(name: "Anime Style", color: .pink, image: "anime_sample")
    ]
    
    var body: some View {
            NavigationStack {
                ZStack {
                    Color.black.edgesIgnoringSafeArea(.all) // Dark background
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            // First Carousel: Main Themes
                            CarouselView(
                                title: "Choose Your Style",
                                items: themes.map { theme in
                                    CarouselItem(
                                        title: theme.name,
                                        image: theme.image, // Swap with system image if no assets
                                        action: {
                                            // Navigate to ContentView with selected theme
                                        }
                                    )
                                },
                                showSeeAll: true
                            )
                            
                            // Featured Banner (like Disney in Collart)
                            CarouselView(
                                title: "Featured",
                                items: [
                                    CarouselItem(
                                        title: "Disney",
                                        image: "disney_sample",
                                        action: {}
                                    )
                                ],
                                showSeeAll: false
                            )
                            .padding(.vertical)
                            
                            // Additional Carousel (e.g., more styles)
                            CarouselView(
                                title: "More Styles",
                                items: themes.reversed().map { theme in
                                    CarouselItem(
                                        title: theme.name,
                                        image: theme.image,
                                        action: {}
                                    )
                                },
                                showSeeAll: true
                            )
                        }
                    }
                }
                .navigationTitle("CartoonMe")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack {
                            Button(action: {}) {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.white)
                            }
                            Button(action: {}) {
                                Image(systemName: "person.circle")
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
            }
        }
    }

// Theme model
struct Theme: Identifiable {
    let id = UUID()
    let name: String
    let color: Color
    let image: String // Placeholder for sample image
}



#Preview {
    ThemeSelectionView()
}
