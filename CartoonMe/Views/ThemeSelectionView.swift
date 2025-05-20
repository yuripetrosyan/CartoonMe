//
//  ContentView.swift
//  CartoonMe
//
//  Created by Yuri Petrosyan on 10/04/2025.
//
// ThemeSelectionView.swift
import SwiftUI

struct ThemeSelectionView: View {
    @State private var showAllThemes = false
    let themes = [
        Theme(name: "Studio Ghibli", color: .purple, image: "GhibliImage", logo: ""),
        Theme(name: "Classic Cartoon", color: .blue, image: "SimpsonsImage",logo: ""),
        Theme(name: "Anime Style", color: .pink, image: "AnimeImage", logo: ""),
        Theme(name: "Disney", color: .orange, image: "DisneyImage", logo: "DinseyLogo"),
        Theme(name: "Pixar Style", color: .yellow, image: "PixarImage", logo: nil),
        Theme(name: "Marvel Comic", color: .red, image: "MarvelImage", logo: nil),
        Theme(name: "Pop Art", color: .green, image: "PopArtImage", logo: nil),
        Theme(name: "Chibi", color: .mint, image: "ChibiImage", logo: nil),
        Theme(name: "Noir Comic", color: .gray, image: "NoirImage", logo: nil),
        Theme(name: "Watercolor Illustration", color: .cyan, image: "WatercolorImage", logo: nil),
        Theme(name: "Retro 80s Cartoon", color: .teal, image: "Retro80sImage", logo: nil),
        Theme(name: "Minimalist Flat", color: .indigo, image: "MinimalistImage", logo: nil),
        Theme(name: "Manga", color: .black, image: "MangaImage", logo: nil),
        Theme(name: "Caricature", color: .brown, image: "CaricatureImage", logo: nil)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Hidden NavigationLink for programmatic navigation
                        NavigationLink(destination: AllThemesView(themes: themes), isActive: $showAllThemes) { EmptyView() }
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
                            showSeeAll: true,
                            seeAllAction: { showAllThemes = true }
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
                            showSeeAll: true,
                            seeAllAction: { showAllThemes = true }
                        )
                    }.padding(.top, 30)
                        .padding(.bottom, 100)
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

struct AllThemesView: View {
    let themes: [Theme]
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(themes) { theme in
                        NavigationLink(destination: ContentView(selectedTheme: theme)) {
                            VStack {
                                Image(theme.image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 120)
                                    .background(theme.color.opacity(0.2))
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                Text(theme.name)
                                    .foregroundColor(.primary)
                                    .font(.headline)
                                    .multilineTextAlignment(.center)
                            }
                            .padding()
                            .background(Color(.systemBackground).opacity(0.8))
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("All Themes")
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
