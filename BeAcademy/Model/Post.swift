//
//  Post.swift
//  BeAcademy
//
//  Created by Elizbar Kheladze on 11/11/25.
//

import Foundation
import FirebaseFirestore

struct Post: Identifiable, Codable {
    @DocumentID var id: String?
    var description: String
    var imageUrlBack: String
    var imageUrlFront: String?
    var timestamp: Timestamp
    
    var formattedTimestamp: String {
        let date = timestamp.dateValue()
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case description
        case imageUrlBack
        case imageUrlFront
        case timestamp
    }
}
