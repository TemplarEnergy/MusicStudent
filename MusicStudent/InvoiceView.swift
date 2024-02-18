import Cocoa
import SwiftUI
import AppKit
import PDFKit
import Foundation
import UniformTypeIdentifiers


struct InvoiceView: View {
    @Binding var isInvoiceSheetPresented: Bool
    @Binding var listStudents: [Student]
    @Binding var businessAddress: String
    @Binding var headTeacher: HeadTeacher?
    @Binding var isSheetPresented: Bool
    
    //   @State private var isInvoiceSheetPresented: Bool = false
    @StateObject var viewModel = InvoiceViewModel()
    
    @State private var pdfData: Data?
    @State private var currentIndex: Int = 0
    //   @State private var invoiceTotal = 0
    @State private var invoiceName = ""
    
    @State private var invoiceTotal: Double = 0
    var invoiceDate: Date = Date()
    //  var lessonFee = "£30.00"
    var body: some View {
        if let student = listStudents.indices.contains(currentIndex) ? listStudents[currentIndex] : nil {
            InvoiceContentView(student: student, headTeacher: headTeacher,  viewModel: viewModel, currentIndex: $currentIndex, isInvoiceSheetPresented: $isInvoiceSheetPresented, isSheetPresented: $isSheetPresented, listStudents: $listStudents)
        }
    }
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
            let priceString = findRate(duration: lesson.duration, multiplier: student.multiplier)
            if let price = Double(priceString) {
                totalPrice += price
            }
        }
        
        return totalPrice
    }
    
}


