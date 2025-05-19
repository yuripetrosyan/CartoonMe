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
        Theme(name: "Studio Ghibli", color: .purple, image: "GhibliImage", logo: ""),
        Theme(name: "Classic Cartoon", color: .blue, image: "SimpsonsImage",logo: ""),
        Theme(name: "Anime Style", color: .pink, image: "AnimeImage", logo: ""),
        Theme(name: "Disney", color: .orange, image: "DisneyImage", logo: "DinseyLogo")
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // First Carousel: Main Themes
                        CarouselView(
                            title: "Most Used Styles",
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
                                selectedTheme: Theme(name: "Disney", color: .orange, image: "HouseImage", logo: "DisneyLogo")
                            )
                        ) {
                            BannerView(
                                item: BannerItem(
                                    title: "Disney",
                                    image: "HouseImage",
                                    isNew: true,
                                    action: {},
                                    logo: "DisneyLogo"
                                )
                            )
                        }
                        .padding(.vertical)
                        
                        // Additional Carousel: More Styles
                        CarouselView(
                            title: "New Styles",
                            items: themes.reversed().map { theme in
                                CarouselItem(
                                    title: theme.name,
                                    image: theme.image,
                                    destination: AnyView(ContentView(selectedTheme: theme))
                                )
                            },
                            showSeeAll: true
                        )
                    }.padding(.top, 30)
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
    let logo: String?
}

#Preview {
    ThemeSelectionView()
}
