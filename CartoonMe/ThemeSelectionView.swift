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
    
    // Define the grid columns: 2 columns, flexible width
    let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(themes) { theme in
                        NavigationLink(destination: ContentView(selectedTheme: theme)) {
                            ThemeCard(theme: theme)
                        }
                    }
                }
                .padding()
                // Move the title outside the grid for better spacing
                .navigationTitle("CartoonME")
            }
            .background(Color(.systemGray6))
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

// Theme card view
struct ThemeCard: View {
    let theme: Theme
    
    var body: some View {
        VStack {
            Spacer()
            // Placeholder image (replace with real assets later)
            Image(systemName: "photo") // Swap with theme.image when you add assets
                .resizable()
                .scaledToFit()
                .frame(height: 50)
                .cornerRadius(10)
            
            VStack {
                Spacer()
                Text(theme.name)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.regularMaterial.shadow(.inner(radius: 1)))
                    .cornerRadius(20)
            }.padding(10)
        }
        // Uncomment to enforce a fixed size if needed
         .frame(width: 180, height: 220)
        .background(theme.color)
       // .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 5, y: 5)
        .padding(.vertical, 10)
    }
}

#Preview {
    ThemeSelectionView()
}
