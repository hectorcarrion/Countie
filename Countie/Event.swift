//
//  Event.swift
//  Countie
//
//  Created by yakk on 12/23/23.
//

import Foundation

//enum WidgetFamily: String, Codable, CaseIterable {
//    case accessoryCircular = "Circular"
//    case accessoryRectangular = "Rectangular"
//    case accessoryInline = "Inline"
//    
//    var displayName: String {
//        switch self {
//        case .accessoryCircular:
//            return "Circular"
//        case .accessoryRectangular:
//            return "Rectangular"
//        case .accessoryInline:
//            return "Inline"
//        }
//    }
//    
//    var displayImage: String {
//        switch self {
//        case .accessoryCircular:
//            return "circle"
//        case .accessoryRectangular:
//            return "rectangle"
//        case .accessoryInline:
//            return "minus"
//        }
//    }
//}

struct Event: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var date: Date
    
    // Computed property to format the date as a string for display
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    // Computed property to determine if the event is today
    var isToday: Bool {
        return Calendar.current.isDateInToday(date)
    }
}
