//
//  SwiftDataSource.swift
//  SwiftDataZeroToHero
//
//  Created by NVR4GET on 17/3/2025.
//

import SwiftData
import SwiftUI

@Observable
final class FriendViewModel {
    
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext
    
    var friends: [Friend] = []
    
    @MainActor
    init(){
        self.modelContainer = ModelContainer.sharedModelContainer
        self.modelContext = modelContainer.mainContext
        fetchFriends()
    }
    
    func addFriend(_ friend: Friend) {
        modelContext.insert(friend)
        save()
    }
    
    func save() {
        do {
            try modelContext.save()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func fetchFriends() {
        do {
            friends = try modelContext.fetch(
                FetchDescriptor<Friend>(
                    sortBy: [SortDescriptor(\.name)]
                )
            )
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func fetchPosts(_ friendIDs: [String]) {
        do {
            let fetchDescriptor = FetchDescriptor<Friend>(
                predicate: #Predicate { friend in
                    friendIDs.contains(friend.id) },
                sortBy: [SortDescriptor(\.name)]
            )
            
            friends = try modelContext.fetch(fetchDescriptor)
        } catch {
            fatalError("Error fetching posts for friend IDs: \(error.localizedDescription)")
        }
    }
    
    func deleteFriend(_ friend: Friend) {
        modelContext.delete(friend)
        save()
        fetchFriends()
    }
    
}
