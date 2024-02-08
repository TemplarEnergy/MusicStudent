//
//  MusicStudentApp.swift
//  MusicStudent
//
//  Created by Thomas Radford on 21/12/2023.
//
import SwiftUI
import Accounts

@main
struct StudentDatabaseApp: App {
    @State private var users: [Student] = [] // Initialize the users array 

    var body: some Scene {
        WindowGroup {
            
            ContentView()
        }
        .windowStyle(HiddenTitleBarWindowStyle()) // Hide the default title bar
        .windowToolbarStyle(UnifiedCompactWindowToolbarStyle())
    }
}

