//
//  FirebaseManager.swift
//  BeAcademy
//
//  Created by Elizbar Kheladze on 11/11/25.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage // Make sure to import this
import UIKit // We need this for UIImage
import Combine // For ObservableObject

// This class will handle all our interactions with Firebase.
// By making it an ObservableObject, our views can watch it for updates.
class FirebaseManager: ObservableObject {
    
    // @Published means that any view watching this manager will
    // automatically update when the 'posts' array changes.
    @Published var posts: [Post] = []
    
    private var db = Firestore.firestore()
    private var storage = Storage.storage().reference()
    
    init() {
        // We call fetchPosts() as soon as the manager is created.
        fetchPosts()
    }
    
    // 1. Fetching Posts
    // This function remains the same. Our fix in Post.swift (making
    // imageUrlFront optional) will correctly handle old posts.
    func fetchPosts() {
        db.collection("posts")
          // We order by timestamp, descending, so the newest posts are first.
          .order(by: "timestamp", descending: true)
          // addSnapshotListener gives us real-time updates.
          .addSnapshotListener { querySnapshot, error in
              
              if let error = error {
                  print("Error getting posts: \(error.localizedDescription)")
                  return
              }
              
              guard let documents = querySnapshot?.documents else {
                  print("No documents")
                  return
              }
              
              // We use compactMap to try and decode each document into our Post model.
              // This is why we made Post 'Codable'.
              self.posts = documents.compactMap { document -> Post? in
                  do {
                      return try document.data(as: Post.self)
                  } catch {
                      print("Error decoding post: \(error.localizedDescription)")
                      return nil
                  }
              }
          }
    }
    
    // 2. Creating a New Post
    // --- COMPLETELY UPDATED FUNCTION ---
    // We now take two images (front and back)
    func createPost(description: String, imageBack: UIImage, imageFront: UIImage, completion: @escaping (Bool) -> Void) {
        
        // We need to upload two images. We'll use a DispatchGroup
        // to know when both uploads are finished.
        let group = DispatchGroup()
        
        var backImageUrl: String?
        var frontImageUrl: String?
        var uploadError = false

        // --- Step 1: Upload the Back Image ---
        group.enter() // Enter the group for the back image
        self.uploadImage(image: imageBack) { url in
            if let url = url {
                backImageUrl = url.absoluteString
            } else {
                uploadError = true
            }
            group.leave() // Leave the group for the back image
        }
        
        // --- Step 2: Upload the Front Image ---
        group.enter() // Enter the group for the front image
        self.uploadImage(image: imageFront) { url in
            if let url = url {
                frontImageUrl = url.absoluteString
            } else {
                uploadError = true
            }
            group.leave() // Leave the group for the front image
        }
        
        // --- Step 3: Wait for both uploads, then save to Firestore ---
        group.notify(queue: .main) {
            
            // If either upload failed, or we don't have both URLs, stop.
            guard let backURL = backImageUrl, let frontURL = frontImageUrl, !uploadError else {
                print("Error: One or more images failed to upload.")
                completion(false)
                return
            }
            
            // --- Step 4: Save the Post Info to Firestore ---
            
            let postData: [String: Any] = [
                "description": description,
                "imageUrlBack": backURL,        // New field
                "imageUrlFront": frontURL,       // New field
                "timestamp": Timestamp(date: Date()) // Use the current time
            ]
            
            self.db.collection("posts").addDocument(data: postData) { error in
                if let error = error {
                    print("Error saving post to Firestore: \(error.localizedDescription)")
                    completion(false)
                    return
                }
                
                // All steps succeeded!
                print("Successfully created post!")
                completion(true)
            }
        }
    }
    
    // --- NEW HELPER FUNCTION ---
    // A reusable function to upload a single image and return its URL.
    private func uploadImage(image: UIImage, completion: @escaping (URL?) -> Void) {
        
        // --- FIX: Move image compression to a background thread ---
        // This prevents the main thread (UI) from freezing.
        DispatchQueue.global(qos: .userInitiated).async {
            
            // Convert the UIImage to Data (This is the heavy work)
            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                print("Could not get image data")
                // Make sure to call completion on the main thread
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            // Create a unique ID for the image file
            let filename = UUID().uuidString + ".jpg"
            // We are in a closure, so we need 'self.storage'
            let imageRef = self.storage.child("images/\(filename)")
            
            // Upload the data
            imageRef.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    print("Error uploading image: \(error.localizedDescription)")
                    // Make sure to call completion on the main thread
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                }
                
                // Get the download URL
                imageRef.downloadURL { url, error in
                    if let error = error {
                        print("Error getting download URL: \(error.localizedDescription)")
                        // Make sure to call completion on the main thread
                        DispatchQueue.main.async {
                            completion(nil)
                        }
                        return
                    }
                    
                    // Success! Return the URL on the main thread.
                    DispatchQueue.main.async {
                        completion(url)
                    }
                }
            }
        }
        // --- END FIX ---
    }
    // --- END NEW HELPER ---
}
