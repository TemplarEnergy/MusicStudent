import SwiftUI
import EventKit
import Foundation


extension Color {
    static let gold = Color(red: 1.0, green: 0.84, blue: 0.0)
    
    static let myYellow = Color(red: 0.5, green: 0.42, blue: 0)
    static let olive = Color(red: 0.5, green: 0.84, blue: 0.5)
    static let beige = Color(red:0.96, green: 0.96, blue: 0.86)
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
}
struct ScrollToTopButton: View {
    var scrollToTop: () -> Void
    
    var body: some View {
        Button("Scroll to Top") {
            scrollToTop()
        }
        .padding()
    }
}


public struct ContentView: View {
    @State private var refreshFlag = false
    @State private var showHeadTeacherInput = false
    @State private var searchQuery: String = ""
    @State private var companyAddress: String = ""
    @StateObject private var presentationManager = PresentationManager()
    @State private var filterOptions = FilterOptionsView.FilterOptions()
    @State private var students: [Student] = []
    @State private var headTeacher: HeadTeacher? = HeadTeacher(
        companyName: "",
        calendarName: "",
        teacherNumber: "",
        firstName: "",
        lastName: "",
        phoneNumber: "",
        phoneNumber2: "",
        street1: "",
        street2: "",
        city: "",
        county: "",
        country: "",
        postalCode: "",
        email: "",
        active: true,
        rate: "",
        payableName: "",
       accountNumber: "",
       sortCode: ""
    )
    @State private var isAddingStudent = false
    @State private var isSheetPresented = false
    @State private var isInvoiceSheetPresented = false
    @State private var selectedStudent: Student?
    @State private var filteredStudents: [Student] = []
    @State private var editedStudent: Student? // Added state for editedStudent
    @State private var scrollOffset: CGFloat = 0.0
    
    private var scrollViewProxy: ScrollViewProxy?
    
    private let eventStore = EKEventStore()
    private var calendarStudents: [Student] = []
    let newStudent = Student(
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
        multiplier: 1.0
    )
    
    
    init() {
        headTeacher = HeadTeacher(
            companyName: "Miss Radford's School of Music",
            calendarName: "",
            teacherNumber: "0",
            firstName: "Annastasia",
            lastName: "Radford",
            phoneNumber: "07722099508",
            phoneNumber2: "02380702415",
            street1: "6 Lordswood Gardens",
            street2: "",
            city: "Southampton", // Corrected spelling
            county: "Hants",
            country: "UK",
            postalCode: "SO16 6RY",
            email: "theviolinchick@hotmail.com",
            active: true,
            rate: "30",
            payableName: "",
           accountNumber: "",
           sortCode: ""
        )
        
        
    }
    
    //  companyAddress = "\(headTeacher.companyName)\n\(headTeacher.street1)\n\(headTeacher.city), \(headTeacher.county)\n\(headTeacher.country)\n\(headTeacher.postalCode)\n\n\(headTeacher.email) "
    let instruments = InstrumentDataManager.shared.loadInstruments()
    //  companyAddress = "\(headTeacher.companyName)\n\(headTeacher.street1)\n\(headTeacher.city), \(headTeacher.county)\n\(headTeacher.country)\n\(headTeacher.postalCode)\n\n\(headTeacher.email)"
    
