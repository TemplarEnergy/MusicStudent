//
//  InstrumentDataManager.swift
//  MusicStudent
//
//  Created by Thomas Radford on 05/02/2024.
//

import Foundation
//
//  LessonDataManager.swift
//  MusicStudent
//
//  Created by Thomas Radford on 04/02/2024.
//
 

import Foundation

class InstrumentDataManager {
    static let shared = InstrumentDataManager()

    private init() {}

    func saveInstruments(_ instruments: [String]) {
           do {
               let encodedData = try JSONEncoder().encode(instruments)
               UserDefaults.standard.set(encodedData, forKey: "instrumentDataKey")
           } catch {
               print("Error encoding instruments data: \(error)")
           }
       }



    func loadInstruments() -> [String] {
           guard let encodedData = UserDefaults.standard.data(forKey: "instrumentDataKey") else {
               return []
           }

           do {
               let instruments = try JSONDecoder().decode([String].self, from: encodedData)
               return instruments
           } catch {
               print("Error decoding instruments data: \(error)")
               return []
           }
       }
   
    private func getPlistURL() -> URL? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }

        return documentsDirectory.appendingPathComponent("Instruments.plist")
    }
}

