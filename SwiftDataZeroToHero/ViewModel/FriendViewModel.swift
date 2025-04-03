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
 
    let dataSource: FriendDataSource
    var friends: [Friend] = []
    
    init(){
        let container = ModelContainer.sharedModelContainer
        dataSource = FriendDataSource(modelContainer: container)
    }
    
    func addFriend(name: String, url: String) async {
        let newFriend = Friend(
            name: name,
            url: url
        )
        await dataSource.addFriend(newFriend)
        friends.append(newFriend)
    }
    
    func updateFriend(name: String, url: String, friend: Friend) async {
        await dataSource.updateFriend(name: name, url: url, friend: friend)
    }
    
    func fetchFriends() async {
        let items = await dataSource.fetchFriends()
        friends = items
    }
    
    func deleteFriend(_ friend: Friend) async {
        friends.removeAll(where: { $0 == friend })
        await dataSource.deleteFriend(friend)
    }
    
}
