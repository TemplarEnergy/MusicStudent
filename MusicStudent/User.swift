//
//  User.swift
//  MusicStudent
//
//  Created by Thomas Radford on 22/12/2023.
//

// User.swift

import Foundation

struct User: Codable, Identifiable {
    var id = UUID()
    var firstName: String
    var lastName: String
    var parentsName: String
    var instrument: String
    var lessonDay: String
    var lessonTime: Date
    var duration: String
    var kit: [String]

    static let instruments = ["Violin", "Viola", "Cello", "Voice", "Piano", "Trio", "Ensemble"]
    static let daysOfWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
}
