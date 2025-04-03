//
//  FriendDataSource.swift
//  SwiftDataZeroToHero
//
//  Created by NVR4GET on 3/4/2025.
//

import SwiftUI
import SwiftData

@ModelActor
final actor FriendDataSource {
    
    func addFriend(_ friend: Friend) {
        modelContext.insert(friend)
        save()
    }
    
    func deleteFriend(_ friend: Friend) {
        modelContext.delete(friend)
        save()
    }
    
    func save() {
        do {
            try modelContext.save()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func fetchFriends() -> [Friend]{
        do {
            let friends = try modelContext.fetch(
                FetchDescriptor<Friend>(
                    sortBy: [SortDescriptor(\.name)]
                )
            )
            return friends
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func updateFriend(name: String, url: String, friend: Friend) {
        friend.name = name
        friend.url = url
        save()
    }
    
}
