//
//  FriendCreationView.swift
//  SwiftDataZeroToHero
//
//  Created by NVR4GET on 17/3/2025.
//

import SwiftUI

struct FriendCreationView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    @Binding var path: [NavViews]
    
    @State private var friendName: String = ""
    
    @State private var friendURL: String = ""
    
    var friend: Friend?
    
    var body: some View {
        
        VStack {
            
            Text("Friend Name:")
                .font(.title)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            TextField("Enter name", text: $friendName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(maxWidth: 300)
                .padding()
            
            
            Text("Friend URL:")
                .font(.title)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            TextField("Enter url", text: $friendURL)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(maxWidth: 300)
                .padding()
            
            Button(action: {
                if let friend {
                    updateFriend(friend)
                } else {
                    createFriend()}
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
    
    private func createFriend() {
        let newFriend = Friend(
            name: friendName,
            url: friendURL
        )
        modelContext.insert(newFriend)
        saveData()
        
    }
    
    private func updateFriend(_ friend: Friend) {
        friend.name = friendName
        friend.url = friendURL
        saveData()
    }
    
    private func saveData(){
        do {
            try modelContext.save()
        } catch {
            print("Error saving: \(error)")
        }
    }
}

