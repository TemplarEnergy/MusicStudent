//
//  LessonDataManager.swift
//  MusicStudent
//
//  Created by Thomas Radford on 04/02/2024.
//

import Foundation

class LessonRateManager {
    static let shared = LessonRateManager()
    
    private var lessonRatePlistURL: URL {
        // Replace "HeadTeacher.plist" with your actual plist file name
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent("LeasonRate.plist")
    }

    private init() {}

    func saveLessonRate(_ lessonRate: [LessonRate]) {
        do {
            let encoder = PropertyListEncoder()
            let data = try encoder.encode(lessonRate)
            try data.write(to: lessonRatePlistURL)
        } catch {
            print("Error encoding lesson data: \(error)")
        }
    }


    func loadLessonRate() -> [LessonRate] {
 /*          guard let encodedData = UserDefaults.standard.data(forKey: "lessonRateKey") else {
               return []
           }
*/
           do {
               let data = try Data(contentsOf: lessonRatePlistURL)
               let decoder = PropertyListDecoder()
               let lessonRate = try decoder.decode([LessonRate].self, from: data)
           //    return headTeacher
           //    let lessonRate = try JSONDecoder().decode([LessonRate].self, from: encodedData)
               return lessonRate
           } catch {
               print("Error decoding lesson rate: \(error)")
               return []
           }
       }
    func findLessonDurationRate(duration: String, firstName: String, lastName: String) -> Double {
        let students = DatabaseManager.shared.loadStudents()
        do {
            let data = try Data(contentsOf: lessonRatePlistURL)
            let decoder = PropertyListDecoder()
            let lessonRate = try decoder.decode([LessonRate].self, from: data)
            if let foundLessonRate = lessonRate.first(where: { $0.duration == duration }) {
                if let rate = Double(foundLessonRate.fee) {
                    if let student = students.first (where: { $0.firstName == firstName && $0.lastName == lastName}) {
                        return rate * student.multiplier
                    }else {
                        return 0.0
                    }
                    
                } else {
                    return 0.0
                }
            } else {
                return 0.0  // Return nil if the duration is not found
            }
        } catch {
            print("Error decoding lesson rate: \(error)")
            return 0.00 // Return nil if decoding fails
        }
    }

}

