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
    static func PopulateStudents(headTeacher: HeadTeacher)  {
        
        let eventStore = EKEventStore()
        var testWord: String = ""
        var nominalLessonDay: String = ""
        var validatedLessonTime: Date = Date()
        var locationComponents: [String]?
        var calendarIdentifier = ""
        var multipler = 1
        var intRate = 0
        var addedLesson: Student.Lesson = Student.Lesson(
            id: UUID(),
            number: "1",
            day: "",
            time: Date(),
            duration: "",
            price: ""
        )
        
        
        var titleComponents: [String]?
        
        var assumedInstrument: String = "Violin"
        
        eventStore.requestAccess(to: .event) { granted, error in
            if granted {
                // Specify the calendar identifier
                let calendars = eventStore.calendars(for: .event)
                for calendar in calendars {
                    //            print("Calendar: \(calendar.title), Identifier: \(calendar.calendarIdentifier)")
                    //           print("I'm looking for \(headTeacher.calendarName)")
                    if calendar.title == headTeacher.calendarName{
                        calendarIdentifier = calendar.calendarIdentifier
                    }
                }
                
                // Get the specific calendar using its identifier
                if let calendar = eventStore.calendar(withIdentifier: calendarIdentifier) {
                    // Set up the date range for which you want to fetch events
                    let startDate = Date()
                    let endDate = Calendar.current.date(byAdding: .month, value: 1, to: startDate)!
                    
                    // Create a predicate to filter events within the date range for the specific calendar
                    let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: [calendar])
                    
                    // Fetch events based on the predicate
                    let events = eventStore.events(matching: predicate)
                    
                    
                    
                    // Process each event and add data to the database
                    for event in events {
                        // Assuming the student's name is the first word in the event title
                        let studentName = event.title ?? "NaS"
                        if studentName == "NaS" || studentName == "CSO" || studentName == "CSO Rehearsal" || studentName == "SPC" { continue }
                        
                        let lessonNumberDay = Calendar.current.component(.weekday, from: event.startDate)
                        let durationInMinutes = Int(event.endDate.timeIntervalSince(event.startDate) / 60)
                        let durationString = "\(durationInMinutes)"
                        multipler = 1
                        if let unwrappedRate = Int(Rates.rateTable(duration: durationString)) {
                            intRate = unwrappedRate * multipler
                        }
                        if let lessonTime = event.startDate {
                            // Now you can use `lessonTime` as a non-optional `Date`
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd            HH:mm:"
                            
                            validatedLessonTime =  lessonTime
                            //                print("Event start date and time: \(validatedLessonTime)")
                            
                            // ... rest of your code ...
                        }
                        
                        if let firstWord = getFirstWord(from: studentName) {
                            testWord = firstWord
                        }
                        // Check if a student with the same first name and is active already exists in the database
                        
                        //          print("SOMEHOW i've mised  \(studentName)")
                        var components = event.title.components(separatedBy: " ")
                        
                        
                        // Rest of your logic...
                        if let unwrappedLocComp = event.location?.components(separatedBy: " ") {
                            let unwrappedLocCompCount = unwrappedLocComp.count
                            if unwrappedLocCompCount >= 3 {
                                let loc1 = unwrappedLocComp[0]
                                let loc2 = unwrappedLocComp[1]
                                let loc3 = unwrappedLocComp[2]
                                let loc123 = ("\(loc1) \(loc2) \(loc3)")
                                multipler =  Rates.mulitplier(location: loc123)
                            }
                            
                        }
                        // set location to the location of the event
                        if let locationComponents = locationComponents, locationComponents.count >= 1 {
                            let testNote = String(locationComponents[0]).capitalizingFirstLetter()
                            if   InstrumentDataManager.shared.loadInstruments().contains(testNote) {
                                assumedInstrument = testNote
                            }
                        }
                        
                        // Set title to the name of the event
                        if let title = event.title {
                            titleComponents = title.components(separatedBy: " ")
                        }
                        
                        // debug prent statment
                        let studentNameComponents = studentName.components(separatedBy: " ")
                        if studentNameComponents[0] == "Edward" {
                            //                       print("hey i'm on edward and debugginh")
                        }
                        
                        // Test to see if the Lesson location is present. if it is, check to see if an insturment is mentioned
                        if let locationComponents = locationComponents, locationComponents.count >= 1 {
                            let testNote = String(locationComponents[0]).capitalizingFirstLetter()
                            if  InstrumentDataManager.shared.loadInstruments().contains(testNote) {
                                assumedInstrument = testNote
                            }
                        }
                        // Test to see if the Lesson name is more the the student. if it is, check to see if an insturment is mentioned
                        if let titleComponents = titleComponents, titleComponents.count > 1  {
                            let testTitle = String(titleComponents[0]).capitalizingFirstLetter()
                            if   InstrumentDataManager.shared.loadInstruments().contains(testTitle) {
                                assumedInstrument = testTitle
                            }
                        }
                        
                        testWord = studentNameComponents[0]
                        //     studentNameComponents.removeFirst() // Remove the first word
                        components = []
                        
                        components.append(testWord)
                        // Now, updatedStudentName contains the second word if it's "online" or "cello"
                        //               print("Updated Student Name: \(testWord)")
                        
                        if let wrappedNominalLessonDay = dayName(for: lessonNumberDay) {
                            nominalLessonDay = wrappedNominalLessonDay
                        }
                        // Load existing students from the database
                        var existingStudents = DatabaseManager.shared.loadStudents()
                        
                        if var existingStudent = DatabaseManager.shared.getStudentByFirstName(testWord),
                           existingStudent.active {
                            // Student already exists and is active, skip adding personal info
                            // Will add additional lesson times if appropriate
                            let count = existingStudent.lessons.count
                            if DatabaseManager.shared.getStudentByLessonTime(validatedLessonTime) != nil {
                                //                    print("found existing lesson \(validatedLessonTime)")
                            } else {
                                //                   print("the count of lessons is \(count)")
                                addedLesson.number = String(count + 1)
                                addedLesson.duration = durationString
                                addedLesson.day = nominalLessonDay
                                addedLesson.time = validatedLessonTime
                                addedLesson.duration = durationString
                                if let unwrappedRate = Int(Rates.rateTable(duration: durationString)) {
                                    intRate = unwrappedRate * multipler
                                }
                                
                                addedLesson.price = String(intRate)
                                //      addedLessonElement.append(addedLesson)
                                existingStudent.lessons.append(addedLesson)
                                
                                DatabaseManager.shared.updateStudent(existingStudent)
                                
                                multipler = 1
                                
                            }
                        }
                        else {
                            if studentNameComponents.first != nil {
                                addedLesson.duration  = durationString
                                addedLesson.number  = "1"
                                addedLesson.day = nominalLessonDay
                                addedLesson.time = validatedLessonTime
                                addedLesson.duration = durationString
                                if let unwrappedRate = Int(Rates.rateTable(duration: durationString)) {
                                    intRate = unwrappedRate * multipler
                                }
                                
                                addedLesson.price = String(intRate)
                                // Create a Student object and add it to the database
                                let student = Student(
                                    studentNumber: "",
                                    firstName: testWord,
                                    lastName: "",
                                    parentsName: "",  // You may need to extract this from the event as well
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
                                    active: true
                                )
                                
                                multipler = 1
                                
                                // Append the new student to the existing list
                                existingStudents.append(student)
                                //            print("I'm at the breaking point")
                                DatabaseManager.shared.saveStudents(existingStudents)
                            }
                            
                            Task {
                                await MainActor.run {
                                    let contentView = ContentView()
                                    contentView.loadData()
                                }
                            }
                            
                            
                        }
                    }
                }
                else {
                    // Handle the case where the calendar with the specified identifier is not found
                    print("Calendar not found with identifier: \(calendarIdentifier)")
                }
                
            }else {
                // Handle the case where access to the calendar is not granted
                print("Access to the calendar is not granted.")
            }
            
        }
    }

       
    
    
    static func PopulateLessons(headTeacher: HeadTeacher)  {
        let eventStore = EKEventStore()
        var testWord: String = ""
        var nominalLessonDay: String = ""
        var validatedLessonTime: Date = Date()
        var calendarIdentifier = ""
        var multipler = 1
        var intRate = 0
        let blankLesson: Student.Lesson = Student.Lesson(
            id: UUID(),
            number: "1",
            day: "",
            time: Date(),
            duration: "",
            price: ""
        )
        var addedLesson: Student.Lesson = blankLesson
        let currentDate = Date()
        var startDate: Date?
        var endDate: Date?
        
     
                eventStore.requestAccess(to: .event) { granted, error in
                    if granted {
                        // Specify the calendar identifier
                        
                        let calendars = eventStore.calendars(for: .event)
                        for calendar in calendars {
        //                    print("Calendar: \(calendar.title), Identifier: \(calendar.calendarIdentifier)")
          //                  print("I'm looking for \(headTeacher.calendarName)")
                            if calendar.title == headTeacher.calendarName {
                                calendarIdentifier = calendar.calendarIdentifier
                            }
                        }
                        
                        // Get the specific calendar using its identifier
                        if let calendar = eventStore.calendar(withIdentifier: calendarIdentifier) {
                            // Set up the date range for which you want to fetch events
                            
                            // Calculate the start of the next month
                            if let calculatedStartDate = Calendar.current.date(bySetting: .day, value: 1, of: Calendar.current.date(byAdding: .month, value: 1, to: currentDate)!) {
                                startDate = calculatedStartDate
                                endDate = Calendar.current.date(byAdding: .month, value: 1, to: startDate!)
                            } else {
            //                    print("Error calculating start of next month")
                                return
                            }
                            if  let startDate = startDate ,  let endDate = endDate {
                                // Create a predicate to filter events within the date range for the specific calendar
                                let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: [calendar])
                                
                                // Fetch events based on the predicate
                                let events = eventStore.events(matching: predicate)
                                for event in events {
                                    if let existingStudent = DatabaseManager.shared.getStudentByFirstName(testWord),
                                       existingStudent.active {
                                        var studentName = event.title ?? "NaS"
                                        if studentName == "NaS" || studentName == "CSO" || studentName == "CSO Rehearsal" || studentName == "SPC" { continue }
                                        let studentNameComponents = studentName.components(separatedBy: " ")
                                        testWord = String(studentNameComponents[0])
                                        studentName = testWord
                                        if var existingStudent = DatabaseManager.shared.getStudentByFirstName(testWord) {
                                            existingStudent.lessons = []
                                        }
                                    }
                                }
                                
                                
                                // Process each event and add data to the database
                                for event in events {
                                    if var existingStudent = DatabaseManager.shared.getStudentByFirstName(testWord),
                                       existingStudent.active {
                                        var studentName = event.title ?? "NaS"
                                        if studentName == "NaS" || studentName == "CSO" || studentName == "CSO Rehearsal" || studentName == "SPC" { continue }
                                        let studentNameComponents = studentName.components(separatedBy: " ")
                                        testWord = String(studentNameComponents[0])
                                        studentName = testWord
                                        if var existingStudent = DatabaseManager.shared.getStudentByFirstName(testWord) {
                                            existingStudent.lessons = []
                                        }
                                        // Assuming the student's name is the first word in the event title
                                        
                                        let lessonNumberDay = Int(Calendar.current.component(.weekday, from: event.startDate))
                                        let durationInMinutes = Int(event.endDate.timeIntervalSince(event.startDate) / 60)
                                        let durationString = "\(durationInMinutes)"
                                        multipler = 1
                                        if let unwrappedRate = Int(Rates.rateTable(duration: durationString)) {
                                            intRate = unwrappedRate * multipler
                                        }
                                        if let lessonTime = event.startDate {
                                            // Now you can use `lessonTime` as a non-optional `Date`
                                            let dateFormatter = DateFormatter()
                                            dateFormatter.dateFormat = "yyyy-MM-dd            HH:mm:"
                                            validatedLessonTime =  lessonTime
                    //                        print("Event start date and time: \(validatedLessonTime)")
                                        }
                                        if let unwrappedLocComp = event.location?.components(separatedBy: " ") {
                                            let unwrappedLocCompCount = unwrappedLocComp.count
                                            if unwrappedLocCompCount >= 3 {
                                                let loc1 = unwrappedLocComp[0]
                                                let loc2 = unwrappedLocComp[1]
                                                let loc3 = unwrappedLocComp[2]
                                                let loc123 = ("\(loc1) \(loc2) \(loc3)")
                                                multipler =  Rates.mulitplier(location: loc123)
                                            }
                                            
                                        }
                                        
                                        if let wrappedNominalLessonDay = dayName(for: lessonNumberDay) {
                                            nominalLessonDay = wrappedNominalLessonDay
                                        }
                                        // Will add additional lesson times if appropriate
                                        let count = existingStudent.lessons.count
                                        if DatabaseManager.shared.getStudentByLessonTime(validatedLessonTime) != nil {
                      //                      print("found existing lesson \(validatedLessonTime)")
                                        } else {
                     //                       print("the count of lessons is \(count)")
                                            addedLesson.number = String(count + 1)
                                            addedLesson.duration = durationString
                                            addedLesson.day = nominalLessonDay
                                            addedLesson.time = validatedLessonTime
                                            addedLesson.duration = durationString
                                            if let unwrappedRate = Int(Rates.rateTable(duration: durationString)) {
                                                intRate = unwrappedRate * multipler
                                            }
                                            
                                            addedLesson.price = String(intRate)
                                            //      addedLessonElement.append(addedLesson)
                                            existingStudent.lessons.append(addedLesson)
                                            
                                            DatabaseManager.shared.updateStudent(existingStudent)
                                            
                                            multipler = 1
                                            
                                        }
                                    }
                                }
                            }
                        }
                        
                        else {
                            // Handle the case where the calendar with the specified identifier is not found
                            print("Calendar not found with identifier: \(calendarIdentifier)")
                        }
                        
                    }else {
                        // Handle the case where access to the calendar is not granted
                        print("Access to the calendar is not granted.")
                    }
                    
                }
            }
        
    }
    
    

    
    func getFirstWord(from inputString: String) -> String? {
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
    
    func dayName(for dayOfWeek: Int) -> String? {
        guard dayOfWeek >= 1 && dayOfWeek <= 7 else {
            return nil
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "EEEE" // This format returns the full day name
        
        let date = Calendar.current.date(bySetting: .weekday, value: dayOfWeek, of: Date())!
        return dateFormatter.string(from: date)
    }
    


