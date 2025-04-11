//
//  BannerView.swift
//  CartoonMe
//
//  Created by Yuri Petrosyan on 11/04/2025.
//

import SwiftUI

struct BannerItem: Identifiable {
    var id: UUID = UUID()
    var title: String
    var image: String
    var isNew: Bool
    let action: () -> Void
}


struct BannerView: View {
    
    let item: BannerItem
    
    var body: some View {
        Button(action: item.action) {
                    ZStack(alignment: .leading) {
                        // Background Image
                        Image(item.image)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 230)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        VStack{
                            Spacer()
                            
                            // Overlay Content
                            HStack {
                                // Title
                                Text(item.title.uppercased())
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .shadow(radius: 2)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 20)
//                                    .background(
//                                        Color.black.opacity(0.5)
//                                            .clipShape(RoundedRectangle(cornerRadius: 10))
//                                    )
                                
                                Spacer()
                                
                                // Try Now Button
                                Text("Try Now")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 20)
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.purple, Color.blue]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                    )
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 10)
                            
                            .background(
                                VStack {
                                    Spacer()
                                        Rectangle()
                                            .fill(.ultraThinMaterial)

                                                  .frame(height: 130)
                                                  .mask {

                                                      LinearGradient(colors: [Color.black, Color.black, Color.black, Color.black.opacity(0)], startPoint: .bottom, endPoint: .top)
}
                                          }
                            )
                        }.frame(height: 232)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                        // NEW Badge
                        if item.isNew {
                            Text("NEW")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.vertical, 5)
                                .padding(.horizontal, 10)
                                .background(Color.purple)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .position(x: 40, y: 20) // Top-left corner
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }

#Preview {
    BannerView(item: BannerItem(title: "Disney", image: "HouseImage", isNew: true, action: {}))
}
