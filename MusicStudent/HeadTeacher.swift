//
//  HeadTeacher.swift
//  MusicStudent
//
//  Created by Thomas Radford on 29/01/2024.
//

import Foundation

struct HeadTeacher: Codable, Identifiable, Hashable {
    var id = UUID()
    var  companyName: String
    var calendarName: String
    var   teacherNumber: String
    var    firstName: String
    var    lastName: String
    var    phoneNumber: String
    var    phoneNumber2: String
    var    street1: String
    var    street2: String
    var    city: String
    var    county: String
    var    country: String
    var    postalCode: String
    var    email: String
    var    active: Bool
    var    rate: String
    var payableName: String
    var accountNumber: String
    var sortCode: String
    
    
    static let daysOfWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
    static let extraItemStatus = ["Suggested", "Ordered", "Delivered", "Paid", "Other"]

    
    
    
}


struct Rates {
    static func rateTable(duration: String) -> String {
        
        switch duration{
        case "20":
            return "12";
        case "15":
            return "15";
        case "30":
            return "20";
        case "45":
            return "25";
        case "60":
            return "30";
        case "90":
            return "50"
        case "240":
            return "122"
        default:
            return "0"
              }
    }
    
    static func mulitplier(location: String) -> Int {
        switch location{
        case "90 Romsey Road":
            return 3;
        default:
            return 1;
        }
    }
}
/*
struct FindCalendarID {
    static func CalendarID() -> String {
        let calendarName = "MapleOaks Teaching"
        return calendarName
    }
}

*/
