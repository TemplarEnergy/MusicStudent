//
//  LessonDataManager.swift
//  MusicStudent
//
//  Created by Thomas Radford on 04/02/2024.
//

import Foundation

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
    func findLessonDurationRate(duration: String, multiplier: Int) -> String? {
   /*     guard let encodedData = UserDefaults.standard.data(forKey: "lessonRateKey") else {
            return nil // Return nil if data is not found
        }
*/
        do {
            let data = try Data(contentsOf: lessonRatePlistURL)
            let decoder = PropertyListDecoder()
            let lessonRate = try decoder.decode([LessonRate].self, from: data)
     //       let lessonRates = try JSONDecoder().decode([LessonRate].self, from: encodedData)
            // Find the lesson rate with the specified duration
            if let aLessonRate = lessonRate.first(where: { $0.duration == duration }) {
                // Assuming `fee` is a property representing the lesson rate
                if let rate = Int(aLessonRate.fee) {
                    let multipliedRate = rate * multiplier
                    return String(multipliedRate) // Convert the multiplied rate back to a string
                } else {
                    return nil // Return nil if the rate cannot be converted to an integer
                }
            } else {
                return nil // Return nil if the duration is not found
            }
        } catch {
            print("Error decoding lesson rate: \(error)")
            return nil // Return nil if decoding fails
        }
    }

/*    private func getPlistURL() -> URL? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }

        return documentsDirectory.appendingPathComponent("LessonRate.plist")
    }*/
}

