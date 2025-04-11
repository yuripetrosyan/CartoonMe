//
//  ContentView.swift
//  CartoonMe
//
//  Created by Yuri Petrosyan on 10/04/2025.
//
// ThemeSelectionView.swift
import SwiftUI

struct ThemeSelectionView: View {
    let themes = [
        Theme(name: "Studio Ghibli", color: .purple, image: "GhibliImage"),
        Theme(name: "Classic Cartoon", color: .blue, image: "cartoon_sample"),
        Theme(name: "Anime Style", color: .pink, image: "anime_sample"),
        Theme(name: "Disney", color: .orange, image: "disney_sample")
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // First Carousel: Main Themes
                        CarouselView(
                            title: "Choose Your Style",
                            items: themes.map { theme in
                                CarouselItem(
                                    title: theme.name,
                                    image: theme.image,
                                    destination: AnyView(ContentView(selectedTheme: theme))
                                )
                            },
                            showSeeAll: true
                        )
                        
                        // Featured Banner
                        NavigationLink(
                            destination: ContentView(
                                selectedTheme: Theme(name: "Disney", color: .orange, image: "HouseImage")
                            )
                        ) {
                            BannerView(
                                item: BannerItem(
                                    title: "Disney",
                                    image: "HouseImage",
                                    isNew: true,
                                    action: {}
                                )
                            )
                        }
                        .padding(.vertical)
                        
                        // Additional Carousel: More Styles
                        CarouselView(
                            title: "More Styles",
                            items: themes.reversed().map { theme in
                                CarouselItem(
                                    title: theme.name,
                                    image: theme.image,
                                    destination: AnyView(ContentView(selectedTheme: theme))
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

struct Theme: Identifiable {
    let id = UUID()
    let name: String
    let color: Color
    let image: String
}

#Preview {
    ThemeSelectionView()
}
