//
//  HeadTeacherInputView.swift
//  MusicStudent
//
//  Created by Thomas Radford on 03/02/2024.
//
import SwiftUI

struct HeadTeacherInputView: View {
    @Binding var showHeadTeacherInput: Bool
    @Binding var headTeacher: HeadTeacher
    @State private var isShowTaughtInstruments = false
    @State private var isShowLessonPrices = false
    @State private var lessonRates = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                Spacer()
                HStack {
                    Spacer()
                    Button("Change Rates") {
                        isShowLessonPrices.toggle()
                    }
                    .padding(20)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .sheet(isPresented: $isShowLessonPrices ) {
                        // Show the invoice view when the flag is true
                        
                        LessonRateView(
                            isShowLessonPrices: $isShowLessonPrices
                        )
                    }
                    .cornerRadius(8)
                    Spacer()
                    Button("Change Instruments") {
                        isShowTaughtInstruments.toggle()
                    }
                    .padding(20)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .sheet(isPresented: $isShowTaughtInstruments ) {
                        // Show the invoice view when the flag is true
                        
                        TaughtInstrumentView(
                            isShowTaughtInstruments: $isShowTaughtInstruments
                        )
                    }
                    .cornerRadius(8)
                    Spacer()
                }
               
                
                Form {
                    Section(header: Text("Company Information")
                        .foregroundColor(.olive) // Change text color
                        .background(Color.black)
                    ) {
                        HStack {
                            VStack(alignment: .leading) {
                                Spacer()
                                TextField("Company Name", text: $headTeacher.companyName)
                                    .frame(width: 300)
                                TextField("Teaching Calendar Name", text: $headTeacher.calendarName)
                                    .frame(width: 300)
                                TextField("Street Address", text: $headTeacher.street1)
                                    .frame(width: 300)
                                TextField(" ", text: $headTeacher.street2)
                                    .frame(width: 300)
                                HStack {
                                    TextField("City", text: $headTeacher.city)
                                        .frame(width: 150)
                                    TextField("County", text: $headTeacher.county)
                                        .frame(width: 150)
                                }
                                HStack {
                                    TextField("Country", text: $headTeacher.country)
                                        .frame(width: 200)
                                    TextField("PostCode", text: $headTeacher.postalCode)
                                        .frame(width: 150)
                                }
                            }
                            .font(.body)
                        }
                        
                    }
                    .padding(.top, 20)
                    .padding(.leading, 20)
                    .font(.headline)
                    
                    
                    Section(header: Text("Contact Information")
                        .foregroundColor(.olive) // Change text color
                        .background(Color.black)
                    ) {
                        VStack(alignment: .leading) {
                            TextField("First Name", text: $headTeacher.firstName)
                                .frame(width: 300)
                            TextField("Last Name", text: $headTeacher.lastName)
                                .frame(width: 300)
                            TextField("eMail", text: $headTeacher.email)
                                .frame(width: 300)
                            TextField("Phone", text: $headTeacher.phoneNumber)
                                .frame(width: 300)
                            TextField("Alternative Phone", text: $headTeacher.phoneNumber2)
                                .frame(width: 300)
                            TextField("Teacher Number", text: $headTeacher.teacherNumber)
                                .frame(width: 100)
                        }
                        .font(.body)
                    }
                    
                    .padding(.top, 20)
                    .padding(.leading, 20)
                    .font(.headline)
                    
                    Section(header: Text("Additional Information")
                        .foregroundColor(.olive) // Change text color
                        .background(Color.black)
                    ) {
                        VStack(alignment: .leading) {
                            Toggle("Active", isOn: $headTeacher.active)
                                .frame(width: 200)
                            TextField("Wage £/hr", text: $headTeacher.rate)
                                .frame(width: 100)
                        }
                        .font(.body)
                    }
                    
                    .padding(.top, 20)
                    .padding(.leading, 20)
                    .font(.headline)
                    
                    Section(header: Text("Banking Information")
                        .foregroundColor(.olive) // Change text color
                        .background(Color.black)
                    ) {
                        VStack(alignment: .leading) {
                            TextField("Payable to Name", text: $headTeacher.payableName)
                                .frame(width: 300)
                            TextField("Account Number", text: $headTeacher.accountNumber)
                                .frame(width: 300)
                            TextField("Sort Code", text: $headTeacher.sortCode)
                                .frame(width: 300)
                        }
                        .font(.body)
                    }
                    .padding(.top, 20)
                    .padding(.leading, 20)
                    .font(.headline)
                    
                    HStack {
                        Spacer()
                        Button(action: {
                            saveData()
                            showHeadTeacherInput = false
                        }) {
                            Text("Save")
                                .foregroundColor(.black)
                                .padding()
                                
                                .cornerRadius(8)
                        }
                        .background(Color.olive)
                            .cornerRadius(8)
                        Button(action: {
                            showHeadTeacherInput = false
                        }) {
                            Text("Cancel")
                                .foregroundColor(.black)
                                .padding()
                                
                                .cornerRadius(8)
                        }
                        .background(Color.gold)
                            .cornerRadius(8)
                        Spacer()
                    }
                    .padding(20)
                    .font(.body)
                }
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Admin")
                            .font(.headline)
                    }
                }
                .onAppear {
                    loadData()
                }
            }
            .frame(minWidth: 500,   minHeight: 800, maxHeight: .infinity, alignment: .top)
        }
        .onAppear(){
            loadData()
        }
    }
    
    private func saveData() {
        // Save a single HeadTeacher
        print("HeadTeacher name is \(headTeacher.calendarName)")
        PlistManager.shared.saveHeadTeacherData(headTeacher)
    }
    
    private func loadData() {
        if let loadedData = PlistManager.shared.loadHeadTeacherData()  {
            headTeacher = loadedData
        }
    }
}

struct HeadTeacherInputView_Previews: PreviewProvider {
    static var previews: some View {
        let headTeacher = HeadTeacher(
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
        return HeadTeacherInputView(showHeadTeacherInput: .constant(true), headTeacher: .constant(headTeacher))
    }
}
