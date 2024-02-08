import SwiftUI

struct FilterOptionsView: View {
    struct FilterOptions: Equatable {
        var filterDay: String?
        var filterInstrument: String?
        var filterActive: Bool?  // Change to non-optional Bool
    }

    @Binding var filterDay: String?
    @Binding var filterInstrument: String?
    @Binding var filterActive: Bool? // Change to non-optional Bool


    @State private var selectedDay: String = ""
    @State private var selectedInstrument: String = ""

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Picker("Day", selection: $selectedDay) {
                    Text("All").tag("")
                    Text("Monday").tag("Monday")
                    Text("Tuesday").tag("Tuesday")
                    Text("Wednesday").tag("Wednesday")
                    Text("Thursday").tag("Thursday")
                    Text("Friday").tag("Friday")
                }
                .onChange(of: selectedDay) { newValue in
                    self.filterDay = newValue.isEmpty ? nil : newValue
                }
                .padding()
                Spacer()

                Spacer()

                Toggle("Active Students", isOn: Binding(
                    get: { self.filterActive ?? true },
                    set: { self.filterActive = $0 }
                ))

                Spacer()
                Spacer()

                Picker("Instrument", selection: $selectedInstrument) {
                    Text("All").tag("")
                    Text("Violin").tag("Violin")
                    Text("Viola").tag("Viola")
                    Text("Cello").tag("Cello")
                    Text("Voice").tag("Voice")
                    Text("Piano").tag("Piano")
                    Text("Trio").tag("Trio")
                    Text("Ensemble").tag("Ensemble")
                    Text("Pari").tag("Pari")
                }
                .onChange(of: selectedInstrument) { newValue in
                    self.filterInstrument = newValue.isEmpty ? nil : newValue
                }
                .padding()
                Spacer()
 
            }
        }
    }
}

struct FilterOptionsView_Previews: PreviewProvider {
    static var previews: some View {
        FilterOptionsView(
            filterDay: .constant(nil),
            filterInstrument: .constant(nil),
            filterActive: .constant(true)
        )
    }
}

