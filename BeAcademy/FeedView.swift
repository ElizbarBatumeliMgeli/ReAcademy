//
//  FeedView.swift
//  BeAcademy
//
//  Created by Elizbar Kheladze on 11/11/25.
//

import SwiftUI

struct FeedView: View {
    @StateObject private var firebaseManager = FirebaseManager()
    @State private var showingCreatePostView = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                VStack(spacing: 0) {
                    HStack {
                        Text("BeAcademy")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .background(Color.black)
                    
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            if firebaseManager.posts.isEmpty {
                                Text("No posts yet.\nTap the '+' to be the first!")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .padding(.top, 100)
                            } else {
                                ForEach(firebaseManager.posts) { post in
                                    PostView(post: post)
                                }
                            }
                        }
                        .padding(.bottom, 90)
                    }
                }
                .background(Color.black)
                .ignoresSafeArea(edges: .bottom)
                
                Button {
                    showingCreatePostView = true
                } label: {
                    Image(systemName: "plus")
                        .font(.title.weight(.semibold))
                        .foregroundColor(.black)
                        .padding()
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(radius: 10, y: 5)
                }
                .padding(.bottom, 20)
            }
        }
        .sheet(isPresented: $showingCreatePostView) {
            CreatePostView()
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    FeedView()
}
