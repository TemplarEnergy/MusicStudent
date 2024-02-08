//
//  DatabaseManager.swift
//  MusicStudent
//
//  Created by Thomas Radford on 24/12/2023.
//

import Foundation 

class DatabaseManager {
    static let shared = DatabaseManager()
    private let databaseURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("students.json")
   
    
    func saveStudents(_ students: [Student]) {
        do {
            let data = try JSONEncoder().encode(students)
            try data.write(to: databaseURL)
        } catch {
            print("Error saving data: \(error)")
        }
    }
    
    func loadStudents() -> [Student] {
        do {
           print("the url is \(databaseURL)")
            let data = try Data(contentsOf: databaseURL)
            return try JSONDecoder().decode([Student].self, from: data)
        } catch {
            print("Error loading data: \(error)")
            return []
        }
    }
    
    // Inside DatabaseManager

    func updateStudent(_ updatedStudent: Student) {
        var students = loadStudents()
        
        if let index = students.firstIndex(where: { $0.id == updatedStudent.id }) {
            students[index] = updatedStudent
            saveStudents(students)
        } else {
            print("Student not found for update.")
        }
    }
    
    // Function to delete a student
        func deleteStudent(_ student: Student) {
            
                var students = loadStudents()
            if let index = students.firstIndex(where: { $0.id == student.id }) {
                students.remove(at: index)
                saveStudents(students)
                
            } else {
                print("Student not found in the database.")
            }
        }
    
    func addCalendarStudent(_ updatedStudent: Student) {
        do {
            let data = try JSONEncoder().encode(updatedStudent)
            try data.write(to: databaseURL)
        } catch {
            print("Error saving data: \(error)")
        }
    }
    
    func getStudentByFirstName(_ firstName: String) -> Student? {
        return loadStudents().first { $0.firstName == firstName }
    }

    func getStudentByLessonTime(_ time: Date) -> Student? {
        return loadStudents().first { student in
            student.lessons.contains { lesson in
                lesson.time == time
            }
        }
    }



}
