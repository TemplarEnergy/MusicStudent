//
//  StudentRowView.swift
//  MusicStudent
//
//  Created by Thomas Radford on 31/12/2023.
//
import SwiftUI

struct StudentRowView: View {
    let student: Student

    var body: some View {
        Button(action: {
            // Handle the tap if needed
           
        }) {
            HStack {
                Text("\(student.firstName) \(student.lastName)")
                    .font(.headline)
                    .padding()

                Spacer()

                Text("\(student.instrument)")
                    .padding()

                Text("\(student.lessons.first?.day ?? "")")
                    .padding()
            }
        }
    }
}


struct StudentRowView_Previews: PreviewProvider {
    static var previews: some View {
        StudentRowView(student: Student(
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
        ))
    }
}
