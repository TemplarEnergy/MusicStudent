import SwiftUI
import EventKit
import Foundation

extension Color {
    static let gold = Color(red: 1.0, green: 0.84, blue: 0.0)
    
    static let myYellow = Color(red: 0.5, green: 0.42, blue: 0)
    static let olive = Color(red: 0.5, green: 0.84, blue: 0.5)
}

public struct ContentView: View {
    @State private var filterOptions = FilterOptionsView.FilterOptions()
    @State private var students: [Student] = []
    @State private var isAddingStudent = false
    @State private var isSheetPresented = false
    @State private var selectedStudent: Student?
    @State private var filteredStudents: [Student] = []
    @StateObject private var presentationManager = PresentationManager()
    private let eventStore = EKEventStore()
    private var calendarStudents: [Student] = []
    
    @State private var editedStudent: Student? // Added state for editedStudent
    let newStudent = Student(
        firstName: "",
        lastName: "",
        parentsName: "",
        instrument: "Violin",
        lessonDay: "Monday",
        lessonTime: Date(),
        duration: "30",
        kit: ["", ""],
        active: true
    )
    public var body: some View {
        NavigationView {
            ScrollView([.vertical, .horizontal]) { // Wrap
                VStack (){
                    Text("Miss Radford's School of Music Student Registry")
                        .font(.largeTitle)
                        .background(Color.gold)
                        .padding()
                    
                    
                    FilterOptionsView(
                        filterDay: $filterOptions.filterDay,
                        filterInstrument: $filterOptions.filterInstrument,
                        filterActive: $filterOptions.filterActive
                    )
                    ForEach(filteredStudents, id: \.id) { student in
                        Button(action: {
                            selectedStudent = student
                            isSheetPresented = true
                        }) {
                            HStack {
                                Rectangle()
                                    .fill(Color.teal)
                                    .frame(maxWidth: .infinity, minHeight:20, maxHeight: 20) // Adjust the width to your preference
                                    .overlay(
                                        HStack(alignment: .top) {
                                            Text("\(student.firstName) \(student.lastName)")
                                                .font(.headline)
                                            
                                            Spacer()
                                            
                                            Text("\(student.instrument)")
                                            
                                            
                                            Text("     ")
                                            Text("\(student.lessonDay)")
                                            Text("     ")
                                        }
                                            .padding([.leading, .trailing], 10)
                                    )
                            }
                            .padding(.bottom, 2)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .foregroundColor(.black)
                    }
                    
                    HStack {
                        Button("Add New Student") {
                            isAddingStudent = true
                        }
                        .padding()
                        .sheet(isPresented: $isAddingStudent, onDismiss: {
                            loadData()
                        }) {
                            AddStudentView(isAddingStudent: $isAddingStudent, student: newStudent)
                        }
                        
                        
                        Button("Update Students") {
                            loadData()
                        }
                        .padding()
                        .sheet(isPresented: $isSheetPresented, onDismiss: {
                            loadData()
                        }) {
                            EditStudentView(isSheetPresented: $isSheetPresented, editedStudent: $selectedStudent)
                        }
                        .padding()
                    }
                    .onAppear {
                        
                        loadData()
                        populateDatabaseFromCalendar()
                    }
                    Spacer()
                    
                }
                .onChange(of: filterOptions) { _ in
                    updateFilteredStudents()
                }
            }
        }
        .onAppear(perform: checkCalendarAccess)
        
    }
    
    private func checkCalendarAccess() {
        DispatchQueue.main.async {
            self.requestCalendarAccess { granted in
                if granted {
                    // Access granted, proceed with fetching events or other actions
                    self.populateDatabaseFromCalendar()
                } else {
                    // Inform the user that access is needed
                    print("Calendar access is required.")
                }
            }
        }
    }

    
    private func loadData() {
        
        students = DatabaseManager.shared.loadStudents()
        updateFilteredStudents()
    }
    
    
    
    private func requestCalendarAccess(completion: @escaping (Bool) -> Void) {
        let eventStore = EKEventStore()
        
        switch EKEventStore.authorizationStatus(for: .event) {
        case .authorized:
            // The app has permission to access the calendar
            completion(true)
        case .denied:
            // The app doesn't have permission; inform the user to grant access in settings
            completion(false)
        case .notDetermined:
            // Request permission
            eventStore.requestAccess(to: .event) { granted, error in
                completion(granted)
            }
        case .restricted:
            // The app is restricted from accessing the calendar
            completion(false)
        @unknown default:
            // Handle any future cases
            completion(false)
        }
    }
    
    
    
    
    private func populateDatabaseFromCalendar() {
        let eventStore = EKEventStore()
        var testWord: String = ""
        
        // Request access to the calendar
        eventStore.requestAccess(to: .event) { granted, error in
            if granted {
                // Specify the calendar identifier
                let calendarIdentifier = "3CBA0B2A-12FC-478E-8568-E000BFFD320F"
                
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
                        if studentName == "NaS" { continue }
                        let lessonNumberDay = Calendar.current.component(.weekday, from: event.startDate)
                        let lessonTime = event.startDate
                        let durationInMinutes = Int(event.endDate.timeIntervalSince(event.startDate) / 60)
                        let durationString = "\(durationInMinutes) mins"
                        if let firstWord = getFirstWord(from: studentName) {
                            testWord = firstWord
                        }
                        // Check if a student with the same first name and is active already exists in the database
                        if let existingStudent = DatabaseManager.shared.getStudentByFirstName(testWord),
                           existingStudent.active {
                            // Student already exists and is active, skip adding
                           
                                   continue
                        }
                        print("SOMEHOW i've mised  \(studentName)")
                            let lessonDay = dayName(for: lessonNumberDay) // Returns "Monday"}
                            let components = event.title.components(separatedBy: " ")
                            if let studentName = components.first {
                                // Create a Student object and add it to the database
                                let student = Student(
                                    firstName: studentName,
                                    lastName: "",
                                    parentsName: "",  // You may need to extract this from the event as well
                                    instrument: "",  // You may need to extract this from the event as well
                                    lessonDay: lessonDay!,  // You may need to extract this from the event as well
                                    lessonTime: event.startDate,
                                    duration: "",  // You may need to extract this from the event as well
                                    kit: [],
                                    active: true
                                )
                                
                                // Load existing students from the database
                                var existingStudents = DatabaseManager.shared.loadStudents()

                                // Append the new student to the existing list
                                existingStudents.append(student)

                                // Save the updated list back to the database
                                DatabaseManager.shared.saveStudents(existingStudents)// Add the student to the database
                                loadData()                        }
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
        
        
        private func updateFilteredStudents() {
            filteredStudents = students.filter { student in
                let dayFilterPass = filterOptions.filterDay == nil || student.lessonDay == filterOptions.filterDay
                let instrumentFilterPass = filterOptions.filterInstrument == nil || student.instrument == filterOptions.filterInstrument
                let activeFilterPass = filterOptions.filterActive == nil || student.active == filterOptions.filterActive
                return dayFilterPass && instrumentFilterPass && activeFilterPass
            }
        }
    }
    
    private func fetchEventsFromCalendar() {
        let eventStore = EKEventStore()
        
        // Rest of your code to fetch events and update the database
        // ...
    }
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
    
    
    
    
