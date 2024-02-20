import SwiftUI
import Contacts
import AppKit



struct EditStudentView: View {
    @Binding var isSheetPresented: Bool
    @Binding var editedStudent: Student?
    @Binding var businessAddress: String
    @Binding var headTeacher: HeadTeacher?
    
    
    @State private var editedStudentNumber: String
    @State private var editedFirstName: String
    @State private var editedLastName: String
    @State private var editedParentName: String
    @State private var editedParentsLastName: String
    @State private var editedPhoneNumber: String
    @State private var editedPhoneNumber2: String
    @State private var editedStreet1: String
    @State private var editedStreet2: String
    @State private var editedCity: String
    @State private var editedCounty: String
    @State private var editedCountry: String
    @State private var editedPostalCode: String
    @State private var editedEmail: String
    @State private var editedInstrument: String
    @State private var editedNominalLessonDay: String
    @State private var editedNominalLessonTime: Date
    @State private var editedNominalLessonDuration: String
    @State private var editedLessons: [Student.Lesson]
    @State private var editedKit: [Student.KitItem]
    @State private var editedActive: Bool
    @State private var editedMultiplier: Int
    
    @State private var timer: Timer?
    @State private var showKitAlert = false
    @State private var showStudentAlert = false
    @State private var showLessonAlert = false
    @State private var kitItemName: String = ""
    @State private var kitItemPrice: String = "" // A
    @State private var kitItemStatus: String = "" // Assuming the price is a string, you can adjust this based on your data type
    @State private var textStudentNumber: String = ""
    @State private var inScopeStudentNumber: Int = 0
    
    @State private var selectedKitItemIndex: Int?
    @State private var kitItems: [Student.KitItem] = []
    @State private var kitItem: String = ""
    
    @State private var selectedLessonIndex: Int?
    @State private var lessons: [Student.Lesson] = []
    @State private var lesson: String = ""
    
    
    @State private var isInvoiceSheetPresented = false
    @State private var listStudents: [Student] = []
    
    
    
    let daysOfWeek = HeadTeacher.daysOfWeek
    let instruments  = InstrumentDataManager.shared.loadInstruments()
    let status = HeadTeacher.extraItemStatus
    
    //  private var perseverantStudent: Student
    private var store = CNContactStore()
    private let calendar = Calendar.current
    private var firstDayOfCurrentMonth: Date {
        return calendar.startOfDay(for: Date())
    }
    private var firstDayOfPrecedingMonth: Date {
        return calendar.date(byAdding: .month, value: -1, to: firstDayOfCurrentMonth) ?? Date()
    }
    var onDeleteKitItem: (() -> Void)?
    var onDeleteLesson: (() -> Void)?
    var onDismiss: (() -> Void)? // Add this property
    
