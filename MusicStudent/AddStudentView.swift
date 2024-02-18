// AddStudentView.swift
import SwiftUI
import Foundation




struct AddStudentView: View {
    @Binding var isAddingStudent: Bool
    @State var isSubmitButtonPressed: Bool = false
    @State var isCancelButtonPressed: Bool = false
    @State private var student: Student
    @State private var selectedDate = Date()
    @State private var timer: Timer?
    @State private var textStudentNumber: String = ""
    @State private var maxStudentNumber: Int = 0
    @State private var tempLesson: Lesson = Lesson()  // Assuming Lesson has a default initializer
    private var updatedStudent: Student? = Student(
        studentNumber: "",
        firstName: "",
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
        instrument: "Violin",
        nominalDay: "",
        nominalTime: Date(),
        nominalDuration: "",
        lessons: [
            Student.Lesson(number: "2", day: "Wednesday", time: Date(), duration: "60")
        ],
        kit: [],
        active: true,
        multiplier: 1
    )
    
    struct Lesson: Identifiable, Equatable, Codable {
        var id = UUID()
        var number: String = ""
        var day: String = ""
        var time: Date = Date()
        var duration: String = ""
        var price: String = ""
    }
    
    
    init(isAddingStudent: Binding<Bool>, student: Student) {
        _isAddingStudent = isAddingStudent
        _student = State(initialValue: updatedStudent ?? student)
    }
    
    let daysOfWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
    let instruments = InstrumentDataManager.shared.loadInstruments()
    
