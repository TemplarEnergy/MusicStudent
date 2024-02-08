//
//  LessonRateView.swift
//  MusicStudent
//
//  Created by Thomas Radford on 04/02/2024.
//
import SwiftUI
import Combine

struct Instruments: Identifiable, Equatable, Codable{
    var id: String { duration }
    var duration: String
    var fee: String
}



struct TaughtInstrumentView: View {
    @Binding var isShowTaughtInstruments: Bool
    @State private var sortedInstruments: [String] = []
    
    private func loadData() {
        sortedInstruments = InstrumentDataManager.shared.loadInstruments()
        sortedInstruments.sort()
    }
    
    private func deleteInstrument(at indexSet: IndexSet) {
        sortedInstruments.remove(atOffsets: indexSet)
        // Perform any additional deletion logic if needed
    }
    
    
    private func saveData() {
        InstrumentDataManager.shared.saveInstruments(sortedInstruments)
    }
    
    private func addLesson() {
        // Add a default entry or customize as needed
        let newInstrument = ""
        sortedInstruments.append(newInstrument)
    }
    
    var body: some View {
        VStack {
            
            HStack {
                Spacer()
                Button(action: {
                    addLesson()
                }) {
                    Text("Add Instrument")
                        .foregroundColor(.white)
                        .padding(20)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding(40)
                Spacer()
            }
            
            ForEach(0..<sortedInstruments.count, id: \.self) { index in
                HStack {
                    Spacer()
                    TextField("Instrument", text: $sortedInstruments[index])
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 180)
                    Spacer()
                    Button(action: {
                        deleteInstrument(at: IndexSet([index]))
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
                    isShowTaughtInstruments = false
                }) {
                    Text("Save")
                        .foregroundColor(.black)
                        .padding()
                        .background(Color.olive)
                        .cornerRadius(8)
                }
                Button(action: {
                    isShowTaughtInstruments = false
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

struct TaughtInstrumentView_Previews: PreviewProvider {
    static var previews: some View {
        LessonRateView(isShowLessonPrices: .constant(false))
    }
}