func findRate(duration: String, multiplier: Int) -> String {
    var priceText = ""
    if let price = LessonRateManager.shared.findLessonDurationRate(duration: duration, multiplier: multiplier) {
        priceText = "£\(price))"
    }
    else {
        priceText = "£ 0.00"
    }
    return priceText
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


struct InvoiceContentView: View {
    var student: Student
    var headTeacher: HeadTeacher?
    var viewModel: InvoiceViewModel
    @Binding var currentIndex: Int
    @Binding var isInvoiceSheetPresented: Bool
    @Binding var isSheetPresented: Bool
    @Binding var listStudents: [Student]
    
    
    @State private var studentPDF: Student?
    
    var body: some View {
        if let student = listStudents.indices.contains(currentIndex) ? listStudents[currentIndex] : nil {
            ZStack {
                Rectangle()
                    .frame(width: 595, height: 842)
                    .foregroundColor(.white)
                    .border(Color.black)
                    .alignmentGuide(.top) { $0[VerticalAlignment.top] }
                
                VStack {
                    if let unwrappedStudent = student {
                        HeaderView(headTeacher: headTeacher, student: unwrappedStudent)
                        InvoiceDetailView(studentPDF: student)
                        BillinView(studentPDF: student, student: unwrappedStudent,  viewModel: viewModel)
                        LessonView(student: unwrappedStudent, viewModel: viewModel, listStudents: $listStudents)
                        Spacer()
                    }
                    PaymentDetailsView(headTeacher: headTeacher)
                    Spacer()
                    ButtonsView(generatePDF: generatePDF, studentPDF: $studentPDF, currentIndex: $currentIndex, isInvoiceSheetPresented: $isInvoiceSheetPresented, isSheetPresented: $isSheetPresented, listStudents: $listStudents)
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
    
    
    private struct ButtonsView: View {
        var generatePDF: () -> Void
        @Binding var studentPDF: Student?
        @Binding var currentIndex: Int
        @Binding var isInvoiceSheetPresented: Bool
        @Binding var isSheetPresented: Bool
        @Binding var listStudents: [Student]
        
        var body: some View {
            HStack(spacing: 20) {
                Button(action: {
                    // Save PDF button action
                    generatePDF()
                   
                    if currentIndex >= listStudents.count {
                        isInvoiceSheetPresented = false
                    }
                }) {
                    Text("Save PDF")
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                
                Button(action: {
                    // Cancel Student button action
                    currentIndex += 1
                    
                    if currentIndex >= listStudents.count {
                        isInvoiceSheetPresented = false
                        isSheetPresented = true
                    }
                }) {
                    Text("Cancel Student")
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.red)
                        .cornerRadius(8)
                }
                
                if listStudents.count > 1 {
                    Button(action: {
                        // Cancel All Students button action
                        isInvoiceSheetPresented = false
                        isSheetPresented = false
                    }) {
                        Text("Cancel All Students")
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.gray)
                            .cornerRadius(8)
                    }
                }
            }
        }
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
 /*
    private func letterDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy"
        return dateFormatter.string(from: date)
    }
*/
    private func generatePDF() {
        guard let student = studentPDF else {
            // Handle the case where studentPDF is nil
            return
        }
        
        // Generate a default PDF file name based on the current date and student's name
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM-yyyy"
        let currentDate = dateFormatter.string(from: Date())
        
        let fileName = "\(currentDate)-\(student.firstName)-\(student.lastName).pdf"
        
        if let unwrappedHeadTeacher = headTeacher {
            var invoiceTotal: Double = 0
            var invoiceName: String = ""
            invoiceTotal = viewModel.findTotalPrice(for: student)
            invoiceName = viewModel.findInvoiceName(for: student)
            
            updateStudentPDF(student) // Call updateStudentPDF here
            
            createInvoicePDF(student: student, invoiceTotal: invoiceTotal, headTeacher: unwrappedHeadTeacher, fileName: fileName, invoiceName: invoiceName,  isInvoiceSheetPresented: $isInvoiceSheetPresented)
        } else {
            // Handle the case where headTeacher is nil
        }
        
        currentIndex += 1
    }
}



private func LessonTimeDate(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm  MMM dd"
    return dateFormatter.string(from: date)
}

private func InvoiceIdDate() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyyMM"
    return dateFormatter.string(from: Date())
}

private func LetterDate() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMMM dd, yyyy"
    return dateFormatter.string(from: Date())
}


private struct BillinView: View {
    var studentPDF: Student
    var student: Student
    var viewModel: InvoiceViewModel
    var body: some View {
        HStack{
            VStack(alignment: .leading){
                if let invoiceName = viewModel.findInvoiceName(for: student) {
                    Text(invoiceName)
                }
                if let street1 = studentPDF.street1 {
                    Text(street1)
                }
                if let city = studentPDF.city {
                    Text(city)
                }
                if let county = studentPDF.county {
                    Text(county)
                }
                if let postalCode = studentPDF.postalCode {
                    Text(postalCode)
                }
                
                Text(" ")
                if let phone = studentPDF.phoneNumber {
                    Text(phone)
                }
                if let email = studentPDF.email {
                    Text(email)
                }
            }
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)

    }
        
}

private struct InvoiceDetailView: View {
    var studentPDF: Student
    var body: some View {
        VStack{
            
            HStack{
                Spacer()
                VStack(alignment: .leading) {
                    if let invoiceID = studentPDF.studentNumber, let invoiceIdDate = InvoiceIdDate() {
                        Text("Invoice ID: \(invoiceID)\(invoiceIdDate)")
                    }
                    if let letterDate = LetterDate() {
                        Text("Invoice Date: \(letterDate)")
                    }
                    if let dueDate = firstDayOfNextMonth() {
                        Text("Due Date: \(dueDate)")
                    }
                    if let accountName = studentPDF.firstName {
                        Text("Account: \(accountName)")
                    }
                }
            }
        }
    }
}

private struct LessonView: View {
    var student: Student
    var viewModel: InvoiceViewModel
    @Binding var listStudents: [Student]
    
    var body: some View {
        VStack {            
            if let lessons = student.lessons {
                ForEach(lessons, id: \.self) { lesson in
                    HStack(alignment: .top) {
                        Text("\(student.instrument) Lesson ")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("\(lesson.day)")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("\(LessonTimeDate(lesson.time))")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("\(lesson.duration) minutes")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text(findRate(duration: lesson.duration, multiplier: student.multiplier))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
    }
}

private struct HeaderView: View {
    var headTeacher: HeadTeacher?
    var student: Student
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(headTeacher?.companyName ?? "")
                    .font(.title)
                    .padding(.bottom)
                
                VStack(alignment: .leading) {
                    Text("\(headTeacher?.street1 ?? "")")
                    Text("\(headTeacher?.city ?? ""), \(headTeacher?.county ?? "")")
                    Text("\(headTeacher?.country ?? "")")
                    Text("\(headTeacher?.postalCode ?? "")")
                    Text("\(headTeacher?.phoneNumber ?? "")")
                    Text("\(headTeacher?.email ?? "")")
                }
                .padding(.bottom)
            }
            Spacer()
        }
        
    }
}

private struct PaymentDetailsView: View {
    var headTeacher: HeadTeacher?
    
    var body: some View {
        HStack {
            
            VStack(alignment: .leading) {
                if let unwrappedHeadTeacher = headTeacher {
                    Text("Payment Details \n")
                        .font(.headline)
                    Text("\(unwrappedHeadTeacher.payableName)")
                    Text("Sort Code: \(unwrappedHeadTeacher.sortCode) \(unwrappedHeadTeacher.accountNumber)")
                        .padding(.bottom)
                    Text("Please make cheques payable to \(unwrappedHeadTeacher.payableName)")
                }
            }
            .font(.caption)
            Spacer()
        }
        
    }
}


