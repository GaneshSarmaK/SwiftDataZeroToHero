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
    
    @Environment(\.horizontalSizeClass) var sizeClass
    
    var columns: [GridItem] {
        let count = (sizeClass == .regular) ? 3 : 2
        return Array(repeating: GridItem(.flexible(), spacing: 10), count: count)
    }
        
    var body: some View {
        NavigationStack(path: $path){
            VStack {
                
                if areFriendsVisible {
                    withAnimation() {
                        HorizontalFriendsView(selectedFriends: $selectedFriends, path: $path, friends: friendViewModel.friends)
                            .transition(.move(edge: .top))
                            .animation(.easeInOut, value: areFriendsVisible)
                    }
                }
                
                controlPanel
                
                Spacer(minLength: 15)
                
                Text("Posts: ")
                    .font(.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(5)
                
                postsGrid
                
                Spacer()
                
                Button(action: {
                    path.append(.postCreationView(nil))
                }, label: {
                    Text("Add new post")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                })
                
                //                /*Testing*/
                //                Button {
                //                    let array = Array(repeating: 100, count: 20)
                //                    for i in array {
                //                        let randomInt = Int.random(in: 100...1000)
                //                        print("Adding \(i) with text \(randomInt)")
                ////                        Testing
                //                        Task {
                //                            await postViewModel.addPost(title: "\(randomInt)", colour: .random, friends: [UUID().uuidString], postKind: .created)
                //                        }
                //                    }
                //                } label: {
                //                    Text("Bulk Add")
                //                }
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
    
    var controlPanel: some View {
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
            
            Text(areFriendsVisible ? "Hide Friends" : "Show Friends")
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(Capsule())
                .onTapGesture {
                    withAnimation(.none) {
                        areFriendsVisible.toggle()
                    }
                }
            
            Spacer()
            
            Text("Clear all")
                .padding()
                .foregroundColor(.red)
                .onTapGesture {
                    withAnimation(.none) {
                        areFriendsVisible = false
                        selectedFriends = []
                        selectedKind = nil
                        Task {
                            await postViewModel.fetchPosts( friendIDs: Array(selectedFriends))
                        }
                    }
                }
        }
    }
    
    var postsGrid: some View {
        
        
        ScrollView {
            let postImageSize = (sizeClass == .regular) ? 250.0 : 150.0
            
            Text("Total Posts: \(postViewModel.posts.count)")
                .bold()
            LazyVGrid(columns: columns) {
                ForEach(postViewModel.posts) { post in
                    VStack {
                        ImageManager.loadImageFromDocuments(filename: post.photoURL!)
                            .resizable()
                            .scaledToFill()
                            .frame(width: postImageSize, height: postImageSize)
                            .cornerRadius(10)
                        
                        Text("\(post.title)")
                        
                        HStack {
                            Text("\(post.friends.count) users")
                                .padding(5)
                                .padding(.horizontal, 8)
                                .background(post.colour)
                                .clipShape(Capsule())
                            Image(systemName: post.postKind == "created" ? "arrowshape.up.fill" : "arrowshape.down.fill")
                                .foregroundColor(post.postKind == "created" ? .green : .red)
                            
                        }
                    }
                    .padding(5)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                            .background(.gray.opacity(0.1))
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.bottom, 15)
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
            
        }
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
