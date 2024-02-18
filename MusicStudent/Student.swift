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
    var studentNumber: String
    var firstName: String
    var lastName: String
    var parentsName: String
    var parentsLastName: String
    var phoneNumber: String
    var phoneNumber2: String
    var street1: String
    var street2: String
    var city: String
    var county: String
    var country: String
    var postalCode: String
    var email: String
    var instrument: String
    var nominalDay: String
    var nominalTime: Date
    var nominalDuration: String
    var lessons: [Lesson]
    var kit: [KitItem]
    var active: Bool
    var multiplier: Int
    
    
    struct KitItem: Identifiable, Codable, Hashable {
        var id = UUID()
        var name: String
        var date: Date
        var price: String
        var status: String
       }
    
    struct Lesson: Identifiable, Codable, Hashable {
        var id = UUID()
        var number: String
        var day: String
        var time: Date
        var duration: String
    //    var price: String
       }

}

