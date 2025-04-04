//
//  Utils.swift
//  SwiftDataZeroToHero
//
//  Created by NVR4GET on 17/3/2025.
//

import SwiftUI

extension Color {
    static var random: Color {
        return Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
}

enum NavViews: Hashable {
    case postCreationView(Post?)
    case friendCreationView(Friend?)
}

struct ImageManager {
    
    static func saveImageToDocuments(data: Data) -> String? {
        let filename = "\(UUID().uuidString).jpg"
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = directory.appendingPathComponent(filename)
        
        do {
            try data.write(to: fileURL)
            print(fileURL.absoluteString)
            return filename
        } catch {
            print("Failed to write image data: \(error)")
            return nil
        }
    }
    
    static func deleteImageFromDocuments(filename: String) {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = directory.appendingPathComponent(filename)

        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(at: fileURL)
                print("Deleted image: \(filename)")
            } catch {
                print("Failed to delete image: \(error.localizedDescription)")
            }
        } else {
            print("File does not exist at path: \(fileURL)")
        }
    }
    
    static func loadImageFromDocuments(filename: String) -> Image {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = directory.appendingPathComponent(filename)

        if let uiImage = UIImage(contentsOfFile: fileURL.path) {
            return Image(uiImage: uiImage)
        } else {
            print(" Failed to load image at: \(fileURL)")
            return Image(systemName: "exclamationmark.triangle")
        }
    }
}



