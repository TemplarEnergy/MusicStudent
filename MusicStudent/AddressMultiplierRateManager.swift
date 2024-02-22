//
//  RateMultiplierAddressManager.swift
//  MusicStudent
//
//  Created by Thomas Radford on 21/02/2024.
//

import Foundation

class AddressMultiplierRateManager {
    static let shared = AddressMultiplierRateManager()
    
    private var addressMultiplierRatePlistURL: URL {
        // Replace "HeadTeacher.plist" with your actual plist file name
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent("AddressMultiplierRate.plist")
    }
    
    private init() {}
    
    func saveAddressMultiplierRate(_ rates: [AddressMultiplierRate]) {
        // Encode the rates and save them to the plist file
        do {
            let data = try PropertyListEncoder().encode(rates)
            try data.write(to: addressMultiplierRatePlistURL)
        } catch {
            print("Error saving address-multiplier rates: \(error)")
        }
    }

    
    func loadAddressMultiplierRates() -> [AddressMultiplierRate] {
        // Load the data from the plist file (handle errors appropriately)
        do {
            let data = try Data(contentsOf: addressMultiplierRatePlistURL)
            let addressMultiplierRates = try PropertyListDecoder().decode([AddressMultiplierRate].self, from: data)
            return addressMultiplierRates
        } catch {
            print("Error loading address-multiplier rates: \(error)")
            return []
        }
    }
    
    func findMultiplier(for address: String, in rates: [AddressMultiplierRate]) -> Double? {
           return rates.first { $0.address == address }?.multiplier
       }
    
    func AddNewLessonExisting( student: Student, name: String, street: String, instrument: String,  day: String, time: Date,  duration: String )  {
      var exisitingStudent = student
            let count = student.lessons.count
       
            
        
            if DatabaseManager.shared.getStudentByLessonTime(time) != nil {
                // Do nothing if the lesson already exists
            } else {
                let addedLesson = Student.Lesson(
                    id: UUID(),
                    number: String(count + 1),
                    day: day,
                    time: time,
                    duration: duration
                )
                exisitingStudent.street1 = street
                exisitingStudent.instrument = instrument
                exisitingStudent.lessons.append(addedLesson)
                exisitingStudent.multiplier = AddressMultiplierRateManager.shared.updateMultiplier(firstThreeWords: street)
                DatabaseManager.shared.updateStudent(exisitingStudent)
            }
        
    }
        
        func AddLessonAndStudent( name: String, street: String, instrument: String,  day: String, time: Date,  duration: String ) -> Student {
            let addedLesson = Student.Lesson(
                id: UUID(),
                number: "1",
                day: day,
                time: time,
                duration: duration
            )
            let student = Student(
                studentNumber: "",
                firstName: name,
                lastName: "",
                parentsName: "",
                parentsLastName: "",
                phoneNumber: "",
                phoneNumber2: "",
                street1: street,
                street2: "",
                city: "",
                county: "",
                country: "UK",
                postalCode: "",
                email: "",
                instrument: instrument,
                nominalDay: day,
                nominalTime: time,
                nominalDuration: duration,
                lessons: [addedLesson],
                kit: [],
                active: true,
                multiplier: 1.0
            )
            return student
    }
    
    func updateMultiplier(firstThreeWords: String) -> Double {
        let addressMultiplierRates = AddressMultiplierRateManager.shared.loadAddressMultiplierRates()
        if firstThreeWords == "90 Romsey Road" {
            print("say hi")
        }
        // Check if any of the rates' addresses match firstThreeWords
        if let matchingRate = addressMultiplierRates.first(where: { $0.address == firstThreeWords }) {
            return matchingRate.multiplier
        }
        
        return 1.0 // Default multiplier if no match found
    }

}
