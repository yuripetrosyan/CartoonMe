//
//  CarouselView.swift
//  CartoonMe
//
//  Created by Yuri Petrosyan on 11/04/2025.
//

import SwiftUI

struct CarouselItem: Identifiable {
    let id = UUID()
    let title: String
    let image: String // Asset name or system image for now
    let action: () -> Void // Action when tapped
}

struct CarouselView: View {
    let title: String
    let items: [CarouselItem]
    let showSeeAll: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                if showSeeAll {
                    Button(action: {
                        // Add "See All" action if needed
                    }) {
                        Text("See All")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(items) { item in
                        Button(action: item.action) {
                            VStack {
                                Image(item.image) // Use system image or asset
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 120)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                                
                                Text(item.title)
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                            }
                            .frame(width: 120)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

#Preview {
    CarouselView(
        title: "Image to Video Clip",
        items: [
            CarouselItem(title: "Yearbook", image: "photo", action: {}),
            CarouselItem(title: "Business Suit", image: "photo", action: {}),
            CarouselItem(title: "Kitchen", image: "photo", action: {})
        ],
        showSeeAll: true
    )
    .background(Color.black)
}
