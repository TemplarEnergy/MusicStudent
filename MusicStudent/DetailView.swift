import SwiftUI

internal struct DetailView: View {

    @StateObject private var viewModel: DetailViewModel // Assuming you create a DetailViewModel

       init(editedStudent: Student) {
           _viewModel = StateObject(wrappedValue: DetailViewModel(editedStudent: editedStudent))
       }
    
    let daysOfWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
    let instruments = ["Violin", "Viola", "Cello", "Voice", "Piano", "Trio", "Ensemble"]
    
    var body: some View {
        VStack {
            Text("\(viewModel.editedStudent.firstName) \(viewModel.editedStudent.lastName)")
            Text("\(viewModel.editedStudent.instrument),  \(viewModel.editedStudent.lessonDay), Active: \(viewModel.editedStudent.active ? "Yes" : "No")")
                .foregroundColor(.gray)
                .font(.footnote)
            Spacer()

            HStack {
                Text("First Name:")
                TextField("Enter First name", text: $viewModel.editedStudent.firstName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Text("Last Name:")
                TextField("Enter Last name", text: $viewModel.editedStudent.lastName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
            }
            HStack {
                Text("Parents Name:")
                TextField("Enter Parents name", text: $viewModel.editedStudent.parentsName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Text("Instrument:")
                Picker("Select", selection: $viewModel.editedStudent.instrument) {
                    ForEach(instruments, id: \.self) {
                        Text($0)
                    }
                }
            }
            HStack {
                Text("Day:")
                Picker("", selection: $viewModel.editedStudent.lessonDay) {
                    ForEach(daysOfWeek, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()

                Text("Lesson Time:")
                DatePicker("", selection: $viewModel.editedStudent.lessonTime, displayedComponents: [.hourAndMinute])
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .padding()

                Text("Duration of Lesson:")
                TextField("Enter Duration of Lesson", text: $viewModel.editedStudent.duration)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
            }
        }
    }
}

internal class DetailViewModel: ObservableObject {
    @Published var editedStudent: Student

    init(editedStudent: Student) {
        self.editedStudent = editedStudent
    }
    
    func submitChangesToDatabase() {
        // Implement your logic to save changes to the database
        // You can use DatabaseManager.shared.saveStudent(editedStudent) or similar
        // Make sure to handle errors and update UI accordingly
    }
}


struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(editedStudent: Student(firstName: "John", lastName: "Doe", parentsName: "Parent", instrument: "Violin", lessonDay: "Monday", lessonTime: Date(), duration: "30", kit: [], active: true))
    }
}
