//
//  PostView.swift
//  BeAcademy
//
//  Created by Elizbar Kheladze on 11/11/25.
//

import SwiftUI

struct PostView: View {
    let post: Post
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .topLeading) {
                AsyncImage(url: URL(string: post.imageUrlBack)) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .overlay(ProgressView().tint(.white))
                    case .success(let image):
                        image
                            .resizable()
                    case .failure:
                        Rectangle()
                            .fill(Color.red.opacity(0.3))
                            .overlay(Image(systemName: "exclamationmark.triangle").foregroundColor(.white))
                    @unknown default:
                        EmptyView()
                    }
                }
                .aspectRatio(3/4, contentMode: .fill)
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(12)
                
                if let frontUrlString = post.imageUrlFront, let frontUrl = URL(string: frontUrlString) {
                    AsyncImage(url: frontUrl) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable()
                        case .empty, .failure, _:
                            Rectangle().fill(Color.gray.opacity(0.4))
                        }
                    }
                    .aspectRatio(3/4, contentMode: .fill)
                    .frame(width: 100, height: 133)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.black, lineWidth: 2)
                    )
                    .padding(12)
                }
            }
            
            HStack(alignment: .top) {
                Text(post.description)
                    .font(.headline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text(post.formattedTimestamp)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.gray)
                    .padding(.top, 2)
            }
            .padding(.horizontal, 4)
        }
        .padding()
        .background(Color.black)
        .cornerRadius(20)
        .padding(.horizontal)
        .padding(.vertical, 8)
        .foregroundColor(.white)
    }
}
