//
//  PostCreationView.swift
//  SwiftDataZeroToHero
//
//  Created by NVR4GET on 17/3/2025.
//

import SwiftUI
import SwiftData
import PhotosUI

struct PostCreationView: View {
    
    @Binding var path: [NavViews]
    
    @State private var postTitle: String = ""
    @State private var postKindSelectedSegment: PostKind = .created
    @State private var selectedFriends: Set<String> = []
    @State private var photoPickerItem: PhotosPickerItem?
    @State var photoData: Data? = nil
    
    @Environment(FriendViewModel.self) var friendViewModel
    @Environment(PostViewModel.self) var postViewModel
    
    var post: Post?
    
    var body: some View {
        
        VStack {
            
            
            Text("Friends: ")
                .font(.title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, -10)
            
            
            HorizontalFriendsView(selectedFriends: $selectedFriends, path: $path, friends: friendViewModel.friends)
            
            
            Spacer()
            
            (post != nil ? ImageManager.loadImageFromDocuments(filename: post!.photoURL!) : photoData?.toImage ?? Image(systemName: "person.circle"))
                .resizable()
                .scaledToFit()
                .frame(width: 200)
                .clipShape(.circle)
            
            PhotosPicker("Select image", selection: $photoPickerItem, matching: .images)
            
            Spacer()
            
            Text("Post title: ")
                .font(.title)
                .padding(.bottom, -10)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            TextField("Enter post title", text: $postTitle)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(maxWidth: .infinity)
                .padding()
            
            Spacer()
            
            Text("Post Kind: ")
                .font(.title)
                .padding(.bottom, -10)
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
                        await postViewModel.addPost(title: postTitle, colour: .random, friends: Array(selectedFriends), postKind: postKindSelectedSegment, photoData: photoData)
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
            .disabled(postTitle.isEmpty || selectedFriends.isEmpty || photoData == nil)
            
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
        .onChange(of: photoPickerItem) {
            Task {
                if let imageData = try await photoPickerItem?.loadTransferable(type: Data.self) {
                    photoData = imageData
                } else {
                    print("Photo failed")
                }
            }
        }
    }
}

#Preview {
    MainView()
        .modelContainer(for: [Friend.self, Post.self], inMemory: true)
}
