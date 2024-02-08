//
//  CreateInvoicePDF.swift
//  MusicStudent
//
//  Created by Thomas Radford on 07/02/2024.
//

import Cocoa
import SwiftUI
import AppKit
import PDFKit
import Foundation
import UniformTypeIdentifiers
 
func createInvoicePDF(student: Student, invoiceTotal: Double, headTeacher: HeadTeacher, fileName: String, invoiceName: String)  {
    
    
    // Create a PDF document
    let fontBody: CGFloat = 10
    let fontCaption: CGFloat = 8
    let fontTitle: CGFloat = 18
    
    let textColor = NSColor.white
    let pdfDocument = PDFDocument()
    
    var streetAddress: String
    // Create a PDF page
    let pdfPage = PDFPage()
    //   let student = studentPDF!
    // Add your company name at the top with larger font and bold using annotation
    let companyNameText = headTeacher.companyName
    let companyNameFont = NSFont.boldSystemFont(ofSize: fontTitle)
    let companyNameRect = CGRect(x: 150, y: 700, width: 500, height: 30)
    let companyNameAnnotation = PDFAnnotation(bounds: companyNameRect, forType: .freeText, withProperties: nil)
    companyNameAnnotation.font = companyNameFont
    companyNameAnnotation.color = NSColor.white
    companyNameAnnotation.contents = companyNameText
    pdfPage.addAnnotation(companyNameAnnotation)
    
    // Add your address on the right using annotation
    let yourAddressText = "\(headTeacher.street1)\n\(headTeacher.city ), \(headTeacher.county ),\n\(headTeacher.country ),\n\(headTeacher.postalCode )\n\n\(headTeacher.phoneNumber)\n\n\(headTeacher.email )"
        let yourAddressFont = NSFont.systemFont(ofSize: fontBody)
        let yourAddressRect = CGRect(x: 50, y: 540, width: 200, height: 150)
        let yourAddressAnnotation = PDFAnnotation(bounds: yourAddressRect, forType: .freeText, withProperties: nil)
        yourAddressAnnotation.font = yourAddressFont
        yourAddressAnnotation.color = NSColor.white
        yourAddressAnnotation.contents = yourAddressText
        pdfPage.addAnnotation(yourAddressAnnotation)
        
        // Add a link to the email address
    if headTeacher.email != "" {
        let email = headTeacher.email
        let emailLinkRect = CGRect(x: 50, y: 520, width: 200, height: 150)
        let emailLinkAnnotation = PDFAnnotation(bounds: emailLinkRect, forType: .link, withProperties: nil)
   //     let emailLinkRect = CGRect(x: 50, y: 520, width: 200, height: 150)
        emailLinkAnnotation.color = NSColor.white
        emailLinkAnnotation.url = URL(string: "mailto:\(email)")
        pdfPage.addAnnotation(emailLinkAnnotation)
        
    }
    let InvoiceDateText = InvoiceIdDate()
    let letterDateText = InvoiceDate()
    let firstDayofNextMonthText = firstDayOfNextMonth() ?? "N/A"
    
    let studentIDText = "Invoice ID \(student.studentNumber)\(InvoiceDateText)\nInvoice Date: \(letterDateText)\nDue Date: \(firstDayofNextMonthText)\nAccount: \(student.firstName)"
    let studentIDFont = NSFont.systemFont(ofSize: fontBody)
    let studentIDRect = CGRect(x: 350, y: 480, width: 200, height: 100)
    let studentIDAnnotation = PDFAnnotation(bounds: studentIDRect, forType: .freeText, withProperties: nil)
    studentIDAnnotation.font = studentIDFont
    studentIDAnnotation.color = NSColor.white
    studentIDAnnotation.contents = studentIDText
    pdfPage.addAnnotation(studentIDAnnotation)
    
    
    if !student.street2.isEmpty {
        streetAddress = "\(student.street1)\n\(student.street2)"
    }
    else {
        streetAddress = student.street1
    }
    
    // Add client's name on the left using annotation
    let clientNameText = "\(invoiceName)\n\(streetAddress)\n\(student.city),\(student.county)\n\(student.country)\n\(student.postalCode)"
    let clientNameFont = NSFont.systemFont(ofSize: fontBody)
    let clientNameRect = CGRect(x: 50, y: 500, width: 200, height: 70)
    let clientNameAnnotation = PDFAnnotation(bounds: clientNameRect, forType: .freeText, withProperties: nil)
    clientNameAnnotation.font = clientNameFont
    clientNameAnnotation.color = NSColor.white
    clientNameAnnotation.contents = clientNameText
    pdfPage.addAnnotation(clientNameAnnotation)
    
    var yPos = 450
    
    for (index, lessonLine) in student.lessons.enumerated() {
       // Add four lines with description, date, and price
       
           // Adjust x coordinates for description, date, and price
           let xIndex = 50
        let xName = 75
           let xDate = 250
           let xDuration = 375
           let xPrice = 450

           // Sample text for each field
        let indexText =  "# \(index + 1)"
        let nameText =  "\(student.instrument)"
        let dateText = "\(LetterDate(lessonLine.time))"
        let durationText = "\(lessonLine.duration) minutes"
        let priceText = "£\(lessonLine.price)"

           // Font and text color
           let font = NSFont.systemFont(ofSize: fontBody)
        
        // Add description text
        let indexRect = CGRect(x: xIndex, y: yPos, width: 200, height: 20)
        let indexAnnotation = PDFAnnotation(bounds: indexRect, forType: .freeText, withProperties: nil)
        indexAnnotation.font = font
        indexAnnotation.color = textColor
        indexAnnotation.contents = indexText
        pdfPage.addAnnotation(indexAnnotation)
        
           // Add description text
           let nameRect = CGRect(x: xName, y: yPos, width: 200, height: 20)
           let nameAnnotation = PDFAnnotation(bounds: nameRect, forType: .freeText, withProperties: nil)
        nameAnnotation.font = font
        nameAnnotation.color = textColor
        nameAnnotation.contents = nameText
           pdfPage.addAnnotation(nameAnnotation)

           // Add date text
           let dateRect = CGRect(x: xDate, y: yPos, width: 200, height: 20)
           let dateAnnotation = PDFAnnotation(bounds: dateRect, forType: .freeText, withProperties: nil)
           dateAnnotation.font = font
           dateAnnotation.color = textColor
           dateAnnotation.contents = dateText
           pdfPage.addAnnotation(dateAnnotation)
        
        // Add duration text
        let durationRect = CGRect(x: xDuration, y: yPos, width: 200, height: 20)
        let durationAnnotation = PDFAnnotation(bounds: durationRect, forType: .freeText, withProperties: nil)
        durationAnnotation.font = font
        durationAnnotation.color = textColor
        durationAnnotation.contents = durationText
        pdfPage.addAnnotation(durationAnnotation)


           // Add price text
           let priceRect = CGRect(x: xPrice, y: yPos, width: 200, height: 20)
           let priceAnnotation = PDFAnnotation(bounds: priceRect, forType: .freeText, withProperties: nil)
           priceAnnotation.font = font
           priceAnnotation.color = textColor
           priceAnnotation.contents = priceText
           pdfPage.addAnnotation(priceAnnotation)
        yPos = yPos -  Int(2.2 * fontBody)
        
       }
    
    // Iterate over student's kit lines and add them to the PDF
   
    
    

    // Define the y positions for each line
        
    for kitLine in student.kit {
       // Add four lines with description, date, and price
       
           // Adjust x coordinates for description, date, and price
           let xName = 50
           let xDate = 250
           let xPrice = 450

           // Sample text for each field
        let nameText = "\(kitLine.name)"
        let dateText = "\(LetterDate(kitLine.date))"
        let priceText = "£\(kitLine.price)"

           // Font and text color
           let font = NSFont.systemFont(ofSize: fontBody)

           // Add description text
           let nameRect = CGRect(x: xName, y: yPos, width: 200, height: 20)
           let nameAnnotation = PDFAnnotation(bounds: nameRect, forType: .freeText, withProperties: nil)
        nameAnnotation.font = font
        nameAnnotation.color = textColor
        nameAnnotation.contents = nameText
           pdfPage.addAnnotation(nameAnnotation)

           // Add date text
           let dateRect = CGRect(x: xDate, y: yPos, width: 200, height: 20)
           let dateAnnotation = PDFAnnotation(bounds: dateRect, forType: .freeText, withProperties: nil)
           dateAnnotation.font = font
           dateAnnotation.color = textColor
           dateAnnotation.contents = dateText
           pdfPage.addAnnotation(dateAnnotation)

           // Add price text
           let priceRect = CGRect(x: xPrice, y: yPos, width: 200, height: 20)
           let priceAnnotation = PDFAnnotation(bounds: priceRect, forType: .freeText, withProperties: nil)
           priceAnnotation.font = font
           priceAnnotation.color = textColor
           priceAnnotation.contents = priceText
           pdfPage.addAnnotation(priceAnnotation)
        yPos = yPos -  Int(2.2 * fontBody)
        
       }
    
    let xName = 50
     
    let xPrice = 450

    // Sample text for each field
  
 let separatorText = "============="

    // Font and text color
    let font = NSFont.systemFont(ofSize: fontBody)

    // Add description text
    // Add price text
    let separatorRect = CGRect(x: xPrice, y: yPos, width: 200, height: 20)
    let separatorAnnotation = PDFAnnotation(bounds: separatorRect, forType: .freeText, withProperties: nil)
    separatorAnnotation.font = font
    separatorAnnotation.color = textColor
    separatorAnnotation.contents = separatorText
    pdfPage.addAnnotation(separatorAnnotation)
   
    
     yPos = yPos -  Int(2.2 * fontBody)
    let nameText = "Total"
    let priceText = String(invoiceTotal)
    
    let nameRect = CGRect(x: xName, y: yPos, width: 200, height: 20)
    let nameAnnotation = PDFAnnotation(bounds: nameRect, forType: .freeText, withProperties: nil)
 nameAnnotation.font = font
 nameAnnotation.color = textColor
 nameAnnotation.contents = nameText
    pdfPage.addAnnotation(nameAnnotation)
 
    // Add price text
    let priceRect = CGRect(x: xPrice, y: yPos, width: 200, height: 20)
    let priceAnnotation = PDFAnnotation(bounds: priceRect, forType: .freeText, withProperties: nil)
    priceAnnotation.font = font
    priceAnnotation.color = textColor
    priceAnnotation.contents = ("£\(priceText)")
    pdfPage.addAnnotation(priceAnnotation)
   
    
    
    
    // Add your banking details at the bottom using annotation
    let bankingDetailsText = "\nPayment Details: \n\(headTeacher.payableName)\nSort Code: \(headTeacher.sortCode) Account: \(headTeacher.accountNumber)\nPlease make cheques payable to \(headTeacher.payableName)"
    let bankingDetailsFont = NSFont.systemFont(ofSize: fontCaption)
    let bankingDetailsRect = CGRect(x: 50, y: 50, width: 250, height: 80)
    let bankingDetailsAnnotation = PDFAnnotation(bounds: bankingDetailsRect, forType: .freeText, withProperties: nil)
    bankingDetailsAnnotation.font = bankingDetailsFont
    bankingDetailsAnnotation.color = NSColor.white
    bankingDetailsAnnotation.contents = bankingDetailsText
    pdfPage.addAnnotation(bankingDetailsAnnotation)
    
    // Insert the page to the document
    pdfDocument.insert(pdfPage, at: pdfDocument.pageCount)
    
    
    savePDF(pdfDocument, withFileName: fileName)
    
}

private func LetterDate(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMMM dd, yyyy"
    return dateFormatter.string(from: date)
}

private func InvoiceDate() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMMM yyyy"
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

private func InvoiceIdDate() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyyMM"
    return dateFormatter.string(from: Date())
}

private func savePDF(_ pdfDocument: PDFDocument, withFileName fileName: String) {
    let savePanel = NSSavePanel()
    savePanel.allowedContentTypes = [UTType.pdf]
    savePanel.nameFieldStringValue = fileName
    
    savePanel.begin { (result) in
        if result == .OK, let url = savePanel.url {
            pdfDocument.write(to: url)
            print("Saved PDF to: \(url)")
        }
    }
}
