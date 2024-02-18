//
//  PopulateDatabaseFromCalendar.swift
//  MusicStudent
//
//  Created by Thomas Radford on 31/01/2024.
//

import Foundation
import SwiftUI
import EventKit


struct FromCalendar {
    
    static func PopulateStudents(headTeacher: HeadTeacher) {
        let eventStore = EKEventStore()
        var testWord: String = ""
        var nominalLessonDay: String = ""
        var validatedLessonTime: Date = Date()
      
        var calendarIdentifier = ""
        var multiplier = 1
   
        
        // Calculate next month's start and end dates
        let nextMonthDates = calculateNextMonthDates()
        
        eventStore.requestAccess(to: .event) { granted, error in
            if granted {
                let calendars = eventStore.calendars(for: .event)
                for calendar in calendars {
                    if calendar.title == headTeacher.calendarName {
                        calendarIdentifier = calendar.calendarIdentifier
                    }
                }
                
                if let calendar = eventStore.calendar(withIdentifier: calendarIdentifier) {
                    let predicate = eventStore.predicateForEvents(withStart: nextMonthDates.startDate, end: nextMonthDates.endDate, calendars: [calendar])
                    let events = eventStore.events(matching: predicate)
                    
                    for event in events {
                        let studentName = event.title ?? "NaS"
                        if studentName == "NaS" || studentName == "CSO" || studentName == "CSO Rehearsal" || studentName == "SPC" { continue }
                        
                        let lessonNumberDay = Calendar.current.component(.weekday, from: event.startDate)
                        let durationInMinutes = Int(event.endDate.timeIntervalSince(event.startDate) / 60)
                        let durationString = "\(durationInMinutes)"
                        
                        let eventLocation = event.location ?? "" // Get the event's location or use an empty string if it's nil
         
                        let locationComponents = eventLocation.components(separatedBy: " ")

                        // Take the first three components and join them back into a string
                        let firstThreeWords = locationComponents.prefix(3).joined(separator: " ")
            //            print("first three words \(firstThreeWords)")

                        // Compare the first three words with your desired string
                        if firstThreeWords == "90 Romsey Road" {
                            multiplier = 3
                        } else {
                            multiplier = 1
                        }
       
                        if let lessonTime = event.startDate {
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:"
                            validatedLessonTime = lessonTime
                        }
                        
                        if let firstWord = FromCalendar.getFirstWord(from: studentName) {
                            testWord = firstWord
                        }
                        
                        
                        // Load existing students from the database
                        var existingStudents = DatabaseManager.shared.loadStudents()
                        
                        
                        if let unwrappedNominalLessonDay = FromCalendar.dayName(for: lessonNumberDay) {
                            nominalLessonDay = unwrappedNominalLessonDay
                        }
                        
                        if var existingStudent = DatabaseManager.shared.getStudentByFirstName(testWord), existingStudent.active {
                            let count = existingStudent.lessons.count
                            if DatabaseManager.shared.getStudentByLessonTime(validatedLessonTime) != nil {
                                // Do nothing if the lesson already exists
                            } else {
                                let addedLesson = Student.Lesson(
                                    id: UUID(),
                                    number: String(count + 1),
                                    day: nominalLessonDay,
                                    time: validatedLessonTime,
                                    duration: durationString
                                )
                                existingStudent.lessons.append(addedLesson)
                                DatabaseManager.shared.updateStudent(existingStudent)
                            }
                        } else {
                            // Create a new student
                            let assumedInstrument = determineAssumedInstrument(event)
                            let addedLesson = Student.Lesson(
                                id: UUID(),
                                number: "1",
                                day: nominalLessonDay,
                                time: validatedLessonTime,
                                duration: durationString
                            )
                            let student = Student(
                                studentNumber: "",
                                firstName: testWord,
                                lastName: "",
                                parentsName: "",
                                parentsLastName: "",
                                phoneNumber: "",
                                phoneNumber2: "",
                                street1: "",
                                street2: "",
                                city: "",
                                county: "",
                                country: "UK",
                                postalCode: "",
                                email: "",
                                instrument: assumedInstrument,
                                nominalDay: nominalLessonDay,
                                nominalTime: validatedLessonTime,
                                nominalDuration: durationString,
                                lessons: [addedLesson],
                                kit: [],
                                active: true,
                                multiplier: 1
                            )
                            existingStudents.append(student)
                            DatabaseManager.shared.saveStudents(existingStudents)
                        }
                    }
                } else {
                    print("Calendar not found with identifier: \(calendarIdentifier)")
                }
            } else {
                print("Access to the calendar is not granted.")
            }
        }
    }
    
