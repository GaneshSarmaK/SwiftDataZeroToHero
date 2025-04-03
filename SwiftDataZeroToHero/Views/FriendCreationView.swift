//
//  FriendCreationView.swift
//  SwiftDataZeroToHero
//
//  Created by NVR4GET on 17/3/2025.
//

import SwiftUI

struct FriendCreationView: View {
    
    @Environment(FriendViewModel.self) var friendViewModel
    
    @Binding var path: [NavViews]
    
    @State private var friendName: String = ""
    @State private var friendURL: String = ""
    
    var friend: Friend?
    
    var body: some View {
        
        VStack {
            
            Spacer()
            
            Text("Friend Name:")
                .font(.title)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            TextField("Enter name", text: $friendName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(maxWidth: 300)
                .padding()
            
            Text("Friend URL:")
                .font(.title)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            TextField("Enter url", text: $friendURL)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(maxWidth: 300)
                .padding()
            
            Spacer()
            
            Button(action: {
                if let friend {
                    Task {
                        await friendViewModel.updateFriend(name: friendName, url: friendURL, friend: friend)
                    }
                } else {
                    Task {
                        await friendViewModel.addFriend(name: friendName, url: friendURL)
                    }
                }
                path.removeLast()
            }, label: {
                Text(friend == nil ? "Add new Friend" : "Update Friend")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            })
            .disabled(friendURL.isEmpty || friendName.isEmpty)
        }
        .onAppear {
            if let friend {
                friendName = friend.name
                friendURL = friend.url
            }
        }
    }
}

