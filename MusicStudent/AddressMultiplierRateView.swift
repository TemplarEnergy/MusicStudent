//
//  AddressMultiplierRateView.swift
//  MusicStudent
//
//  Created by Thomas Radford on 21/02/2024.
//

import SwiftUI

import Combine

struct AddressMultiplierRate: Identifiable, Equatable, Codable{
    var id: String { address }
    var address: String
    var multiplier: Double
}



struct AddressMultiplierRateView: View {
    @Binding var isShowAddressMultiplier: Bool
    @Binding var headTeacher: HeadTeacher
    
    @State private var sortedAddressData: [AddressMultiplierRate] = []
    @State private var multiplierString: String = ""
    
    private func loadData() {
        sortedAddressData = AddressMultiplierRateManager.shared.loadAddressMultiplierRates()
            .sorted { $0.address < $1.address }
    }
    
    private func deleteAddress(at indexSet: IndexSet) {
        sortedAddressData.remove(atOffsets: indexSet)
        // Perform any additional deletion logic if needed
    }
    
    // Inside LessonRateView
    private func saveData() {
        AddressMultiplierRateManager.shared.saveAddressMultiplierRate(sortedAddressData)
        let students = DatabaseManager.shared.loadStudents()
            for student in students {
                let updatedMultiplier = AddressMultiplierRateManager.shared.updateMultiplier(firstThreeWords: student.street1)
                if student.firstName == "Edward" {
                    print("my name is \(student.firstName)")
                }
                         
                    DatabaseManager.shared.updateStudentMultiplier(for: student.street1, with: updatedMultiplier)
                
            }
            isShowAddressMultiplier = false
    }
    
    private func addAddress() {
        // Add a default entry or customize as needed
        let newAddress = AddressMultiplierRate(address: "", multiplier: 1.0)
        sortedAddressData.append(newAddress)
    }
    
    var body: some View {
        VStack {
          
            HStack {
                Spacer()
            Button(action: {
                addAddress()
            }) {
                 Text("Add Address")
                    .foregroundColor(.white)
                    .padding(20)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .padding(40)
                Spacer()
            }
            
            ForEach(0..<$sortedAddressData.count, id: \.self) { index in
                HStack {
                    Spacer()
                    TextField("Address Multiplier ", text: $sortedAddressData[index].address)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 180)
                    Spacer()
                    TextField("Multiplier ", text: Binding<String>(
                        get: { String(sortedAddressData[index].multiplier) },
                        set: { sortedAddressData[index].multiplier = Double($0) ?? 0.0 }
                    ))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 120)
                    
                    Button(action: {
                        deleteAddress(at: IndexSet([index]))
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    Spacer()
                }
                .padding()
            }
            
            HStack {
                Spacer()
                Button(action: {
                    saveData()
                    isShowAddressMultiplier = false
                }) {
                    Text("Save")
                        .foregroundColor(.black)
                        .padding()
                        .background(Color.olive)
                        .cornerRadius(8)
                }
                Button(action: {
                    isShowAddressMultiplier = false
                }) {
                    Text("Cancel")
                        .foregroundColor(.black)
                        .padding()
                        .background(Color.gold)
                        .cornerRadius(8)
                }
                Spacer()
            }
            Spacer()
        }
        .frame(minWidth: 400, idealWidth: 500, maxWidth: 600, minHeight: 500, maxHeight: .infinity, alignment: .top)
        .onAppear {
            loadData()
        }
    }
}

struct AddressMultiplierRateView_Previews: PreviewProvider {
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
        AddressMultiplierRateView(isShowAddressMultiplier: .constant(false), headTeacher: .constant(headTeacher))
    }
}

