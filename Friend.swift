//
//  Item.swift
//  SwiftDataZeroToHero
//
//  Created by NVR4GET on 17/3/2025.
//

import SwiftUI
import SwiftData

@Model
final class Friend: Identifiable {
    @Attribute(.unique) private(set) var id: String = UUID().uuidString
    var name: String
    var url: String
    
    init(name: String, url: String) {
        self.name = name
        self.url = url
    }
}

extension Friend: Equatable {
    static func == (lhs: Friend, rhs: Friend) -> Bool {
        return lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.url == rhs.url
    }
}

extension Friend: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
