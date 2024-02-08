//
//  LessonRateView.swift
//  MusicStudent
//
//  Created by Thomas Radford on 04/02/2024.
//
import SwiftUI
import Combine

struct LessonData: Identifiable, Equatable, Codable{
    var id: String { duration }
    var duration: String
    var fee: String
}



struct LessonRateView: View {
    @Binding var isShowLessonPrices: Bool
    @State private var sortedLessonData: [LessonData] = []
    
    private func loadData() {
        sortedLessonData = LessonDataManager.shared.loadLessonData()
            .sorted { $0.duration < $1.duration }
    }
    
    private func deleteLesson(at indexSet: IndexSet) {
        sortedLessonData.remove(atOffsets: indexSet)
        // Perform any additional deletion logic if needed
    }
    
    // Inside LessonRateView
    private func saveData() {
        LessonDataManager.shared.saveLessonData(sortedLessonData)
    }
    
    private func addLesson() {
        // Add a default entry or customize as needed
        let newLesson = LessonData(duration: "", fee: "")
        sortedLessonData.append(newLesson)
    }
    
    var body: some View {
        VStack {
          
            HStack {
                Spacer()
            Button(action: {
                addLesson()
            }) {
                 Text("Add Lesson")
                    .foregroundColor(.white)
                    .padding(20)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .padding(40)
                Spacer()
            }
            
            ForEach(0..<sortedLessonData.count, id: \.self) { index in
                HStack {
                    Spacer()
                    TextField("Duration  minutes", text: $sortedLessonData[index].duration)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 180)
                    Spacer()
                    TextField("Fee  £", text: $sortedLessonData[index].fee)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 120)
                    
                    Button(action: {
                        deleteLesson(at: IndexSet([index]))
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
                    isShowLessonPrices = false
                }) {
                    Text("Save")
                        .foregroundColor(.black)
                        .padding()
                        .background(Color.olive)
                        .cornerRadius(8)
                }
                Button(action: {
                    isShowLessonPrices = false
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

struct LessonRateView_Previews: PreviewProvider {
    static var previews: some View {
        LessonRateView(isShowLessonPrices: .constant(false))
    }
}

