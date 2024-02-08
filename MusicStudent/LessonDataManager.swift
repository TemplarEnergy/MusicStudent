//
//  LessonDataManager.swift
//  MusicStudent
//
//  Created by Thomas Radford on 04/02/2024.
//

import Foundation

import Foundation

class LessonDataManager {
    static let shared = LessonDataManager()

    private init() {}

    func saveLessonData(_ lessonData: [LessonData]) {
           do {
               let encodedData = try JSONEncoder().encode(lessonData)
               UserDefaults.standard.set(encodedData, forKey: "lessonDataKey")
           } catch {
               print("Error encoding lesson data: \(error)")
           }
       }



    func loadLessonData() -> [LessonData] {
           guard let encodedData = UserDefaults.standard.data(forKey: "lessonDataKey") else {
               return []
           }

           do {
               let lessonData = try JSONDecoder().decode([LessonData].self, from: encodedData)
               return lessonData
           } catch {
               print("Error decoding lesson data: \(error)")
               return []
           }
       }
   
    private func getPlistURL() -> URL? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }

        return documentsDirectory.appendingPathComponent("LessonData.plist")
    }
}

