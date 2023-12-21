// UserListView.swift

import SwiftUI

struct UserListView: View {
    @State private var users: [User] = []
    @State private var selectedUser: User?

    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                NavigationLink(destination: ContentView(
                    selectedUser: $selectedUser,
                    users: $users
                )) {
                    Text("Add New User")
                }
                Spacer()
                List(users, id: \.id) { user in
                    Button(action: {
                        selectedUser = user
                    }) {
                        HStack(alignment: .top) {
                            Text("\(user.firstName) \(user.lastName)")
                        }
                    }
                }
            }
            .navigationTitle("Student List")
            .onAppear {
                loadData()
            }
        }
    }

    private func loadData() {
        if let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("student_database.json") {
            do {
                let data = try Data(contentsOf: fileURL)
                let decoder = JSONDecoder()
                users = try decoder.decode([User].self, from: data)
            } catch {
                print("Error loading data: \(error.localizedDescription)")
            }
        }
    }
}

struct UserListView_Previews: PreviewProvider {
    static var previews: some View {
        UserListView()
    }
}