    // Function to calculate the start and end dates of the next month
    private static func calculateNextMonthDates() -> (startDate: Date, endDate: Date) {
        let currentDate = Date()
        guard let nextMonthStartDate = Calendar.current.date(byAdding: .month, value: 1, to: currentDate) else {
            return (Date(), Date())
        }
        // Get the first day of the next month
        let components = Calendar.current.dateComponents([.year, .month], from: nextMonthStartDate)
        let firstDayOfNextMonth = Calendar.current.date(from: components)
        // Get the first day of the month after next
        let startOfFollowingMonth = Calendar.current.date(byAdding: .month, value: 1, to: firstDayOfNextMonth!)!
        let nextMonthEndDate = Calendar.current.date(byAdding: .day, value: -1, to: startOfFollowingMonth)!
        
        return (firstDayOfNextMonth!, nextMonthEndDate)
    }
    
    func firstDayOfNextMonth() -> Date? {
        let currentDate = Date()
        guard let nextMonthStartDate = Calendar.current.date(byAdding: .month, value: 1, to: currentDate) else {
            return nil
        }
        // Get the first day of the next month
        let components = Calendar.current.dateComponents([.year, .month], from: nextMonthStartDate)
        let firstDayOfNextMonth = Calendar.current.date(from: components)
        return firstDayOfNextMonth
    }
    // Function to determine the assumed instrument from the event
    private static func determineAssumedInstrument(_ event: EKEvent) -> String {
        // Implementation to determine the assumed instrument
        return "Violin" // Default instrument assumed
    }
    
    static func getFirstWord(from inputString: String) -> String? {
        // Trim leading and trailing whitespaces
        let trimmedString = inputString.trimmingCharacters(in: .whitespaces)
        
        // Split the string by whitespaces
        let components = trimmedString.components(separatedBy: .whitespaces)
        
        // Get the first component (word)
        if let firstWord = components.first {
            return firstWord
        }
        
        // Return nil if the input string is empty
        return nil
    }
    