    public var body: some View {
        NavigationView {
            ScrollViewReader { scrollViewProxy in
                ScrollView([.vertical, .horizontal]) {
                    VStack (){
                        VStack {
                            
                            Text("Miss Radford's School of Music Student Registry")
                                .font(.largeTitle)
                                .background(Color.gold)
                                .padding()
                            FilterOptionsView(
                                filterDay: $filterOptions.filterDay,
                                filterInstrument: $filterOptions.filterInstrument,
                                filterActive: $filterOptions.filterActive
                            )
                            VStack(alignment: .trailing) {
                                HStack {
                                    Spacer()
                                    Spacer()
                                    Button("Admin") {
                                        showHeadTeacherInput.toggle()
                                    }
                                    .padding(.top)
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .sheet(isPresented: $showHeadTeacherInput) {
                                        if let unwrappedHeadTeacher = headTeacher {
                                            HeadTeacherInputView(
                                                showHeadTeacherInput: $showHeadTeacherInput,
                                                headTeacher: Binding(get: { unwrappedHeadTeacher }, set: { newValue in
                                                    headTeacher = newValue
                                                })
                                            )
                                        }
                                    }
                                }
                            }
                            
                        }
                        Button("Generate Invoice") {
                            isInvoiceSheetPresented.toggle()
                        }
                        .padding()
                        .sheet(isPresented: $isInvoiceSheetPresented) {
                            DraggableWindow(isPresented: $isInvoiceSheetPresented) {
                                InvoiceView(
                                    isInvoiceSheetPresented: $isInvoiceSheetPresented,
                                    listStudents: $filteredStudents,
                                    businessAddress: $companyAddress,
                                    headTeacher: $headTeacher,
                                    isSheetPresented: $isSheetPresented
                                )
                            }
                        }
                        
                        
                        ZStack (alignment: .trailing) {
                            
                            TextField("Search Students", text: $searchQuery)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                                .onChange(of: searchQuery) { newValue in
                                    // React to changes in the search query, e.g., update the filtered students
                                    updateFilteredStudents()
                                    
                                }
                            if !searchQuery.isEmpty {
                                Button(action: {
                                    searchQuery = ""
                                    scrollViewProxy.scrollTo(scrollOffset, anchor: .top)
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.secondary)
                                }
                                .padding(.trailing, 8)
                                .padding(.top, 4)
                                
                            }
                        }
                        
                        ForEach(filteredStudents, id: \.id) { student in
                            Button(action: {
                                selectedStudent = student
                                isSheetPresented = true
                                scrollViewProxy.scrollTo(scrollOffset, anchor: .top)
                //                print("Selected Student: \(selectedStudent?.firstName ?? "") \(selectedStudent?.lastName ?? "")")
                            }) {
                                HStack {
                                    Rectangle()
                                        .fill(Color.beige)
                                        .frame(maxWidth: .infinity, minHeight:20, maxHeight: 20) // Adjust the width to your preference
                                        .overlay(
                                            HStack(alignment: .top) {
                                                Text("\(student.firstName) \(student.lastName)")
                                                    .font(.headline)
                                                
                                                Spacer()
                                                
                                                Text("\(student.instrument)")
                                                
                                                
                                                Text("     ")
                                                Text("\(student.nominalDay)")
                                                Text("     ")
                                            }
                                                .background(backgroundForNominalDay(student.nominalDay))
                                                .opacity(0.5)
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
                                scrollViewProxy.scrollTo(scrollOffset, anchor: .top)
                                
                            }
                            .padding()
                            .sheet(isPresented: $isAddingStudent, onDismiss: {
                                loadData()
                            }) {
                                AddStudentView(isAddingStudent: $isAddingStudent, student: newStudent)
                            }
                            
                            Button("Update Database From Calendar") {
                                loadData()
                                if let unwrappedHeadTeacher = headTeacher {
                                    FromCalendar.PopulateStudents(headTeacher: unwrappedHeadTeacher)
                                    _ = FromCalendar.PopulateLessonDatabaseFromCalendar()
                                }
                            }
                            .padding()
                            .sheet(isPresented: $isSheetPresented) {
                                DraggableWindow(isPresented: $isSheetPresented) {
                                    EditStudentView(
                                        isSheetPresented: $isSheetPresented,
                                        editedStudent: $selectedStudent,
                                        businessAddress: $companyAddress,
                                        headTeacher: $headTeacher,
                                        onDismiss: {
                                            // Reload data in ContentView after sheet dismissal
                                            loadData()
                                            scrollViewProxy.scrollTo(scrollOffset, anchor: .top)
                                        }
                                    )
                                    .padding()
                                }
                            }
                        }
                        Spacer()
                /*        ScrollToTopButton {
                            print("Trying to scroll to the top")
                            scrollViewProxy.scrollTo(0, anchor: .top)
                        }*/
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .top)
                    .onAppear {
                        if let loadedData = PlistManager.shared.loadHeadTeacherData()  {
                            headTeacher = loadedData
                        }
                        if let unwrappedHeadTeacher = headTeacher {
                            FromCalendar.PopulateStudents(headTeacher: unwrappedHeadTeacher)
                            _ = FromCalendar.PopulateLessonDatabaseFromCalendar()
                            self.refreshFlag.toggle()
                        }
                        
                        updateCompanyAddress()
                        loadData()
               }
                    .coordinateSpace(name: "scrollToTop")
                    .background(GeometryReader {
                        Color.clear.preference(
                            key: ViewOffsetKey.self,
                            value: -$0.frame(in: .named("scrollToTop")).origin.y
                        )
                    })
                    .onChange(of: filterOptions) { _ in
                        updateFilteredStudents()
                    }
                    
                }
                .frame(minWidth: 600, maxWidth: .infinity, minHeight: 600, maxHeight: .infinity)
                .id(refreshFlag)
                .onPreferenceChange(ViewOffsetKey.self) { offset in
                    scrollOffset = offset
                }
            }
            .onAppear(perform: checkCalendarAccess)
            
        }
        
        
    }
    
    private func backgroundForNominalDay(_ nominalDay: String) -> Color {
            switch nominalDay.lowercased() {
            case "monday":
                return Color.purple
            case "tuesday":
                return Color.blue
            case "wednesday":
                return Color.green
            case "thursday":
                return Color.yellow
            case "friday":
                return Color.orange
            default:
                return Color.teal
            }
        }
    
    private var invoiceButtonAction: () -> Void {
        // Define the action to show the invoice view
        return {
            // Prepare data for the invoice (you can replace these with actual data)
            //        let teacherAddress = "Teacher's Address\nCity, Country"
            let studentAddress = "Student's Address\nCity, Country"
            let lessonDate = Date()
            let lessonDuration = "60" // Assuming 60 minutes for the example
            let lessonFee = "$50.00" // Assuming $50.00 for the example
            let kitItems = ["Kit Item 1", "Kit Item 2"] // Replace with actual kit items
            
            // Present the invoice view
            presentationManager.showInvoiceView(
                businessAddress: companyAddress,
                studentAddress: studentAddress,
                lessonDate: lessonDate,
                lessonDuration: lessonDuration,
                lessonFee: lessonFee,
                kitItems: kitItems
            )
        }
    }
    
    private func checkCalendarAccess() {
        DispatchQueue.main.async {
            self.requestCalendarAccess { granted in
                if granted {
                    // Access granted, proceed with fetching events or other actions
                    //     self.populateDatabaseFromCalendar()
                } else {
                    // Inform the user that access is needed
                    print("Calendar access is required.")
                }
            }
        }
    }
    
    private func updateCompanyAddress() {
        if let unwrappedHeadTeacher = headTeacher {
            companyAddress = "\(unwrappedHeadTeacher.companyName)\n\(unwrappedHeadTeacher.street1)\n\(unwrappedHeadTeacher.city), \(unwrappedHeadTeacher.county)\n\(unwrappedHeadTeacher.country)\n\(unwrappedHeadTeacher.postalCode)\n\n\(unwrappedHeadTeacher.email)"
        } else {
            companyAddress = "Default Company Address"
        }
    }
    
    
    
    func loadData() {
        
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
    
    
    
    private func updateFilteredStudents() {
        // Define the order of days of the week
        let dayOrder: [String: Int] = [
            "Monday": 1,
            "Tuesday": 2,
            "Wednesday": 3,
            "Thursday": 4,
            "Friday": 5,
            "Saturday": 6,
            "Sunday": 7
        ]
        
        // Filter and sort the students
        filteredStudents = students.filter { student in
            // Apply the filter conditions
            let dayFilterPass = filterOptions.filterDay == nil || student.nominalDay == filterOptions.filterDay
            let instrumentFilterPass = filterOptions.filterInstrument == nil || student.instrument == filterOptions.filterInstrument
            let activeFilterPass = filterOptions.filterActive == nil || student.active == filterOptions.filterActive
            let searchFilterPass = searchQuery.isEmpty || "\(student.firstName) \(student.lastName)".lowercased().contains(searchQuery.lowercased())
            
            return dayFilterPass && instrumentFilterPass && activeFilterPass && searchFilterPass
        }.sorted { student1, student2 in
            // Ensure both students have a nominalDay property
         let day1 = student1.nominalDay
            let day2 = student2.nominalDay
            
            // Get the numerical order of the days
            guard let order1 = dayOrder[day1], let order2 = dayOrder[day2] else {
                // Handle the case where the day of the week is not recognized
                return false
            }
            
            if order1 != order2 {
                // If the days are different, sort based on their numerical order
                return order1 < order2
            } else {
                        // If the days are the same, sort based on the lesson time
                        
                        // Extract the time components from nominalTime
                        let calendar = Calendar.current
                        let time1 = calendar.component(.hour, from: student1.nominalTime) * 60 + calendar.component(.minute, from: student1.nominalTime)
                        let time2 = calendar.component(.hour, from: student2.nominalTime) * 60 + calendar.component(.minute, from: student2.nominalTime)
                        
                        // Compare the time components
                        return time1 < time2
                    }
        }
    }

    
}

struct ViewOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct DraggableWindow<Content: View>: View {
    @Binding var isPresented: Bool
    var content: () -> Content
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            content()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
        .offset(y: isPresented ? 0 : (NSScreen.main?.visibleFrame.height ?? 0))
        .animation(.default, value: isPresented)
    }
}



