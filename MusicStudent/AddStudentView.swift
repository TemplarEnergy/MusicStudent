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


    init(isAddingStudent: Binding<Bool>, student: Student) {
          _isAddingStudent = isAddingStudent
          _student = State(initialValue: student)
      }

    let daysOfWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
    let instruments = ["Violin", "Viola", "Cello", "Voice", "Piano", "Trio", "Ensemble"]

    var body: some View {
        VStack {
            Text("\(student.firstName) \(student.lastName)")
            Text("Instrument: \(student.instrument), Day: \(student.lessonDay), Active: \(student.active ? "Yes" : "No")")
                .foregroundColor(.gray)
                .font(.footnote)
            Spacer()

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

                Text("Instrument:")
                Picker("Select", selection: $student.instrument) {
                    ForEach(instruments, id: \.self) {
                        Text($0)
                    }
                }
            }
            HStack {
                Text("Select Day of Lesson:")
                Picker("", selection: $student.lessonDay) {
                    ForEach(daysOfWeek, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()

                Text("Lesson Time:")
                DatePicker("", selection: $student.lessonTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .padding()
                            .onChange(of: student.lessonTime) { newDate in
                                timer?.invalidate() // Invalidate previous timer
                                timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                                    student.lessonTime = roundTo5Minutes(date: newDate)
                                }
                            }
                Text("Duration of Lesson:")
                TextField("Enter Duration of Lesson", text: $student.duration)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
            }
            HStack{
            Button("Add New Student to Database") {
                           // Create a new student using the current state
                           let newStudent = Student(
                               firstName: student.firstName,
                               lastName: student.lastName,
                               parentsName: student.parentsName,
                               instrument: student.instrument,
                               lessonDay: student.lessonDay,
                               lessonTime: student.lessonTime,
                               duration: student.duration,
                               kit: student.kit,
                               active: student.active
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
            
            Button("Cancel") {
                isAddingStudent = false
            }
            .padding()
            .cornerRadius(15)
            .buttonStyle(ControlButtonStyle(backgroundColor: isCancelButtonPressed ? .cyan : .blue))
                
            }
            .padding()
        }
        .padding()
        
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
            firstName: "",
            lastName: "",
            parentsName: "",
            instrument: "Violin",
            lessonDay: "Monday",
            lessonTime: Date(),
            duration: "30",
            kit: ["", ""],
            active: true
        ))
    }
}

