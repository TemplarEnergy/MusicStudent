//
//  MusicStudentApp.swift
//  MusicStudent
//
//  Created by Thomas Radford on 21/12/2023.
//
import SwiftUI

@main
struct StudentDatabaseApp: App {
    @State private var users: [User] = [] // Initialize the users array

    var body: some Scene {
        WindowGroup {
            UserListView()
        }
    }
}

