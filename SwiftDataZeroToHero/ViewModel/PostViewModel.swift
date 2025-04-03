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

