//
//  CarouselView.swift
//  CartoonMe
//
//  Created by Yuri Petrosyan on 11/04/2025.
//
// CarouselView.swift
import SwiftUI

struct CarouselItem: Identifiable {
    let id = UUID()
    let title: String
    let image: String // Asset name or system image for now
    let destination: AnyView? // Optional destination for NavigationLink
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
                        if let destination = item.destination {
                            NavigationLink(destination: destination) {
                                ZStack {
                                    Image(item.image) // Use system image or asset
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 130, height: 190)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                        )
                                    VStack{
                                        
                                        Spacer()
                                        
                                        ZStack{
                                            
                                                    Rectangle()
                                                .fill(.ultraThinMaterial.opacity(0.9))

                                                              .frame(height:70)
                                                              .mask {

                                                                  LinearGradient(colors: [Color.gray, Color.red, Color.black, Color.black.opacity(0)], startPoint: .bottom, endPoint: .top)
            }
                                                      
                                        
                                    .frame(height: 70)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                              
                                            
                                            Text(item.title)
                                                .font(.caption)
                                                .fontDesign(.rounded)
                                                .foregroundColor(.white)
                                                .lineLimit(1)
                                                .padding(10)
                                                .padding(.top)
                                            
                                        }
                                        
                                    }
                                 
                                    .frame(width: 130, height: 190)
                                }
                                .frame(width: 130)
                            }
                        } else {
                            Button(action: {}) {
                                VStack {
                                    Image(item.image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 130, height: 170)
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
                                .frame(width: 130)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

#Preview {
    NavigationStack {
        CarouselView(
            title: "Image to Video Clip",
            items: [
                CarouselItem(title: "Studio Ghibli", image: "GhibliImage", destination: AnyView(Text("Yearbook"))),
                CarouselItem(title: "Simposons Suit", image: "SimpsonsImage", destination: AnyView(Text("SimsponsImage"))),
                CarouselItem(title: "Kitchen", image: "DisneyImage", destination: AnyView(Text("Kitchen")))
            ],
            showSeeAll: true
        )
        .background(Color.black)
    }
}
