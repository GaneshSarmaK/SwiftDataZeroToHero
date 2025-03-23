//
//  PostDataSource.swift
//  SwiftDataZeroToHero
//
//  Created by NVR4GET on 17/3/2025.
//

import SwiftData
import SwiftUI

@Observable
final class PostViewModel {
    
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext
    
    var posts: [Post] = []
    
    
    @MainActor
    init() {
        self.modelContainer = ModelContainer.sharedModelContainer
        self.modelContext = modelContainer.mainContext
        //dump(posts[0].postKind)
    }
    
    func addPost(_ post: Post) {
        modelContext.insert(post)
        save()
        fetchPosts()
    }
    
    func save() {
        do {
            try modelContext.save()
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    func fetchPosts(friendIDs: [String] = [], kind: PostKind? = nil) {
        
        let filterByKind = #Predicate<Post> {
            if kind != nil {
                return $0.postKind == kind!.rawValue
            } else {
                return true
            }
        }
        
        let fetchDescriptor = FetchDescriptor<Post>(predicate: filterByKind)
        
        do {
            //posts = try modelContext.fetch(fetchDescriptor)
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
    }
    
    
    
    func deletePost(_ post: Post) {
        modelContext.delete(post)
        save()
        fetchPosts()
    }
    
}

