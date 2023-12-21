import SwiftUI

struct ContentView: View {
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var parentsName = ""
    @State private var selectedInstrument = "Violin"
    @State private var selectedDay = "Monday"
    @State private var lessonTime = Date()
    @State private var duration = "30"
    @State private var kit = [String]()

    @Binding var selectedUser: User?
    @Binding var users: [User]

    let daysOfWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
    let instruments = ["Violin", "Viola", "Cello", "Voice", "Piano", "Trio", "Ensemble"]

    var body: some View {
        VStack {
            HStack {
                Text("First Name:")
                TextField("Enter First name", text: Binding(get: {
                    selectedUser?.firstName ?? ""
                }, set: {
                    selectedUser?.firstName = $0
                }))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

                Text("Last Name:")
                TextField("Enter Last name", text: Binding(get: {
                    selectedUser?.lastName ?? ""
                }, set: {
                    selectedUser?.lastName = $0
                }))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            }
            HStack {
                Text("Parents Name:")
                TextField("Enter Parents name", text: Binding(get: {
                    selectedUser?.parentsName ?? ""
                }, set: {
                    selectedUser?.parentsName = $0
                }))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

                Text("Instrument:")
                Picker("Select", selection: Binding(get: {
                    selectedUser?.instrument ?? ""
                }, set: {
                    selectedUser?.instrument = $0
                })) {
                    ForEach(instruments, id: \.self) {
                        Text($0)
                    }
                }
            }
            HStack {
                Text("Select Day of Lesson:")
                Picker("", selection: Binding(get: {
                    selectedUser?.lessonDay ?? ""
                }, set: {
                    selectedUser?.lessonDay = $0
                })) {
                    ForEach(daysOfWeek, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()

                Text("Lesson Time:")
                DatePicker("", selection: Binding(get: {
                    selectedUser?.lessonTime ?? Date()
                }, set: {
                    selectedUser?.lessonTime = $0
                }), displayedComponents: [.hourAndMinute])
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding()

                Text("Duration of Lesson:")
                TextField("Enter Duration of Lesson", text: Binding(get: {
                    selectedUser?.duration ?? ""
                }, set: {
                    selectedUser?.duration = $0
                }))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            }
            if selectedUser == nil {
                Button("Submit") {
                    submitButtonClicked()
                }
                .padding()
            } else {
                Button("Update") {
                    updateButtonClicked()
                }
                .padding()
            }
        }
    }

    private func updateButtonClicked() {
        guard let selectedUser = selectedUser else {
            return
        }

        // Find the index of the selected user in the array
        if let index = users.firstIndex(where: { $0.id == selectedUser.id }) {
            // Update the selected user's information
            users[index].firstName = selectedUser.firstName
            users[index].lastName = selectedUser.lastName
            users[index].parentsName = selectedUser.parentsName
            users[index].instrument = selectedUser.instrument
            users[index].lessonDay = selectedUser.lessonDay
            users[index].lessonTime = selectedUser.lessonTime
            users[index].duration = selectedUser.duration
            users[index].kit = selectedUser.kit

            // Write the updated array back to the JSON database
            writeToJSON(data: users)
        }

        // Clear the fields after updating
        clearFields()
        clearUser()
    }

    private func submitButtonClicked() {
        guard !firstName.isEmpty else {
            showAlert(message: "Please enter a student name.")
            return
        }

        let user = User(
            firstName: firstName,
            lastName: lastName,
            parentsName: parentsName,
            instrument: selectedInstrument,
            lessonDay: selectedDay,
            lessonTime: lessonTime,
            duration: duration,
            kit: kit
        )

        self.users.append(user)
        writeToJSON(data: self.users)
        clearFields()
        clearUser()
    }

    private func writeToJSON(data: [User]) {
        do {
            let jsonData = try JSONEncoder().encode(data)

            if let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("student_database.json") {
                try jsonData.write(to: fileURL)
            }
        } catch {
            print("Error writing to JSON: \(error.localizedDescription)")
        }
    }

    private func clearFields() {
        firstName = ""
        lastName = ""
        parentsName = ""
        selectedInstrument = "Violin"
        selectedDay = "Monday"
        lessonTime = Date()
        duration = "30"
        kit = []
    }
    private func clearUser() {
        selectedUser = nil
    }

    private func showAlert(message: String) {
        let alert = NSAlert()
        alert.messageText = "Error"
        alert.informativeText = message
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(selectedUser: .constant(nil), users: .constant([]))
    }
}

