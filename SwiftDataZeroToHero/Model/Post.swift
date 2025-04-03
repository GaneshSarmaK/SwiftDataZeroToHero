//
//  Post.swift
//  SwiftDataZeroToHero
//
//  Created by NVR4GET on 17/3/2025.
//

import SwiftUI
import SwiftData

@Model
final class Post: Identifiable {
    
    @Attribute(.unique) private(set) var id: String = UUID().uuidString
    var postKind: String
    var friends: [String]
    var title: String
    var colourRed: Double
    var colourGreen: Double
    var colourBlue: Double
    
    var colour: Color{
        get { Color(red: colourRed, green: colourGreen, blue: colourBlue) }
        set{
            if let uiColour = UIColor(newValue).cgColor.components{
                self.colourRed = Double(uiColour[0])
                self.colourGreen = Double(uiColour[1])
                self.colourBlue = Double(uiColour[2])
            }
        }
    }
    
    init(title: String, colour: Color, friends: [String], postKind: PostKind = .created) {
        
        self.friends = friends
        self.postKind = postKind.rawValue
        self.title = title
        
        if let uiColour = UIColor(colour).cgColor.components {
            self.colourRed = Double(uiColour[0])
            self.colourGreen = Double(uiColour[1])
            self.colourBlue = Double(uiColour[2])
        } else {
            self.colourRed = 0
            self.colourGreen = 0
            self.colourBlue = 0
        }
    }
}
//
//extension Post: Equatable {
//    static func == (lhs: Post, rhs: Post) -> Bool {
//        return lhs.id == rhs.id &&
//        lhs.colour == rhs.colour &&
//        lhs.title == rhs.title &&
//        lhs.friends == rhs.friends &&
//        lhs.postKind == rhs.postKind
//    }
//}
//
//extension Post: Hashable {
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(id)
//    }
//}

enum PostKind: String, Codable, Hashable, CaseIterable {
    case created
    case received
}
