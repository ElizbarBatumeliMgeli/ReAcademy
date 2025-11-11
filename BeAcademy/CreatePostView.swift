//
//  CreatePostView.swift
//  BeAcademy
//
//  Created by Elizbar Kheladze on 11/11/25.
//
import SwiftUI

struct CreatePostView: View {
    
    @StateObject private var firebaseManager = FirebaseManager()
    
    @Environment(\.dismiss) var dismiss
    
    @State private var description: String = ""
    
    @State private var imageBack: UIImage?
    @State private var imageFront: UIImage?

    @State private var showingPickerBack = false
    @State private var showingPickerFront = false
    
    @State private var isUploading = false
    
    var body: some View {
        NavigationStack {
            
            Form {
                
                Section(header: Text("Photo Preview")) {
                    Button {
                        showingPickerBack = true
                    } label: {
                        ZStack(alignment: .topLeading) {
                            
                            if let image = imageBack {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(maxWidth: .infinity, minHeight: 300, maxHeight: 300)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(12)
                            } else {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(maxWidth: .infinity, minHeight: 300, maxHeight: 300)
                                    
                                    VStack(spacing: 10) {
                                        Image(systemName: "camera.fill")
                                            .font(.largeTitle)
                                        Text("Tap to take photo")
                                            .font(.headline)
                                    }
                                    .foregroundColor(.gray)
                                }
                            }
                            
                            if let image = imageFront {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 100, height: 133)
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.white, lineWidth: 3)
                                    )
                                    .padding()
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
                .listRowInsets(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                
                Section(header: Text("Description")) {
                    TextField("Write a description...", text: $description, axis: .vertical)
                        .lineLimit(3...5)
                        .padding(.vertical, 5)
                }
                
                Section {
                    Button {
                        uploadPost()
                    } label: {
                        if isUploading {
                            ProgressView()
                                .frame(maxWidth: .infinity, alignment: .center)
                        } else {
                            Text("Post")
                                .font(.headline)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                    .foregroundColor(isUploading ? .gray : .white)
                    .padding(.vertical, 5)
                    .background(isUploading ? Color.gray : Color.blue)
                    .cornerRadius(12)
                    .disabled(imageBack == nil || imageFront == nil || description.isEmpty || isUploading)
                    // --- END UPDATE ---
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
            }

            .navigationTitle("Create New Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingPickerBack, onDismiss: {
            if imageBack != nil && imageFront == nil {
                showingPickerFront = true
            }
        }) {
            ImagePicker(selectedImage: $imageBack, sourceType: .camera, cameraDevice: .rear)
        }
        .sheet(isPresented: $showingPickerFront) {
            ImagePicker(selectedImage: $imageFront, sourceType: .camera, cameraDevice: .front)
        }
    }
    
    private func uploadPost() {
        guard let imageBack = imageBack, let imageFront = imageFront else { return }
        isUploading = true
        firebaseManager.createPost(description: description, imageBack: imageBack, imageFront: imageFront) { success in
            isUploading = false
            if success {
                dismiss()
            } else {
                print("Error: Could not create post.")
            }
        }
    }
}

#Preview {
    CreatePostView()
        .preferredColorScheme(.dark)
}
