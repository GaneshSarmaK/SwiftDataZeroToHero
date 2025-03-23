//
//  ContentView.swift
//  SwiftDataZeroToHero
//
//  Created by NVR4GET on 17/3/2025.
//

import SwiftUI
import SwiftData



struct MainView: View {
    
    
    
    @State private var path: [NavViews] = []
    
    @State private var selectedFriends: Set<String> = []
    
    @State private var areFriendsVisible: Bool = false
    
    @State private var selectedKind: PostKind? = nil
    
    @State private var showKindOptions = false
    
    @State var friendViewModel: FriendViewModel = FriendViewModel()
    
    @State var postViewModel: PostViewModel = PostViewModel()
    
    
    var body: some View {
        NavigationStack(path: $path){
            VStack {
                
                if areFriendsVisible {
                    HorizontalFriendsView(selectedFriends: $selectedFriends, friends: friendViewModel.friends)
                }
                
                HStack{
                    
                    Menu {
                        Button {
                            selectedKind = nil
                            postViewModel.fetchPosts(friendIDs: Array(selectedFriends))
                        } label: {
                            Label("All", systemImage: selectedKind == nil ? "checkmark.square" : "square")
                        }
                        
                        Button {
                            selectedKind = .created
                            postViewModel.fetchPosts(friendIDs: Array(selectedFriends), kind: .created)
                        } label: {
                            Label("Created", systemImage: selectedKind == .created ? "checkmark.square" : "square")
                        }
                        
                        Button {
                            selectedKind = .received
                            postViewModel.fetchPosts(friendIDs: Array(selectedFriends), kind: .received)
                        } label: {
                            Label("Received", systemImage: selectedKind == .received ? "checkmark.square" : "square")
                        }
                    }
                    label: {
                        Text("Post Kind")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                    //                    Button {
                    //                        showKindOptions = true
                    //                    } label: {
                    //                        Text("Post Kind")
                    //                            .padding()
                    //                            .background(Color.blue)
                    //                            .foregroundColor(.white)
                    //                            .clipShape(Capsule())
                    //                    }
                    //                    .confirmationDialog("Filter by Post Kind", isPresented: $showKindOptions, titleVisibility: .visible) {
                    //                        Button("All") {
                    //                            postViewModel.fetchPosts(friendIDs: Array(selectedFriends))
                    //                        }
                    //                        Button("Created") {
                    //                            postViewModel.fetchPosts(friendIDs: Array(selectedFriends), kind: .created)
                    //                        }
                    //                        Button("Received") {
                    //                            postViewModel.fetchPosts(friendIDs: Array(selectedFriends), kind: .received)
                    //                        }
                    ////                        Button("Cancel", role: .cancel) {}
                    //                    }
                    
                    //                    .contextMenu {
                    //                        Button() {
                    //
                    //                            postViewModel.fetchPosts( friendIDs: Array(selectedFriends) )
                    //                        } label: {
                    //                            Text("All")
                    //                        }
                    //                        Button() {
                    //                            postViewModel.fetchPosts( friendIDs: Array(selectedFriends), kind: .created)
                    //                        } label: {
                    //                            Text("Created")
                    //                        }
                    //                        Button() {
                    //                            postViewModel.fetchPosts( friendIDs: Array(selectedFriends), kind: .received)
                    //                        } label: {
                    //                            Text("Received")
                    //                        }
                    //                    }
                    Spacer()
                    Button {
                        areFriendsVisible.toggle()
                    } label: {
                        Text(areFriendsVisible ? "Hide Friends" : "Show Friends")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                    
                    Spacer()
                    Button {
                        areFriendsVisible = false
                        selectedFriends = []
                        postViewModel.fetchPosts( friendIDs: Array(selectedFriends))
                    } label: {
                        Text("Clear all")
                            .padding()
                            .foregroundColor(.red)
                    }
                }
                Spacer(minLength: 15)
                
                Text("Friends: ")
                    .font(.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                friendsGrid
                
                Spacer(minLength: 15)
                
                Text("Posts: ")
                    .font(.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                postsGrid
                
                Spacer(minLength: 25)
                
                Button(action: {
                    path.append(.postCreationView(nil))
                    
                }, label: {
                    Text("Add new post")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                })
            }
            .padding()
            
            .navigationDestination(for: NavViews.self) { destination in
                switch(destination) {
                case .friendCreationView(let friend):
                    FriendCreationView(path: $path, friend: friend)
                case .postCreationView(let post):
                    PostCreationView(path: $path, post: post)
                }
            }
            .onChange(of: selectedFriends) {
                postViewModel.fetchPosts(friendIDs: Array(selectedFriends), kind: selectedKind)
            }
            .onAppear {
                postViewModel.fetchPosts()
                friendViewModel.fetchFriends()
            }
        }
    }
}

extension MainView{
    var friendsGrid: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                ForEach(friendViewModel.friends) { friend in
                    Text(friend.name)
                        .padding()
                        .contextMenu {
                            Button(role: .destructive) {
                                deleteFriend(friend)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            
                            Button(role: .cancel) {
                                updateFriend(friend)
                            } label: {
                                Label("Update", systemImage: "trash")
                            }
                        }
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 1)
        )    }
    
    var postsGrid: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                ForEach(postViewModel.posts) { post in
                    Text(post.title)
                        .padding()
                        .contextMenu {
                            Button(role: .destructive) {
                                deletePost(post)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            
                            Button(role: .cancel) {
                                updatePost(post)
                            } label: {
                                Label("Update", systemImage: "trash")
                            }
                        }
                }
            }
            Text("Total Posts: \(postViewModel.posts.count)")
                .bold()
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 1)
        )
    }
    
}

extension MainView{
    
    func deleteFriend(_ friend: Friend){
        withAnimation {
            friendViewModel.deleteFriend(friend)
        }
    }
    func deletePost(_ post: Post){
        withAnimation {
            postViewModel.deletePost(post)
        }
    }
    
    func updateFriend(_ friend: Friend){
        path.append(.friendCreationView(friend))
    }
    
    func updatePost(_ post: Post){
        path.append(.postCreationView(post))
    }
    
    private func addTestData(){
        var arr: [String] = []
        for i in 0...10{
            let frnd = Friend(name: "Name \(i)", url: "URL \(i)")
            arr.append(frnd.id)
            friendViewModel.addFriend(frnd)
        }
        for i in 0...10{
            let post = Post(title: "Title \(i)", colour: .random, friends: arr, postKind: .created)
            postViewModel.addPost(post)
        }
        for i in 10...20{
            let frnd = Friend(name: "Name \(i)", url: "URL \(i)")
            friendViewModel.addFriend(frnd)        }
        
    }
    
}

#Preview {
    MainView()
        .modelContainer(for: [Friend.self, Post.self], inMemory: false)
}
