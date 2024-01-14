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

                Text("\(student.lessonDay)")
                    .padding()
            }
        }
    }
}


struct StudentRowView_Previews: PreviewProvider {
    static var previews: some View {
        StudentRowView(student: Student(
            firstName: "John",
            lastName: "Doe",
            parentsName: "Jane Doe",
            instrument: "Violin",
            lessonDay: "Monday",
            lessonTime: Date(),
            duration: "30",
            kit: ["Accessory1", "Accessory2"],
            active: true
        ))
    }
}