    var body: some View {
        VStack{
            
            VStack {
                Text("\(student.firstName) \(student.lastName)")
                Text("Instrument: \(student.instrument), Day: \(student.nominalDay), Active: \(student.active ? "Yes" : "No")")
                    .foregroundColor(.gray)
                    .font(.footnote)
                Spacer()
                HStack {
                    
                    Text("Permanent Student Number:")
                    TextField("Enter Student Number", text: $textStudentNumber, onCommit: {
                        // Add the kitItem to the list when the user presses enter
                        print("I've madie it to the on Commit")
                        guard let validatedStudentNumber = Int(textStudentNumber) else {
                            // Handle invalid student number input (show an alert, etc.)
                            print("I've fell in the validatedstudentnumber")
                            return
                        }
                        // Set the student number
                        maxStudentNumber = max(maxStudentNumber, validatedStudentNumber)
                    })
                    .frame(width: 60)
                    .onAppear {
                        // Load existing students and find the max student number
                        print("I've madie it to the appear")
                        let students = DatabaseManager.shared.loadStudents()
                        print("I've made it past the load")
                        maxStudentNumber = students.compactMap { Int($0.studentNumber) }.max() ?? 0
                        print("i've found out the max student number")
                        // Set the default student number to be one more than the max
                        textStudentNumber = "\(maxStudentNumber + 1)"
                    }
                }
                HStack {
                    Text("First Name:")
                    TextField("Enter First name", text: $student.firstName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    Text("Last Name:")
                    TextField("Enter Last name", text: $student.lastName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                }
                HStack {
                    Text("Parents Name:")
                    TextField("Enter Parents name", text: $student.parentsName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    Text("Parents Last Name:")
                    TextField("Enter Parents Last name", text: $student.parentsLastName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    Text("Instrument:")
                    Picker("Select", selection: $student.instrument) {
                        ForEach(instruments, id: \.self) {
                            Text($0)
                        }
                    }
                }
                HStack {
                    Text("Select Day of Lesson:")
                    Picker("", selection: $student.lessons[0].day) {
                        ForEach(daysOfWeek, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding()
                    
                    Text("Lesson Time:")
                    DatePicker("", selection: $student.lessons[0].time, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .padding()
                        .onChange(of: student.lessons[0].time) { newDate in
                            timer?.invalidate() // Invalidate previous timer
                            timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                                student.lessons[0].time = roundTo5Minutes(date: newDate)
                                student.nominalTime = roundTo5Minutes(date: newDate)
                            }
                        }
                    Text("Duration of Lesson:")
                    TextField("Enter Duration of Lesson", text: $student.lessons[0].duration)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                }
                
                HStack{
                    VStack {
                        
                        Text("Address:")
                        TextField("Enter Street", text: $student.street1)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        TextField("Enter Alt Street", text: $student.street2)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                        TextField("Enter City", text: $student.city)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                        TextField("County", text: $student.county)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                        TextField("Country", text: $student.country)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                        TextField("Post Code", text: $student.postalCode)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                    }
                    VStack{
                        
                        Text("Email:")
                        TextField("Enter Email", text: $student.parentsName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                        
                        Text("Phone Number:")
                        TextField("Enter Phone Number", text: $student.parentsLastName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                        
                        Text("Alt Phone Number:")
                        TextField("Enter Alt Phone Number", text: $student.parentsLastName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                    }
                    
                }
                HStack{
                    Button("Add New Student to Database") {
                        // Create a new student using the current state
                        let newStudent = Student(
                            studentNumber: student.studentNumber,
                            firstName: student.firstName,
                            lastName: student.lastName,
                            parentsName: student.parentsName,
                            parentsLastName: student.parentsLastName,
                            phoneNumber:  student.phoneNumber,
                            phoneNumber2:  student.phoneNumber,
                            street1:  student.street1,
                            street2: student.street2,
                            city:  student.city,
                            county: student.county,
                            country:  student.country,
                            postalCode:  student.postalCode,
                            email: student.email,
                            instrument: student.instrument,
                            nominalDay: student.nominalDay,
                            nominalTime: student.nominalTime,
                            nominalDuration: student.nominalDuration,
                            lessons: student.lessons,
                            kit: student.kit,
                            active: student.active,
                            multiplier: 1
                        )
                        
                        // Load existing students from the database
                        var existingStudents = DatabaseManager.shared.loadStudents()
                        
                        // Append the new student to the existing list
                        existingStudents.append(newStudent)
                        
                        // Save the updated list back to the database
                        DatabaseManager.shared.saveStudents(existingStudents)
                        
                        // Dismiss the sheet or perform any other actions if needed
                        isAddingStudent = false
                    }
                    .buttonStyle(ControlButtonStyle(backgroundColor: isCancelButtonPressed ? .olive : .green))
                    
                    Button("Cancel") {
                        isAddingStudent = false
                    }
                    .padding()
                    .cornerRadius(15)
                    .buttonStyle(ControlButtonStyle(backgroundColor: isCancelButtonPressed ? .gold : .yellow))
                    
                }
            }
            .padding()
        }
        
    }
}




private func roundTo5Minutes(date: Date) -> Date {
    let calendar = Calendar.current
    let components = calendar.dateComponents([.hour, .minute], from: date)
    
    let hour = components.hour ?? 0
    let minute = components.minute ?? 0
    var roundedMinute = 0
    
    switch minute {
    case ..<3:
        roundedMinute = 0
    case ..<8:
        roundedMinute = 5
    case ..<13:
        roundedMinute = 10
    case ..<18:
        roundedMinute = 15
    case ..<23:
        roundedMinute = 20
    case ..<28:
        roundedMinute = 25
    case ..<33:
        roundedMinute = 30
    case ..<38:
        roundedMinute = 35
    case ..<43:
        roundedMinute = 40
    case ..<48:
        roundedMinute = 45
    case ..<53:
        roundedMinute = 50
    default:
        roundedMinute = 55
        
    }
    print("the rounded minutes is \(roundedMinute)")
    print("the calendar time is \(calendar.date(bySettingHour: hour, minute: roundedMinute, second: 0, of: date) ?? date)")
    return calendar.date(bySettingHour: hour, minute: roundedMinute, second: 0, of: date) ?? date
}




struct AddStudentView_Previews: PreviewProvider {
    static var previews: some View {
        AddStudentView(isAddingStudent: .constant(false), student: Student(
            studentNumber: "",
            firstName: "",
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
            instrument: "Violin",
            nominalDay: "",
            nominalTime: Date(),
            nominalDuration: "",
            lessons: [],
            kit: [],
            active: true,
            multiplier: 1
        ))
    }
}

