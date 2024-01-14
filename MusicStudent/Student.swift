//
//  Student.swift
//  MusicStudent
//
//  Created by Thomas Radford on 22/12/2023.
//

// Student.swift

import Foundation

struct Student: Codable, Identifiable, Hashable {
    var id = UUID()
    var firstName: String
    var lastName: String
    var parentsName: String
    var instrument: String
    var lessonDay: String
    var lessonTime: Date
    var duration: String
    var kit: [String]
    var active: Bool

    static let instruments = ["Violin", "Viola", "Cello", "Voice", "Piano", "Trio", "Ensemble"]
    static let daysOfWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
}
