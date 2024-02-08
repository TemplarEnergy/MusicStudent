import Cocoa
import SwiftUI
import AppKit
import PDFKit
import Foundation
import UniformTypeIdentifiers


struct PDFPreview: NSViewRepresentable {
    let data: Data
    
    func makeNSView(context: Context) -> NSView {
        let pdfView = PDFView()
        pdfView.document = PDFDocument(data: data)
        return pdfView
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {}
}
extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}




struct InvoiceView: View {
    @Binding var isInvoiceSheetPresented: Bool
    @Binding var listStudents: [Student]
    @Binding var businessAddress: String
    @Binding var headTeacher: HeadTeacher?
    @Binding var isSheetPresented: Bool
    
    //   @State private var isInvoiceSheetPresented: Bool = false
    @StateObject var viewModel = InvoiceViewModel()
    
    @State private var pdfData: Data?
    @State private var studentPDF: Student?
    @State private var currentIndex: Int = 0
 //   @State private var invoiceTotal = 0
    @State private var invoiceName = ""
    
    @State private var invoiceTotal: Double = 0
    var invoiceDate: Date = Date()
    //  var lessonFee = "£30.00"
    
    
    
    
    var body: some View {
        
        if let student = listStudents.indices.contains(currentIndex) ? listStudents[currentIndex] : nil {
            
            ZStack {
                Rectangle()
                    .frame(width: 595, height: 842) // A4 dimensions in points (1 point = 1/72 inch)
                    .foregroundColor(.white) // Optional: Set the background color to white
                    .border(Color.black) // Optional: Add a border for visualization
                    .alignmentGuide(.top) { $0[VerticalAlignment.top] }
                
                
                VStack {
                    VStack {
                        VStack {
                            Text(" ")
                            Text(" ")
                            Text(" ")
                            HStack{
                                Spacer()
                                Text("\(headTeacher?.companyName ?? "")")
                                    .font(.title)
                                    .onAppear {
                                        updateStudentPDF(student)
                                        studentPDF = student
                                    }
                                Spacer()
                            }
                            HStack{
                                VStack(alignment: .leading, spacing: 1) {
                                    VStack {
                                        Text(" ")
                                        Text(" ")
                                        Text(" ")
                                    }
                                    Text("\(headTeacher?.street1 ?? "")")
                                        .padding(.trailing)
                                    Text("\(headTeacher?.city ?? ""), \(headTeacher?.county ?? "")")
                                        .padding(.trailing)
                                    Text("\(headTeacher?.country ?? "")")
                                        .padding(.trailing)
                                    Text("\(headTeacher?.postalCode ?? "")")
                                        .padding(.trailing)
                                    Text("\(headTeacher?.phoneNumber ?? "")")
                                        .padding(.trailing)
                                    Text("\(headTeacher?.email ?? "")")
                                        .padding(.trailing)
                                    Text(" ")
                                        .padding(.trailing)
                                }
                                Spacer()
                            }
                           
                            
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        VStack{
                            
                            HStack{
                                Spacer()
                                VStack(alignment: .leading) {
                                    if let invoiceID = studentPDF?.studentNumber, let invoiceIdDate = InvoiceIdDate() {
                                        Text("Invoice ID: \(invoiceID)\(invoiceIdDate)")
                                    }
                                    if let letterDate = LetterDate() {
                                        Text("Invoice Date: \(letterDate)")
                                    }
                                    if let dueDate = firstDayOfNextMonth() {
                                        Text("Due Date: \(dueDate)")
                                    }
                                    if let accountName = studentPDF?.firstName {
                                        Text("Account: \(accountName)")
                                    }
                                }
                                
                                VStack {
                                    VStack {
                                        Text(" ")
                                        Text(" ")
                                        Text(" ")
                                    }
                                }
                            }
                                HStack{
                                    VStack(alignment: .leading){
                                        if let invoiceName = viewModel.findInvoiceName(for: student) {
                                            Text(invoiceName)
                                        }
                                        if let street1 = studentPDF?.street1 {
                                            Text(street1)
                                        }
                                        if let city = studentPDF?.city {
                                            Text(city)
                                        }
                                        if let county = studentPDF?.county {
                                            Text(county)
                                        }
                                        if let postalCode = studentPDF?.postalCode {
                                            Text(postalCode)
                                        }
                                    }
                                    Spacer()
                                }
                                .padding()
                                
                            
                            
                            VStack {
                                Text(" ")
                                Text(" ")
                                Text(" ")
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("Lessons:")
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)

                        if let lessons = studentPDF?.lessons {
                            ForEach(Array(lessons.enumerated()), id: \.element) { index, lesson in
                                HStack(alignment: .top) {
                                    Text("Lesson # \(index + 1)")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Text("\(lesson.day)")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Text("\(formattedDate(lesson.time))")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Text("\(lesson.duration) minutes")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Text("£\(lesson.price)")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        }
 
                            
                        
                    }
   
                    if let kit = studentPDF?.kit {
                        Text("Additonal Services:")
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                        ForEach(kit, id: \.self) { kitParm in
                            HStack (alignment: .top){
                                Spacer()
                                Text( "\(kitParm.name)")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text( "    ")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text( "\(formattedDate(kitParm.date))")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text( "    ")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text( "£\(kitParm.price)")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        HStack{
                            Spacer()
                            Text( "    ")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text( "    ")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text( "    ")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text( "   ")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text( "==========")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        HStack{
                            Spacer()
                            Text( "Total")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text( "    ")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text( "   ")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text( "    ")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(String(viewModel.findTotalPrice(for: student)))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    
                    Spacer()
                    HStack {
                        VStack (alignment: .leading){
                            if let unwrappedHeadTeacher = headTeacher{
                                Text("Payment Details \n")
                                Text("\(unwrappedHeadTeacher.payableName)")
                                Text("Sort Code: \(unwrappedHeadTeacher.sortCode) \(unwrappedHeadTeacher.accountNumber)\n")
                                Text("Please make cheques payable to \(unwrappedHeadTeacher.payableName)")
                            }
                        }
                        .font(.caption)
                        Spacer()
                    }
                   
         
        
                    Button("Save PDF") {
                        generatePDF()
                  //      isInvoiceSheetPresented = false
                 //       isSheetPresented.toggle()
                        
                    }
                    .padding()
                    Button("Cancel Student") {
                        currentIndex += 1
                        if let lessonCount = studentPDF?.lessons.count, currentIndex >= lessonCount {
                            isInvoiceSheetPresented = false
                        }
                        if currentIndex + 1 > listStudents.count {
                            isSheetPresented = false
                        }
                        
                    }
          
                    
                   if listStudents.count > 1 {
                        Button("Cancel All Student") {
                            
                            isInvoiceSheetPresented = false
                           isSheetPresented = false
                        }
                    }
                    
                }
                .padding(20)
                .frame(width: 595, height: 950)
                .onAppear {
                    updateStudentPDF(student)
                }
                .onChange(of: currentIndex) { newIndex in
                    if let newStudent = listStudents.indices.contains(newIndex) ? listStudents[newIndex] : nil {
                        updateStudentPDF(newStudent)
                    } else {
                        studentPDF = nil
                        isInvoiceSheetPresented = false
                    }
                }
            }
            
        }
    }
    
    private func addTotal(item: String) {
        if let itemsPrice = Double(item) {
            invoiceTotal += itemsPrice
        }
    }
        
        private func InvoiceIdDate() -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMM"
            return dateFormatter.string(from: Date())
        }
    
    private func generatePDF() {
        guard let student = studentPDF else {
            // Handle the case where studentPDF is nil
            return
        }
        
        // Generate a default PDF file name based on the current date and student's name
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MMMM"
        let currentDate = dateFormatter.string(from: Date())
        
        let fileName = "\(currentDate)-\(student.firstName)-\(student.lastName).pdf"
        
        let viewModel = InvoiceViewModel() // Create an instance of InvoiceViewModel
        
        if let unwrappedHeadTeacher = headTeacher {
            var invoiceTotal: Double = 0 // Declare invoiceTotal as a local variable
            var invoiceName: String = "" // Declare invoiceName as a local variable
            invoiceTotal = viewModel.findTotalPrice(for: student) // Call instance method on the instance
            invoiceName = viewModel.findInvoiceName(for: student) // Call instance method on the instance
            createInvoicePDF(student: student, invoiceTotal: invoiceTotal, headTeacher: unwrappedHeadTeacher, fileName: fileName, invoiceName: invoiceName)
        } else {
            // Handle the case where headTeacher is nil
        }

        currentIndex += 1
    }

    
    class InvoiceViewModel: ObservableObject {
        func findInvoiceName(for student: Student) -> String {
            var tempStudent = student
            if student.parentsName.isEmpty {
                tempStudent.parentsName = student.firstName
                tempStudent.parentsLastName = student.lastName
            }
            
            return "\(tempStudent.parentsName) \(tempStudent.parentsLastName)"
        }
        
        func findTotalPrice(for student: Student) -> Double {
            var totalPrice = 0.0
            
            // Loop over kit items
            for kitItem in student.kit {
                if let price = Double(kitItem.price) {
                    totalPrice += price
                }
            }
            
            // Loop over lesson items
            for lesson in student.lessons {
                if let price = Double(lesson.price) {
                    totalPrice += price
                }
            }
            
            return totalPrice
        }

    }
    
    
    private func LetterDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy"
        return dateFormatter.string(from: Date())
    }


    func firstDayOfNextMonth() -> String? {
        // Get the current calendar and today's date
        let calendar = Calendar.current
        let today = Date()

        // Get the components for the next month
        var nextMonthComponents = DateComponents()
        nextMonthComponents.month = 1

        // Calculate the date by adding the components to today's date
        if let nextMonthDate = calendar.date(byAdding: nextMonthComponents, to: today) {
            // Get the components for the first day of the next month
            var firstDayComponents = calendar.dateComponents([.year, .month], from: nextMonthDate)
            firstDayComponents.day = 1

            // Construct the date
            if let firstDayNextMonth = calendar.date(from: firstDayComponents) {
                // Format the date as "MMM dd, yyyy"
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM dd, yyyy"
                return dateFormatter.string(from: firstDayNextMonth)
            }
        }

        return nil
    }
    
    private func updateStudentPDF(_ student: Student) {
        studentPDF = student
        print("student parents name \(student.parentsName) and students name \(student.firstName) ")
        if student.parentsName.isEmpty {
            studentPDF?.parentsName = student.firstName
            studentPDF?.parentsLastName = student.lastName
        }
        else
        {
            studentPDF?.parentsName = student.parentsName
            studentPDF?.parentsLastName = student.parentsLastName
        }
    }
    
  
    private func formattedDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd"
        return dateFormatter.string(from: date)
    }
    
    private func letterDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy"
        return dateFormatter.string(from: date)
    }
}


struct InvoiceViewData {
    let businessAddress: String
    let studentAddress: String
    let lessonDate: Date
    let lessonDuration: String
    let lessonFee: String
    let kitItems: [String]
}


struct InvoiceView_Previews: PreviewProvider {
    static var previews: some View {
        InvoiceView(
            isInvoiceSheetPresented: .constant(false),
            listStudents: .constant([]),
            businessAddress: .constant("Preview Business Address"),
            headTeacher: .constant(nil),
            isSheetPresented: .constant(false) // Provide an appropriate default value for headTeacher
        )
    }
}
