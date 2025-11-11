//
//  FirebaseManager.swift
//  BeAcademy
//
//  Created by Elizbar Kheladze on 11/11/25.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import UIKit
import Combine

class FirebaseManager: ObservableObject {
    
    @Published var posts: [Post] = []
    
    private var db = Firestore.firestore()
    private var storage = Storage.storage().reference()
    
    init() {
        fetchPosts()
    }
    
    func fetchPosts() {
        db.collection("posts")
          .order(by: "timestamp", descending: true)
          .addSnapshotListener { querySnapshot, error in
              
              if let error = error {
                  print("Error getting posts: \(error.localizedDescription)")
                  return
              }
              
              guard let documents = querySnapshot?.documents else {
                  print("No documents")
                  return
              }
              
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
    
    func createPost(description: String, imageBack: UIImage, imageFront: UIImage, completion: @escaping (Bool) -> Void) {
        
        let group = DispatchGroup()
        
        var backImageUrl: String?
        var frontImageUrl: String?
        var uploadError = false

        self.uploadImage(image: imageBack) { url in
            if let url = url {
                backImageUrl = url.absoluteString
            } else {
                uploadError = true
            }
            group.leave()
        }
        
        group.enter()
        self.uploadImage(image: imageFront) { url in
            if let url = url {
                frontImageUrl = url.absoluteString
            } else {
                uploadError = true
            }
            group.leave()
        }
        
        group.notify(queue: .main) {
            
            guard let backURL = backImageUrl, let frontURL = frontImageUrl, !uploadError else {
                print("Error: One or more images failed to upload.")
                completion(false)
                return
            }
            
            let postData: [String: Any] = [
                "description": description,
                "imageUrlBack": backURL,
                "imageUrlFront": frontURL,
                "timestamp": Timestamp(date: Date())
            ]
            
            self.db.collection("posts").addDocument(data: postData) { error in
                if let error = error {
                    print("Error saving post to Firestore: \(error.localizedDescription)")
                    completion(false)
                    return
                }
                
                print("Successfully created post!")
                completion(true)
            }
        }
    }
    
    private func uploadImage(image: UIImage, completion: @escaping (URL?) -> Void) {
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Could not get image data")
            completion(nil)
            return
        }
        
        let filename = UUID().uuidString + ".jpg"
        let imageRef = storage.child("images/\(filename)")
        
        imageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            imageRef.downloadURL { url, error in
                if let error = error {
                    print("Error getting download URL: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                
                completion(url)
            }
        }
    }
}