    static func dayName(for dayOfWeek: Int) -> String? {
        guard dayOfWeek >= 1 && dayOfWeek <= 7 else {
            return nil
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "EEEE" // This format returns the full day name
        
        let date = Calendar.current.date(bySetting: .weekday, value: dayOfWeek, of: Date())!
        return dateFormatter.string(from: date)
    }
    
    private static func calculateLessonRate(_ durationString: String) -> Int? {
        // Implementation to calculate the lesson rate based on duration
        // You can use the durationString parameter to determine the rate
        // Return nil if the rate cannot be calculated
        return Int(durationString) // Dummy implementation, replace with actual logic
    }
    
    

    struct PopulateLessonDatabaseFromCalendar {
        
        static func PopulateLessons(headTeacher: HeadTeacher)  {
            let eventStore = EKEventStore()
            var testWord: String = ""
            var calendarIdentifier = ""
         
            let currentDate = Date()
     
            var nextMonthStartDate: Date?
            var nextMonthEndDate: Date?
            // Get the calendar
            let mycalendar = Calendar.current
 
            // Calculate the start of the next month
            if let startOfNextMonth = mycalendar.date(byAdding: .month, value: 1, to: currentDate) {
                // Get the range of the next month
                if let nextMonthRange = mycalendar.range(of: .day, in: .month, for: startOfNextMonth) {
                    // Get the first day of the next month
                    if let firstDayOfNextMonth = mycalendar.date(from: mycalendar.dateComponents([.year, .month], from: startOfNextMonth)) {
                        // Assign the start date
                        nextMonthStartDate = firstDayOfNextMonth
                    }
                    
                    // Get the last day of the next month
                    if let lastDayOfNextMonth = mycalendar.date(byAdding: DateComponents(day: nextMonthRange.count - 1), to: startOfNextMonth) {
                        // Assign the end date
                        nextMonthEndDate = lastDayOfNextMonth
                    }
                }
           }
            
            eventStore.requestAccess(to: .event) { granted, error in
                if granted {
                    // Specify the calendar identifier
                    
                    let calendars = eventStore.calendars(for: .event)
                    for calendar in calendars {
                        if calendar.title == headTeacher.calendarName {
                            calendarIdentifier = calendar.calendarIdentifier
                            
                            if  let nextMonthStartDate = nextMonthStartDate ,  let nextMonthEndDate = nextMonthEndDate {
                                // Create a predicate to filter events within the date range for the specific calendar
                                let predicate = eventStore.predicateForEvents(withStart: nextMonthStartDate, end: nextMonthEndDate, calendars: [calendar])
                                
                                // Fetch events based on the predicate
                                let events = eventStore.events(matching: predicate)
                                for event in events {
                                    guard let existingStudent = DatabaseManager.shared.getStudentByFirstName(testWord),
                                          existingStudent.active,
                                          let studentName = event.title,
                                          !["NaS", "CSO", "CSO Rehearsal", "SPC"].contains(studentName) else {
                                        continue
                                    }
                                        let studentNameComponents = studentName.components(separatedBy: " ")
                                        testWord = String(studentNameComponents[0])
                                        
                                        if var existingStudent = DatabaseManager.shared.getStudentByFirstName(studentName) {
                                            existingStudent.lessons = []
                                        
                                    }
                                }
                                
                                
                                // Process each event and add data to the database
                               
                                for event in events {
                                    populateLessonsFromEvent(event, headTeacher: headTeacher)
                                                            
                                }
                            }
                        }
                        
                        else {
                            // Handle the case where the calendar with the specified identifier is not found
                            print("Calendar not found with identifier: \(calendarIdentifier)")
                        }
                    }
                    
                } else {
                    // Handle the case where access to the calendar is not granted
                    print("Access to the calendar is not granted.")
                }
            }
        }
    }


    private static func populateLessonsFromEvent(_ event: EKEvent, headTeacher: HeadTeacher) {
        // Calculate next month's start and end dates
        let nextMonthDates = calculateNextMonthDates()
            
        
        guard let studentName = event.title,
              let lessonTime = event.startDate,
              let lessonEndTime = event.endDate else {
            print("Error: Unable to extract necessary information from event.")
            return
        }
        guard let eventStartDate = event.startDate,
                      eventStartDate >= nextMonthDates.startDate,
                      eventStartDate < nextMonthDates.endDate else {
                    return // Skip events outside of the next month
                }
                
        // Check if the student name is valid and if the event is within the specified types to consider
        guard !["NaS", "CSO", "CSO Rehearsal", "SPC"].contains(studentName) else {
            return
        }
        
        // Extract other necessary information from the event
        let lessonNumberDay = Calendar.current.component(.weekday, from: lessonTime)
        let durationInMinutes = Int(lessonEndTime.timeIntervalSince(lessonTime) / 60)
        let durationString = "\(durationInMinutes)"
        
        // Determine the assumed instrument for the student
        let assumedInstrument = determineAssumedInstrument(event)
        
        // Get the nominal lesson day from the day of the week
        guard let nominalLessonDay = FromCalendar.dayName(for: lessonNumberDay) else {
            print("Error: Unable to determine nominal lesson day.")
            return
        }
        
   
        // Check if the student already exists in the database
        if var existingStudent = DatabaseManager.shared.getStudentByFirstName(studentName), existingStudent.active {
            // Update the existing student's lessons with the new lesson
            let count = existingStudent.lessons.count + 1
            let addedLesson = Student.Lesson(
                id: UUID(),
                number: String(count),
                day: nominalLessonDay,
                time: lessonTime,
                duration: durationString
            )
            existingStudent.lessons.append(addedLesson)
            DatabaseManager.shared.updateStudent(existingStudent)
        } else {
            // Create a new student and add the lesson
            let addedLesson = Student.Lesson(
                id: UUID(),
                number: "1",
                day: nominalLessonDay,
                time: lessonTime,
                duration: durationString
            )
            let student = Student(
                studentNumber: "",
                firstName: studentName,
                lastName: "",
                parentsName: "",
                parentsLastName: "",
                phoneNumber: "",
                phoneNumber2: "",
                street1: "",
                street2: "",
                city: "",
                county: "",
                country: "UK",
                postalCode: "",
                email: "",
                instrument: assumedInstrument,
                nominalDay: "",
                nominalTime: Date(),
                nominalDuration: "",
                lessons: [addedLesson],
                kit: [],
                active: true,
                multiplier: 1
            )
            
            DatabaseManager.shared.updateStudent(student)
        }
    }

     
    
}


