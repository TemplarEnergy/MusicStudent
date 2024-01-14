import SwiftUI

struct TestContentView: View {
    @State private var filterOptions = FilterOptionsView.FilterOptions()
    @State private var students: [Student] = []

    var body: some View {
        VStack {
            FilterOptionsView(
                filterDay: $filterOptions.filterDay,
                filterInstrument: $filterOptions.filterInstrument,
                filterActive: $filterOptions.filterActive
            )

            Button("Print Filtered Students") {
          //      updateFilteredStudents()
            }
        }
        .onAppear {
            loadData()
        }
    }

    private func loadData() {
        // Load some test students
        students = [
            Student(firstName: "John", lastName: "Doe", parentsName: "bill", instrument: "Violin", lessonDay: "Monday", lessonTime: Date(), duration: "30", kit: ["dog"], active: true),
            Student(firstName: "Jane", lastName: "Doe", parentsName: "bill",  instrument: "Piano", lessonDay: "Tuesday", lessonTime: Date(), duration: "30", kit: ["dog"], active: true),
            // Add more test students...
        ]
    }
/*
    private func updateFilteredStudents() {
        let filtered = students.filter { student in
            let dayFilterPass = filterOptions.filterDay == nil || student.lessonDay == filterOptions.filterDay
            let instrumentFilterPass = filterOptions.filterInstrument == nil || student.instrument == filterOptions.filterInstrument
            let activeFilterPass = filterOptions.filterActive == nil || student.active == filterOptions.filterActive
            return dayFilterPass && instrumentFilterPass && activeFilterPass
        }

        print("Filtered Students: \(filtered)")
    }

    private func updateFilteredStudents() {
        filteredStudents = students.filter { student in
            let dayFilterPass = filterOptions.filterDay == nil || student.lessonDay == filterOptions.filterDay
            let instrumentFilterPass = filterOptions.filterInstrument == nil || student.instrument == filterOptions.filterInstrument
            let activeFilterPass = filterOptions.filterActive == nil || student.active == filterOptions.filterActive

            // Log the filtering criteria and results
            print("Filtering \(student.firstName): day \(dayFilterPass), instrument \(instrumentFilterPass), active \(activeFilterPass)")

            return dayFilterPass && instrumentFilterPass && activeFilterPass
        }
        print("Filtered Students: \(filteredStudents)")
    }
 */
    
}


struct TestContentView_Previews: PreviewProvider {
    static var previews: some View {
        TestContentView()
    }
}

