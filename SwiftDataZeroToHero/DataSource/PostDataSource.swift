//
//  PostDataSource.swift
//  SwiftDataZeroToHero
//
//  Created by NVR4GET on 3/4/2025.
//

import SwiftUI
import SwiftData

@ModelActor
final actor PostDataSource {
    
    func addPost(_ post: Post) {
        modelContext.insert(post)
        save()
    }
    
    func deletePost(_ post: Post) {
        modelContext.delete(post)
        save()
    }
    
    func save() {
        do {
            try modelContext.save()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func fetchPosts(friendIDs: [String] = [], kind: PostKind? = nil) -> [Post]{
        var posts: [Post] = []
        let filterByKind = #Predicate<Post> {
            if kind != nil {
                return $0.postKind == kind!.rawValue
            } else {
                return true
            }
        }
        let fetchDescriptor = FetchDescriptor<Post>(predicate: filterByKind)
        do {
            let allPosts = try modelContext.fetch(fetchDescriptor)
            // In-memory filtering based on selected friends
            if !friendIDs.isEmpty {
                posts = allPosts.filter { post in
                    post.friends.contains { friendIDs.contains($0) }
                }
            } else {
                posts = allPosts
            }
        } catch {
            print("Error fetching posts: \(error)")
        }
        return posts
    }
    
    func updatePost(title: String, friends: [String], postKind: PostKind, post: Post) {
        post.title = title
        post.friends = friends
        post.postKind = postKind.rawValue
    }
    
}
