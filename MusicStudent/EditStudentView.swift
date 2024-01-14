import SwiftUI

internal struct EditStudentView: View {
    let daysOfWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
    let instruments = ["Violin", "Viola", "Cello", "Voice", "Piano", "Trio", "Ensemble"]
    
    @Binding var isSheetPresented: Bool
    @Binding var editedStudent: Student?

    @State private var editedFirstName: String
    @State private var editedLastName: String
    @State private var editedParentName: String
    @State private var editedInstrument: String
    @State private var editedLessonDay: String
    @State private var editedLessonTime: Date
    @State private var editedDuration: String
    @State private var timer: Timer?


    init( isSheetPresented: Binding<Bool>,editedStudent: Binding<Student?>) {
        _editedStudent = editedStudent
        _isSheetPresented = isSheetPresented
        _editedFirstName = State(initialValue: editedStudent.wrappedValue?.firstName ?? "")
        _editedLastName = State(initialValue: editedStudent.wrappedValue?.lastName ?? "")
        _editedParentName = State(initialValue: editedStudent.wrappedValue?.parentsName ?? "")
        _editedInstrument = State(initialValue: editedStudent.wrappedValue?.instrument ?? "")
        _editedLessonDay = State(initialValue: editedStudent.wrappedValue?.lessonDay ?? "")
        _editedLessonTime = State(initialValue: editedStudent.wrappedValue?.lessonTime ?? Date())
        _editedDuration = State(initialValue: editedStudent.wrappedValue?.duration ?? "")
     
    }

    var body: some View {
        NavigationView {
            VStack {
                Text("\(editedFirstName) \(editedLastName)")

                HStack {
                    Text("First Name:")
                    TextField("Enter First name", text: $editedFirstName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()

                    Text("Last Name:")
                    TextField("Enter Last name", text: $editedLastName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                }
                .padding()

                HStack {
                    Text("Parents Name:")
                    TextField("Enter Parents name", text: $editedParentName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()

                    Text("Instrument:")
                    Picker("Select", selection: $editedInstrument) {
                        ForEach(instruments, id: \.self) {
                            Text($0)
                        }
                    }
                }
                .padding()

                HStack {
                    Text("Day:")
                    Picker("", selection: $editedLessonDay) {
                        ForEach(daysOfWeek, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding()

                    DatePicker("", selection: $editedLessonTime, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                                .datePickerStyle(GraphicalDatePickerStyle())
                                .padding()
                                .onChange(of: editedLessonTime) { newDate in
                                    timer?.invalidate() // Invalidate previous timer
                                    timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                                        editedLessonTime = roundTo5Minutes(date: newDate)
                                    }
                                }
                    Text("Duration of Lesson:")
                    TextField("Enter Duration of Lesson", text: $editedDuration)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                }
                .padding()

                HStack {
                    Button("Submit") {
                        if let unwrappedEditedStudent = editedStudent {
                            // Update the properties of the existing student
                            
                            var updatedStudent = unwrappedEditedStudent
                            updatedStudent.firstName = editedFirstName
                            updatedStudent.lastName = editedLastName
                            updatedStudent.parentsName = editedParentName
                            updatedStudent.instrument = editedInstrument
                            updatedStudent.lessonDay = editedLessonDay
                            updatedStudent.lessonTime = editedLessonTime
                            updatedStudent.duration = editedDuration

                            // Assuming you have a method in DatabaseManager to update a student
                            DatabaseManager.shared.updateStudent(updatedStudent)
                        }

                        // Close the sheet or navigate back
                        isSheetPresented = false
                    }
                    .padding()
                    .buttonStyle(ControlButtonStyle(backgroundColor: Color.blue))

                    Button("Cancel") {
                        isSheetPresented = false
                    }
                    .padding()
                    .buttonStyle(ControlButtonStyle(backgroundColor: Color.cyan))
                }
                .padding()
            }
            .onAppear {
                editedFirstName = editedStudent?.firstName ?? ""
                editedLastName = editedStudent?.lastName ?? ""
                editedParentName = editedStudent?.parentsName ?? ""
                editedInstrument = editedStudent?.instrument ?? ""
                editedLessonDay = editedStudent?.lessonDay ?? ""
                editedLessonTime = editedStudent?.lessonTime ?? Date()
                editedDuration = editedStudent?.duration ?? ""
            }
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


struct ControlButtonStyle: ButtonStyle {
    var backgroundColor: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(5)
            .background(backgroundColor)
            .foregroundColor(Color.black)
            .cornerRadius(5)
    }
}

struct EditStudentView_Previews: PreviewProvider {
    @State private static var editedStudent: Student? = Student(
        firstName: "",
        lastName: "",
        parentsName: "",
        instrument: "Violin",
        lessonDay: "Monday",
        lessonTime: Date(),
        duration: "30",
        kit: ["Accessory1", "Accessory2"],
        active: true
    )
    static var previews: some View {
        EditStudentView( isSheetPresented: .constant(false), editedStudent: $editedStudent)
    }
}

