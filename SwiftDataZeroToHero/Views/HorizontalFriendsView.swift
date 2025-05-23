//
//  HorizontalFriendsView.swift
//  SwiftDataZeroToHero
//
//  Created by NVR4GET on 17/3/2025.
//

import SwiftUI
import SwiftData

struct HorizontalFriendsView: View {
    
    @Environment(FriendViewModel.self) var friendViewModel
    @Binding var selectedFriends: Set<String>
    @Binding var path: [NavViews]
        
    let friends: [Friend]
    
    var body: some View {
        
        ScrollView(.horizontal, showsIndicators: false) {
            
            HStack {
                VStack {
                    Text("+")
                        .frame(width: 50, height: 50)
                        .background(.red)
                        .cornerRadius(25)
                    
                    Text("New")
                }
                .padding(.leading, 10)
                .padding(.trailing, 10)
                .onTapGesture {
                    path.append(.friendCreationView(nil))
                }
                ForEach(friends) { friend in
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 30))]) {
                        let isSelected = selectedFriends.contains(friend.id)
                        
                        ZStack {
                            Circle()
                                .fill(Color.random) // or use a random/user color
                                .frame(width: 50, height: 50)
                            
                            if isSelected {
                                Image(systemName: "checkmark")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.green)
                            }
                        }
                        
                        Text("\(friend.name)")
                            .foregroundStyle(isSelected ? .green : .primary)
                    }
                    .onTapGesture {
                        toggleSelection(friend.id)
                    }
                    .contextMenu {
                        Button(role: .destructive) {
                            Task {
                                await friendViewModel.deleteFriend(friend)
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        
                        Button(role: .cancel) {
                            path.append(.friendCreationView(friend))
                        } label: {
                            Label("Update", systemImage: "trash")
                        }
                    }
                    .padding()
                    
                }
            }
        }
        
    }
    
    private func toggleSelection(_ id: String) {
        if selectedFriends.contains(id) {
            selectedFriends.remove(id)
        } else {
            selectedFriends.insert(id)
        }
    }
}

