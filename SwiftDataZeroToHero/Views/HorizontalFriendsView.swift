//
//  HorizontalFriendsView.swift
//  SwiftDataZeroToHero
//
//  Created by NVR4GET on 17/3/2025.
//

import SwiftUI
import SwiftData

struct HorizontalFriendsView: View {
    
    @Binding var selectedFriends: Set<String>
        
    let friends: [Friend]
    
    var body: some View {
        
        ScrollView(.horizontal, showsIndicators: false) {
            
            HStack {
                ForEach(friends) { friend in
                    VStack {
                        let isSelected = selectedFriends.contains(friend.id)
                        
                        ZStack {
                            Circle()
                                .fill(Color.gray.opacity(0.2)) // or use a random/user color
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

