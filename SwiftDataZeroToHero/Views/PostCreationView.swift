//
//  PostCreationView.swift
//  SwiftDataZeroToHero
//
//  Created by NVR4GET on 17/3/2025.
//

import SwiftUI
import SwiftData

struct PostCreationView: View {
    
    @Binding var path: [NavViews]
    
    @State private var postTitle: String = ""
    @State private var postKindSelectedSegment: PostKind = .created
    @State private var selectedFriends: Set<String> = []
    
    @Environment(FriendViewModel.self) var friendViewModel
    @Environment(PostViewModel.self) var postViewModel
    
    var post: Post?
    
    var body: some View {
        
        VStack {
            
            Spacer(minLength: 30)
            
            Text("Friends: ")
                .font(.title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            HStack{
                VStack {
                    Text("+")
                        .frame(width: 50, height: 50)
                        .background(.red)
                        .cornerRadius(25)
                    
                    Text("New")
                }
                .padding(.leading, 10)
                .onTapGesture {
                    path.append(.friendCreationView(nil))
                }
                
                HorizontalFriendsView(selectedFriends: $selectedFriends, friends: friendViewModel.friends)
                    .padding()
            }
            
            Spacer()
            
            Text("Post title: ")
                .font(.title)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            
            TextField("Enter post title", text: $postTitle)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(maxWidth: 300)
                .padding()
            
            Spacer()
            
            Text("Post Kind: ")
                .font(.title)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Picker("Select", selection: $postKindSelectedSegment) {
                ForEach(PostKind.allCases, id: \.self) { segment in
                    Text("\(segment)".capitalized)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            Spacer()
            
            Button(action: {
                if let post = post {
                    Task {
                        await postViewModel.updatePost(title: postTitle, friends: Array(selectedFriends), postKind: postKindSelectedSegment, post: post)
                    }
                } else {
                    Task {
                        await postViewModel.addPost(title: postTitle, colour: .random, friends: Array(selectedFriends), postKind: postKindSelectedSegment)
                    }
                }
                path.removeLast()
            }, label: {
                Text(post == nil ? "Add new post" : "Update Post")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            })
            .disabled(postTitle.isEmpty || selectedFriends.isEmpty)
            
        }
        .onAppear{
            Task {
                await friendViewModel.fetchFriends()
            }
            if let post = post {
                selectedFriends = Set(post.friends)
                postTitle = post.title
                postKindSelectedSegment = PostKind(rawValue: post.postKind) ?? .created
            }
        }
    }
}

#Preview {
    MainView()
        .modelContainer(for: [Friend.self, Post.self], inMemory: true)
}
