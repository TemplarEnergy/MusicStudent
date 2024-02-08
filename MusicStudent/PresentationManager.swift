//
//  PresentationManager.swift
//  MusicStudent
//
//  Created by Thomas Radford on 25/01/2024.
//

import SwiftUI

class PresentationManager: ObservableObject {
    @Published var isSheetPresented = false
    @Published var isInvoiceViewPresented = false

    func showInvoiceView(
        businessAddress: String,
        studentAddress: String,
        lessonDate: Date,
        lessonDuration: String,
        lessonFee: String,
        kitItems: [String]
    ) {
        // Set up the data or perform any other necessary actions
        // ...

        // Set the flag to present the invoice view
        isInvoiceViewPresented = true
    }
}
