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
                        .transition(.move(edge: .top))
                        .animation(.easeInOut, value: areFriendsVisible)
                }
                
                HStack{
                    Menu {
                        Button {
                            selectedKind = nil
                            Task {
                                await postViewModel.fetchPosts(friendIDs: Array(selectedFriends))
                            }
                        } label: {
                            Label("All", systemImage: selectedKind == nil ? "checkmark.square" : "square")
                        }
                        
                        Button {
                            selectedKind = .created
                            Task {
                                await postViewModel.fetchPosts(friendIDs: Array(selectedFriends), kind: .created)
                            }
                        } label: {
                            Label("Created", systemImage: selectedKind == .created ? "checkmark.square" : "square")
                        }
                        
                        Button {
                            selectedKind = .received
                            Task {
                                await postViewModel.fetchPosts(friendIDs: Array(selectedFriends), kind: .received)
                            }
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
                        selectedKind = nil
                        Task {
                            await postViewModel.fetchPosts( friendIDs: Array(selectedFriends))
                        }
                    } label: {
                        Text("Clear all")
                            .padding()
                            .foregroundColor(.red)
                    }
                }
                
                Spacer(minLength: 15)
                
                Text("Posts: ")
                    .font(.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(-5)
                
                postsGrid
                
                Text("Friends: ")
                    .font(.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(-5)
                
                friendsGrid
                
                Button(action: {
                    path.append(.postCreationView(nil))
                }, label: {
                    Text("Add new post")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                })
                
                Button {
                    let array = Array(repeating: 100, count: 20)
                    for i in array {
                        let randomInt = Int.random(in: 100...1000)
                        print("Adding \(i) with text \(randomInt)")
//                        Testing
                        Task {
                            await postViewModel.addPost(title: "\(randomInt)", colour: .random, friends: [UUID().uuidString], postKind: .created)
                        }
                    }
                } label: {
                    Text("Bulk Add")
                }
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
                Task {
                    await postViewModel.fetchPosts(friendIDs: Array(selectedFriends), kind: selectedKind)
                }
            }
            .onAppear {
                Task {
                    await postViewModel.fetchPosts()
                    await friendViewModel.fetchFriends()
                }
            }
        }
        .environment(postViewModel)
        .environment(friendViewModel)
    }
}

extension MainView{
    var friendsGrid: some View {
        ScrollView(.horizontal) {
            LazyHGrid(rows: [GridItem(.flexible())]) {
                ForEach(friendViewModel.friends) { friend in
                    let colour: Color = .random
                    VStack{
                        Circle()
                            .fill(colour.opacity(0.6)) // or use a random/user color
                            .frame(width: 50, height: 50)
                        
                        Text("\(friend.name)")
                        Text("\(friend.url).")
                            .font(.footnote)
                        
                    }
                    .padding()
                    .contextMenu {
                        Button(role: .destructive) {
                            Task {
                                await friendViewModel.deleteFriend(friend)
                            }
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
        .frame(height: 120)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 0.25)
        )    }
    
    var postsGrid: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]) {
                ForEach(postViewModel.posts) { post in
                    
                    VStack {
                        Circle()
                            .fill(post.colour) // or use a random/user color
                            .frame(width: 50, height: 50)
                        Text("\(post.title)")
                        Text("\(post.postKind)")
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 0.25)
                    )
                    .contextMenu {
                        Button(role: .destructive) {
                            Task {
                                await postViewModel.deletePost(post)
                            }
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
                .stroke(Color.gray, lineWidth: 0.25)
        )
    }
    
}

extension MainView{
    
    func updateFriend(_ friend: Friend){
        path.append(.friendCreationView(friend))
    }
    
    func updatePost(_ post: Post){
        path.append(.postCreationView(post))
    }
}

#Preview {
    MainView()
        .modelContainer(for: [Friend.self, Post.self], inMemory: false)
}