    init(
        isSheetPresented: Binding<Bool>,
        editedStudent: Binding<Student?>,
        businessAddress: Binding<String>,
        headTeacher: Binding<HeadTeacher?>, // Change this to Binding<HeadTeacher?>
        onDeleteKitItem: (() -> Void)? = nil,
        onDeleteLesson: (() -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        _editedStudent = editedStudent
        _businessAddress = businessAddress
        _isSheetPresented = isSheetPresented
        self._headTeacher = headTeacher
        _editedStudentNumber = State(initialValue: editedStudent.wrappedValue?.studentNumber ?? "")
        _editedFirstName = State(initialValue: editedStudent.wrappedValue?.firstName ?? "")
        _editedLastName = State(initialValue: editedStudent.wrappedValue?.lastName ?? "")
        _editedParentName = State(initialValue: editedStudent.wrappedValue?.parentsName ?? "")
        _editedParentsLastName = State(initialValue: editedStudent.wrappedValue?.parentsLastName ?? "")
        _editedPhoneNumber = State(initialValue: editedStudent.wrappedValue?.phoneNumber ?? "")
        _editedPhoneNumber2 = State(initialValue: editedStudent.wrappedValue?.phoneNumber2 ?? "")
        _editedStreet1 = State(initialValue: editedStudent.wrappedValue?.street1 ?? "")
        _editedStreet2 = State(initialValue: editedStudent.wrappedValue?.street2 ?? "")
        _editedCity = State(initialValue: editedStudent.wrappedValue?.city ?? "")
        _editedCounty = State(initialValue: editedStudent.wrappedValue?.county ?? "")
        _editedCountry = State(initialValue: editedStudent.wrappedValue?.country ?? "")
        _editedPostalCode = State(initialValue: editedStudent.wrappedValue?.postalCode ?? "")
        _editedEmail  = State(initialValue: editedStudent.wrappedValue?.email ?? "")
        _editedInstrument = State(initialValue: editedStudent.wrappedValue?.instrument ?? "")
        _editedNominalLessonDay = State(initialValue: editedStudent.wrappedValue?.nominalDay ?? "") // Assuming there's at least one lesson
        _editedNominalLessonTime = State(initialValue: editedStudent.wrappedValue?.nominalTime ?? Date()) // Assuming there's at least one lesson
        _editedNominalLessonDuration = State(initialValue: editedStudent.wrappedValue?.nominalDuration ?? "")
        _editedLessons = State(initialValue: editedStudent.wrappedValue?.lessons ?? [])
        _editedKit = State(initialValue: editedStudent.wrappedValue?.kit ?? [])
        _editedActive = State(initialValue: editedStudent.wrappedValue?.active ?? true)
        _editedMultiplier = State(initialValue: editedStudent.wrappedValue?.multiplier ?? 1)
        
        self.onDeleteKitItem = onDeleteKitItem
        self.onDeleteLesson = onDeleteLesson
        self.onDismiss = onDismiss
        
    }
    
    func deleteKitItem(at index: Int) {
        guard index < editedKit.count else {
            return
        }
        // Remove the kit item from editedKit
        editedKit.remove(at: index)
        
        // Reindex the items in case of multiple deletions
        reindexKitItems()
        // Notify the parent view about the kit item deletion
        onDeleteKitItem?()
    }
    
    func deleteLesson(at index: Int) {
        guard index < editedLessons.count else {
            return
        }
        
        
        // Remove the kit item from editedKit
        editedLessons.remove(at: index)
        
        // Reindex the items in case of multiple deletions
        reindexLessons()
        // Notify the parent view about the kit item deletion
        onDeleteLesson?()
    }
    
    
    func reindexKitItems() {
        for (index, _) in kitItems.enumerated() {
            kitItems[index].id = UUID() // Assuming 'id' is a property of type UUID in Student.KitItem
        }
    }
    
    func reindexLessons() {
        for (index, _) in lessons.enumerated() {
            kitItems[index].id = UUID() // Assuming 'id' is a property of type UUID in Student.KitItem
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                
                    VStack {
                        Text("\(editedStudent?.firstName ?? "")  \(editedLastName)")
                        .font(.title)
                            .padding()
                        HStack {
                           
                            Toggle("Active", isOn: $editedActive)
                            Spacer()
                            Text("Permanent Student Number:")
                            TextField("Enter PSN", text:  $editedStudentNumber)
                                .modifier(CustomTextFieldStyle(backgroundColor: Color.red, pad: 5))
                                .foregroundColor(Color.black)
                                .frame(width: 60)
                            
                         
                        }
                        HStack {
                            Text("First Name:")
                            TextField("Enter First name", text: $editedFirstName)
                                .frame(width: 200)
                                .modifier(CustomTextFieldStyle(backgroundColor: Color.olive, pad: 5))
                            Text("Last Name:")
                            TextField("Enter Last name", text: $editedLastName)
                                .modifier(CustomTextFieldStyle(backgroundColor: Color.olive, pad: 5))
                                .frame(width: 200)
                        }
                        .padding()
                        
                        HStack {
                            Text("Parents Name:")
                            TextField("Enter Parents name", text: $editedParentName)
                                .modifier(CustomTextFieldStyle(backgroundColor: Color.olive, pad: 5))
                                .frame(width: 200)
                            Text("Parents Last Name:")
                            TextField("Enter Parents Last name", text: $editedParentsLastName)
                                .modifier(CustomTextFieldStyle(backgroundColor: Color.olive, pad: 5))
                                .frame(width: 200)
                        }
                        HStack {
                            Text("Instrument:")
                            Picker("", selection: $editedInstrument) {
                                ForEach(instruments, id: \.self) {
                                    Text($0)
                                    
                                }
                            }
                                .modifier(CustomTextFieldStyle(backgroundColor: Color.olive, pad: 5))
                                .frame(width: 200)
                        }
                        .padding()
                        
                        HStack {
                            Text("Day:")
                            Picker("", selection: $editedNominalLessonDay) {
                                ForEach(daysOfWeek, id: \.self) {
                                    Text($0)
                                    
                                }
                            }
                            .modifier(CustomTextFieldStyle(backgroundColor: Color.olive, pad: 5))
                            .frame(width: 150)
                            .pickerStyle(MenuPickerStyle())
                            .padding()
                            DatePicker("", selection: $editedNominalLessonTime, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                                .datePickerStyle(GraphicalDatePickerStyle())
                                .padding()
                                .onChange(of: editedNominalLessonTime) { newDate in
                                    timer?.invalidate() // Invalidate previous timer
                                    timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                                        editedNominalLessonTime = roundTo5Minutes(date: newDate)
                                    }
                                }
                                .frame(width: 150)
                            Text("Duration of Lesson:")
                            TextField("Enter Duration of Lesson", text: $editedNominalLessonDuration)
                                .modifier(CustomTextFieldStyle(backgroundColor: Color.olive, pad: 5))
                                .frame(width: 100)
                        }
                        .padding()
                        
                        HStack{
                            VStack {
                                Text("Address:")
                                TextField("Enter Street", text: $editedStreet1)
                                    .modifier(CustomTextFieldStyle(backgroundColor: Color.olive, pad: 0))
                                    .frame(width: 200)
                                TextField("Enter Alt Street", text: $editedStreet2)
                                    .modifier(CustomTextFieldStyle(backgroundColor: Color.olive, pad: 0))
                                    .frame(width: 200)
                                TextField("Enter City", text: $editedCity)
                                    .modifier(CustomTextFieldStyle(backgroundColor: Color.olive, pad: 0))
                                    .frame(width: 200)
                                TextField("County", text: $editedCounty)
                                    .modifier(CustomTextFieldStyle(backgroundColor: Color.olive, pad: 0))
                                    .frame(width: 200)
                                TextField("Country", text: $editedCountry)
                                    .modifier(CustomTextFieldStyle(backgroundColor: Color.olive, pad: 0))
                                    .frame(width: 200)
                                TextField("Post Code", text: $editedPostalCode)
                                    .modifier(CustomTextFieldStyle(backgroundColor: Color.olive, pad: 0))
                                    .frame(width: 200)
                            }
                            VStack{
                                Text("Email:")
                                TextField("Enter Email", text: $editedEmail)
                                    .modifier(CustomTextFieldStyle(backgroundColor: Color.olive, pad: 5))
                                    .frame(width: 200)
                                Text("Phone Number:")
                                TextField("Enter Phone Number", text: $editedPhoneNumber)
                                    .modifier(CustomTextFieldStyle(backgroundColor: Color.olive, pad: 5))
                                    .frame(width: 200)
                                Text("Alt Phone Number:")
                                TextField("Enter Alt Phone Number", text: $editedPhoneNumber2)
                                    .modifier(CustomTextFieldStyle(backgroundColor: Color.olive, pad: 5))
                                    .frame(width: 200)
                                    .foregroundColor(Color.black)
                            }
                        }
                        .padding()
                        VStack {
                            ForEach(editedLessons.indices, id: \.self) { index in
                                VStack {
                                    HStack(alignment: .top) {
                                        VStack(alignment: .leading) {
                                            Text("Lesson")
                                                .frame(width: 80, alignment: .leading)
                                        }
                                        .padding(.leading, 10)
                                        .padding(.trailing, 10)
                                        VStack(alignment: .leading) {
                                            Text( "\(editedLessons[index].day)")
                                                .foregroundColor(.secondary)
                                                .frame(width: 80, alignment: .leading)
                                        }
                                        .padding(.leading, 10)
                                        .padding(.trailing, 10)
                                        VStack(alignment: .leading) {
                                            Text( "\(formattedDate(editedLessons[index].time))")
                                                .foregroundColor(.secondary)
                                                .frame(width: 150, alignment: .leading)
                                        }
                                        .padding(.leading, 10)
                                        .padding(.trailing, 10)
                                        VStack(alignment: .leading) {
                                            Text( "\(editedLessons[index].duration) minutes")
                                                .foregroundColor(.secondary)
                                                .frame(width: 80, alignment: .leading)
                                        }
                                        .padding(.leading, 10)
                                        .padding(.trailing, 10)
                                        VStack{
                                            Text(" ")
                                        }
                                        VStack(alignment: .leading) {
                                            Text(findRate(duration: editedLessons[index].duration, multiplier: editedMultiplier))
                                                .foregroundColor(.secondary)
                                                .frame(width: 40, alignment: .leading)
                                        }
                                        .padding(.leading, 10)
                                        .padding(.trailing, 10)
                                        
                                        // Delete button
                                        Button("Delete") {
                                            selectedLessonIndex = index
                                            showLessonAlert = true // Trigger confirmation alert
                                        }
                                        .frame(width: 70, alignment: .leading)
                                        
                                       
                                    }
                                    .buttonStyle(ControlButtonStyle(backgroundColor: Color.red))
                                    .alert(isPresented: $showLessonAlert) {
                                        Alert(
                                            title: Text("Confirm Deletion"),
                                            message: Text("Are you sure you want to delete this Lesson? This change is only for this session. For a permanent change remove Lesson for calendar"),
                                            primaryButton: .destructive(Text("Delete")) {
                                                // Call your delete function here
                                                deleteLesson(at: selectedLessonIndex ?? 0)
                                                if let unwrappedEditedStudent = editedStudent {
                                                    // Update the properties of the existing student
                                                    let updatedStudent = unwrappedEditedStudent
                                                    DatabaseManager.shared.updateStudent(updatedStudent)
                                                }
                                                selectedLessonIndex = nil // Reset the selected index
                                            },
                                            
                                            secondaryButton: .cancel()
                                        )
                                    }
                                }
                            }
                        }
                    }
             //       .padding(30)
                    HStack {
                        
                        TextField("Enter Extra Item", text: $kitItemName)
                            .modifier(CustomTextFieldStyle(backgroundColor: Color.olive, pad: 5))
                            .frame(width: 400)
                        TextField("Enter Item's Price", text: $kitItemPrice)
                            .modifier(CustomTextFieldStyle(backgroundColor: Color.olive, pad: 5))
                            .frame(width: 150)
                       
                        
                        Button("Add Item") {
                            // Add the new kit item
                            //     if let price = Double(kitItemPrice) {
                            let newItem = Student.KitItem(name: kitItemName, date: Date(), price: kitItemPrice, status:  kitItemStatus)
                            kitItems.append(newItem)
                            editedKit.append(newItem)
                            kitItemName = "" // Clear the text field
                            kitItemPrice = "" // Clear the price field
                            kitItemStatus = "" // Clear the price field
                            
                        }
                        .buttonStyle(ControlButtonStyle(backgroundColor: Color.olive))
                        
                        
                    }
             //       .padding(30)
                    
                    // Display the kit items
                    VStack(spacing: 10) {
                        ForEach(editedKit.indices, id: \.self) { index in
                            HStack(alignment: .top) {
                                VStack(alignment: .leading) {
                                    Text(editedKit[index].name)
                                        .frame(width: 110, alignment: .leading)
                                        .font(.caption)
                                }
                                Spacer()
                                VStack(alignment: .leading) {
                                    Text("Date: \(formattedDate(editedKit[index].date))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .frame(width: 130, alignment: .leading)
                                }
                                Spacer()
                                VStack(alignment: .leading) {
                                    Text("\(editedKit[index].price)")
                                        .frame(width: 80, alignment: .trailing)
                                        .font(.caption)
                                }
                               
                                
                                // Delete button
                                Button("Delete") {
                                    selectedKitItemIndex = index
                                    showKitAlert = true // Trigger confirmation alert
                                }
                                .font(.caption)
                                .buttonStyle(ControlButtonStyle(backgroundColor: Color.red))
                                .alert(isPresented: $showKitAlert) {
                                    Alert(
                                        title: Text("Confirm Deletion"),
                                        message: Text("Are you sure you want to delete this Item?"),
                                        primaryButton: .destructive(Text("Delete")) {
                                            // Call your delete function here
                                            deleteKitItem(at: selectedKitItemIndex ?? 0)
                                            if let unwrappedEditedStudent = editedStudent {
                                                // Update the properties of the existing student
                                                
                                                var updatedStudent = unwrappedEditedStudent
                                                updatedStudent.kit = editedKit
                                                DatabaseManager.shared.updateStudent(updatedStudent)
                                            }
                                            selectedKitItemIndex = nil // Reset the selected index
                                        },
                                        
                                        secondaryButton: .cancel()
                                    )
                                }
                                
                                
                                
                            }
                        }
                    }
               //     .padding(30)
                    .frame(minHeight: 50) // Adjust the height as needed
                    
                    Button("Generate Invoice PDF") {
                        print("\(editedStudent?.firstName ?? "")  is the students first name")
                        if let unwrappedEditedStudent = editedStudent {var updatedStudent = unwrappedEditedStudent
                            updatedStudent.studentNumber = editedStudentNumber
                            updatedStudent.firstName = editedFirstName
                            updatedStudent.lastName = editedLastName
                            updatedStudent.parentsName = editedParentName
                            updatedStudent.parentsLastName = editedParentsLastName
                            updatedStudent.phoneNumber =  editedPhoneNumber
                            updatedStudent.phoneNumber2 =  editedPhoneNumber2
                            updatedStudent.street1 =  editedStreet1
                            updatedStudent.street2 = editedStreet2
                            updatedStudent.city =  editedCity
                            updatedStudent.county = editedCounty
                            updatedStudent.country =  editedCountry
                            updatedStudent.postalCode =  editedPostalCode
                            updatedStudent.email  = editedEmail
                            updatedStudent.instrument = editedInstrument
                            updatedStudent.nominalDay = editedNominalLessonDay
                            updatedStudent.nominalTime = editedNominalLessonTime
                            updatedStudent.nominalDuration = editedNominalLessonDuration
                            updatedStudent.lessons = editedLessons
                            updatedStudent.active = editedActive
                            updatedStudent.kit = editedKit
                            DatabaseManager.shared.updateStudent(updatedStudent)
                            listStudents.append(updatedStudent)                        }
                        //          listStudents.append(editedStudent?)
                        //       }
                        isInvoiceSheetPresented.toggle()
                    }
                    .buttonStyle(ReversedControlButtonStyle(foregroundColor: Color.green))
                    .sheet(isPresented: $isInvoiceSheetPresented) {
                        InvoiceView(
                            isInvoiceSheetPresented: $isInvoiceSheetPresented,
                            listStudents: $listStudents,
                            businessAddress: $businessAddress,
                            headTeacher: $headTeacher,
                            isSheetPresented: $isSheetPresented
                        )
                    }
                    HStack {
                        Button("Submit") {
                            
                            if let unwrappedEditedStudent = editedStudent {
                                // Update the properties of the existing student
                                
                                var updatedStudent = unwrappedEditedStudent
                                updatedStudent.studentNumber = editedStudentNumber
                                updatedStudent.firstName = editedFirstName
                                updatedStudent.lastName = editedLastName
                                updatedStudent.parentsName = editedParentName
                                updatedStudent.parentsLastName = editedParentsLastName
                                updatedStudent.phoneNumber =  editedPhoneNumber
                                updatedStudent.phoneNumber2 =  editedPhoneNumber2
                                updatedStudent.street1 =  editedStreet1
                                updatedStudent.street2 = editedStreet2
                                updatedStudent.city =  editedCity
                                updatedStudent.county = editedCounty
                                updatedStudent.country =  editedCountry
                                updatedStudent.postalCode =  editedPostalCode
                                updatedStudent.email  = editedEmail
                                updatedStudent.instrument = editedInstrument
                                updatedStudent.nominalDay = editedNominalLessonDay
                                updatedStudent.nominalTime = editedNominalLessonTime
                                updatedStudent.nominalDuration = editedNominalLessonDuration
                                updatedStudent.lessons = editedLessons
                                updatedStudent.active = editedActive
                                updatedStudent.kit = editedKit
                                print("hey ho")
                                print("Updated Student: \(updatedStudent) in scope number  \(inScopeStudentNumber)")
                                DatabaseManager.shared.updateStudent(updatedStudent)
                            }
                            
                            // Close the sheet or navigate back
                            isSheetPresented = false
                        }
                        .padding()
                        .buttonStyle(ControlButtonStyle(backgroundColor: Color.olive))
                        
                        Button("Cancel") {
                            isSheetPresented = false
                        }
                        .padding()
                        .buttonStyle(ControlButtonStyle(backgroundColor: Color.gold))
                        Button("Delete Student") {
                            showStudentAlert = true
                            
                        }
                        .buttonStyle(ControlButtonStyle(backgroundColor: Color.red))
                        // Confirmation Alert
                        .alert(isPresented: $showStudentAlert) {
                            Alert(
                                title: Text("Confirm Deletion"),
                                message: Text("Are you sure you want to delete this Student? For a permanent removal remove student from Calendar entries"),
                                primaryButton: .destructive(Text("Delete")) {
                                    // Call your delete function hereif let unwrappedEditedStudent = editedStudent {
                                    // Update the properties of the existing student
                                    if let unwrappedEditedStudent = editedStudent {
                                        let updatedStudent = unwrappedEditedStudent
                                        DatabaseManager.shared.deleteStudent(updatedStudent)
                                        isSheetPresented = false
                                    }
                                },
                                
                                secondaryButton: .cancel()
                            )
                        }
                    
                }
                
              //  .padding(30)
            }
            .frame(minWidth: 600, maxWidth: .infinity, minHeight: 1000, maxHeight: .infinity )
            .padding(30)
            
        }
    
    
        .onAppear {
            
            if let window = NSApp.mainWindow {
                configureWindow(window)
            }
            DispatchQueue.main.async {
                editedStudentNumber = editedStudent?.studentNumber ?? ""
                editedFirstName = editedStudent?.firstName ?? ""
                editedLastName = editedStudent?.lastName ?? ""
                editedParentName = editedStudent?.parentsName ?? ""
                editedParentsLastName = editedStudent?.parentsLastName ?? ""
                editedPhoneNumber = editedStudent?.phoneNumber ?? ""
                editedPhoneNumber2 = editedStudent?.phoneNumber2 ?? ""
                editedStreet1 = editedStudent?.street1 ?? ""
                editedStreet2 = editedStudent?.street2 ?? ""
                editedCity = editedStudent?.city ?? ""
                editedCounty = editedStudent?.county ?? ""
                editedCountry = editedStudent?.country ?? ""
                editedPostalCode = editedStudent?.postalCode ?? ""
                editedEmail = editedStudent?.email ?? ""
                editedInstrument = editedStudent?.instrument ?? ""
                editedNominalLessonDay = editedStudent?.nominalDay ?? ""
                editedNominalLessonTime = editedStudent?.nominalTime ?? Date()
                editedNominalLessonDuration = editedStudent?.nominalDuration ?? ""
                editedLessons  = editedStudent?.lessons ?? []
                editedKit = editedStudent?.kit ?? []
                editedActive = editedStudent?.active ?? true
                if (editedStudent?.firstName) != nil {
                    //    let ReturnedEditedKit = filterKitItemsForCurrentAndPrecedingMonths(kitItems)
                    
                    //    print("Inside kitItems: \(kitItems)")
                }
            }
        }
        .navigationTitle("") // Empty navigation title
}

func filterKitItemsForCurrentAndPrecedingMonths(_ kitItems: [Student.KitItem]) -> [Student.KitItem] {
    let currentDate = Date()
    let calendar = Calendar.current
    
  //  print("I am in the filter kit current date \(currentDate)")
    // Get the date components for the current month
    let currentMonthComponents = calendar.dateComponents([.year, .month], from: currentDate)
    
    // Calculate the first day of the current month
    guard let firstDayOfCurrentMonth = calendar.date(from: currentMonthComponents) else {
        return []
    }
    
    // Calculate the first day of the preceding month
    guard let firstDayOfPrecedingMonth = calendar.date(byAdding: .month, value: -1, to: firstDayOfCurrentMonth) else {
        return []
    }
    
    // Filter kit items for the current and preceding months
    let filteredKitItems = kitItems.filter { kitItem in
        return kitItem.date >= firstDayOfPrecedingMonth && kitItem.date <= currentDate
    }
    
    
    return filteredKitItems
}
    func findRate(duration: String, multiplier: Int) -> String {
        var priceText = ""
        if let price = LessonRateManager.shared.findLessonDurationRate(duration: duration, multiplier: editedMultiplier) {
            if var proRatedPrice = Double(price) {
             //   proRatedPrice *= Double(multiplier)
                priceText = String(format: "%.2f", proRatedPrice)
            }
            else {
                
                priceText = "£\(price)"
            }
            
        }
        else {
             priceText = "£0.00"
        }
        return priceText
    }
    
func formattedDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter.string(from: date)
}

private func configureWindow(_ window: NSWindow) {
    window.titleVisibility = .hidden
    window.titlebarAppearsTransparent = true
    window.isMovableByWindowBackground = true
    window.standardWindowButton(.zoomButton)?.isHidden = false
    window.standardWindowButton(.miniaturizeButton)?.isHidden = false
    window.standardWindowButton(.closeButton)?.isHidden = false
}

func fetchContactInfo(completion: @escaping () -> Void) {
    store.requestAccess(for: .contacts) { granted, error in
        guard granted else {
            print("Access to contacts denied.")
            return
        }
        print("I am looking for the street \(self.editedStreet1) and also  the postcode  \(self.editedPostalCode) = address.postalCode")
        let lastNameToSearch = editedParentsLastName
        
        do {
            let keysToFetch: [CNKeyDescriptor] = [
                CNContactGivenNameKey as CNKeyDescriptor,
                CNContactFamilyNameKey as CNKeyDescriptor,
                CNContactPhoneNumbersKey as CNKeyDescriptor,
                CNContactEmailAddressesKey as CNKeyDescriptor,
                CNContactPostalAddressesKey as CNKeyDescriptor
            ]
            
            let predicate = CNContact.predicateForContacts(matchingName: lastNameToSearch)
            
            print("for the lastname \(lastNameToSearch) the predicate is \(predicate) ")
            
            let contacts = try store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch)
            
            if let contact = contacts.first(where: { $0.familyName == lastNameToSearch }) {
                // Access the contact information
                let phoneNumbers = contact.phoneNumbers.map { $0.value.stringValue }
                if let firstPhoneNumber = phoneNumbers.first {
                    self.editedPhoneNumber = firstPhoneNumber
                }
                
                let emailAddresses = contact.emailAddresses.map { $0.value as String }
                if let firstEmailAddress = emailAddresses.first {
                    self.editedEmail = firstEmailAddress
                }
                
                let addresses = contact.postalAddresses.map { $0.value }
                for address in addresses {
                    editedStreet1 = address.street
                    editedStreet2 = address.subAdministrativeArea
                    editedCity = address.city
                    editedCounty = address.state
                    editedCountry = address.country
                    editedPostalCode = address.postalCode
                }
                
            }
            completion()
        } catch {
            print("Error fetching contacts: \(error)")
        }
    }
}

