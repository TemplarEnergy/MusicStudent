//
//  Teacher.swift
//  MusicStudent
//
//  Created by Thomas Radford on 25/01/2024.
//

import Foundation

struct Teacher: Codable, Identifiable, Hashable {
    var id = UUID()
    var companyName: String
    var teacherNumber: String
    var firstName: String
    var lastName: String
    var phoneNumber: String
    var phoneNumber2: String
    var street1: String
    var street2: String
    var city: String
    var county: String
    var country: String
    var postalCode: String
    var email: String
    var active: Bool
    var rate: Double

}

