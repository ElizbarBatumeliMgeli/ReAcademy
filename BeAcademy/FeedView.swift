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
                    
                    // 2. Our main scrollable feed
                    ScrollView {
                        // 3. We loop over the 'posts' array from our manager.
                        LazyVStack(spacing: 0) {
                            if firebaseManager.posts.isEmpty {
                                // Show a message if there are no posts
                                Text("No posts yet.\nTap the '+' to be the first!")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .padding(.top, 100)
                            } else {
                                // Create a PostView for each post
                                ForEach(firebaseManager.posts) { post in
                                    PostView(post: post)
                                }
                            }
                        }
                        // --- UPDATED: Add padding to the bottom ---
                        // This ensures the last post can scroll
                        // fully above the new floating button.
                        .padding(.bottom, 90)
                        // --- END UPDATE ---
                    }
                }
                .background(Color.black)
                .ignoresSafeArea(edges: .bottom)
                
                // --- NEW: Floating Action Button ---
                Button {
                    showingCreatePostView = true
                } label: {
                    Image(systemName: "plus")
                        .font(.title.weight(.semibold))
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                        .shadow(radius: 10, y: 5) // Add a shadow to make it "float"
                }
                .padding(.bottom, 20) // Adjust vertical position from the bottom
                // --- END NEW ---
                
            }
            // --- END ZSTACK UPDATE ---
        }
        // 4. This is the sheet that will present the CreatePostView
        .sheet(isPresented: $showingCreatePostView) {
            // --- UPDATED ---
            // We pass the manager from this view into the
            // sheet's environment so it can be shared.
            CreatePostView()
                .environmentObject(firebaseManager)
            // --- END UPDATE ---
        }
        // 5. Force the dark mode style for the whole view
        .preferredColorScheme(.dark)
    }
}

#Preview {
    FeedView()
}
