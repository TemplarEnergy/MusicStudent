//
//  PlistManager.swift
//  MusicStudent
//
//  Created by Thomas Radford on 03/02/2024.
//

import Foundation

class PlistManager {
    static let shared = PlistManager()

    private var headTeacherPlistURL: URL {
        // Replace "HeadTeacher.plist" with your actual plist file name
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent("HeadTeacher.plist")
    }

    func saveHeadTeacherData(_ headTeacher: HeadTeacher) {
        do {
            let encoder = PropertyListEncoder()
            let data = try encoder.encode(headTeacher)
            try data.write(to: headTeacherPlistURL)
        } catch {
            print("Error encoding HeadTeacher data: \(error)")
        }
    }

    func loadHeadTeacherData() -> HeadTeacher? {
        do {
            let data = try Data(contentsOf: headTeacherPlistURL)
            let decoder = PropertyListDecoder()
            let headTeacher = try decoder.decode(HeadTeacher.self, from: data)
            return headTeacher
        } catch {
            let headTeacher  =   HeadTeacher(
                companyName: "",
                calendarName: "",
                teacherNumber: "0",
                firstName: "",
                lastName: "",
                phoneNumber: "",
                phoneNumber2: "",
                street1: "",
                street2: "",
                city: "",
                county: "",
                country: "",
                postalCode: "",
                email: "",
                active: true,
                rate: "",
                payableName: "",
               accountNumber: "",
               sortCode: ""
            )
            return headTeacher
        }
        
    }
}

