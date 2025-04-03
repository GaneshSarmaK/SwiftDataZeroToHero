//
//  PostDataSource.swift
//  SwiftDataZeroToHero
//
//  Created by NVR4GET on 17/3/2025.
//

import SwiftData
import SwiftUI


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


@Observable
final class PostViewModel {
    
    let dataSource: PostDataSource
    var posts: [Post] = []
    
    init() {
        let contianer = ModelContainer.sharedModelContainer
        dataSource = PostDataSource(modelContainer: contianer)
    }
    
    func addPost(title: String, colour: Color, friends: [String], postKind: PostKind) async {
        let newPost = Post(
            title: title,
            colour: colour,
            friends: friends,
            postKind: postKind
        )
        await dataSource.addPost(newPost)
        posts.append(newPost)
    }

    func fetchPosts(friendIDs: [String] = [], kind: PostKind? = nil) async {
        let items = await dataSource.fetchPosts(friendIDs: friendIDs, kind: kind)
        posts = items
    }
    
    func updatePost(title: String, friends: [String], postKind: PostKind, post: Post)  async {
        await dataSource.updatePost(title: title, friends: friends, postKind: postKind, post: post)
    }
    
    func deletePost(_ post: Post) async {
        posts.removeAll(where: { $0 == post })
        await dataSource.deletePost(post)
    }
}