private func onDelete() {
    // Ensure editedStudent is not nil before attempting to delete
    guard let studentToDelete = editedStudent else {
        print("Error: editedStudent is nil.")
        return
    }
    
    // Remove the student from your data source or perform the deletion logic
    // For example, assuming you have a function in DatabaseManager to delete a student
    DatabaseManager.shared.deleteStudent(studentToDelete)
    
    // Dismiss the sheet (assuming isSheetPresented is a Binding to a boolean indicating if the sheet is presented)
    isSheetPresented = false
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

struct ReversedControlButtonStyle: ButtonStyle {
    var foregroundColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(5)
            .background(Color.black)
            .foregroundColor(foregroundColor)
            .cornerRadius(5)
    }
}

struct CustomTextFieldStyle: ViewModifier {
    var backgroundColor: Color
    var pad: Int
    
    func body(content: Content) -> some View {
        content
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .background(backgroundColor.opacity(0.75))
            .foregroundColor(.black)
            .cornerRadius(8)
        
    }
}


struct EditStudentView_Previews: PreviewProvider {
    @State private static var editedStudent: Student? = Student(
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
    )
    @State private static var headTeacher: HeadTeacher? = HeadTeacher(
        companyName: "",
        calendarName: "",
        teacherNumber: "0",
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
    static var previews: some View {
        if let unwrappedHeadTeacher = headTeacher {
            EditStudentView(
                isSheetPresented: .constant(false),
                editedStudent: .constant(nil),
                businessAddress: .constant("Preview Business Address"),
                headTeacher: .constant(unwrappedHeadTeacher)
            )
        }
    }
}


