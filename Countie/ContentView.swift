//
//  ContentView.swift
//  Countie
//
//  Created by Hector Carrion on 11/24/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        EventListView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


//func prettyPrint() {
//    if (UserDefaults(suiteName:"group.com.hectorcarrion.Countie")!.object(forKey: "EVENT_KEY") != nil) && (UserDefaults(suiteName:"group.com.hectorcarrion.Countie")!.object(forKey: "EVDAY_KEY") != nil) && (UserDefaults(suiteName:"group.com.hectorcarrion.Countie")!.object(forKey: "DAYSET_KEY") != nil) {
//        let currentDate = Date()
//
//        let eventName = UserDefaults(suiteName:"group.com.hectorcarrion.Countie")?.object(forKey: "EVENT_KEY") ?? "err load"
//        let eventDate = UserDefaults(suiteName:"group.com.hectorcarrion.Countie")?.object(forKey: "EVDAY_KEY") ?? Date()
//        let startEventDate = Calendar.current.startOfDay(for: eventDate as! Date)
//
//        let startDate = Calendar.current.startOfDay(for: currentDate)
//        let totalDays = Calendar.current.dateComponents([.day], from: startDate, to: startEventDate).day!
//        let setDate = UserDefaults(suiteName:"group.com.hectorcarrion.Countie")?.object(forKey: "DAYSET_KEY") ?? Date()
//
//        if totalDays == 0 {
//            let ratio: Float = 1.0
//        } else {
//            let ratio: Float = Float(100 / totalDays)
//        }
//
//        // Generate a timeline consisting of seven entries a day apart, starting from the current date.
//        for dayOffset in 0 ..< 7 {
//            let entryDate = Calendar.current.date(byAdding: .day, value: dayOffset, to: currentDate)!
//            let trigger = Calendar.current.startOfDay(for: entryDate)
//            let daysElapsed = Calendar.current.dateComponents([.day], from: setDate as! Date, to: trigger).day!
//            let daysRemaining = Calendar.current.dateComponents([.day], from: trigger, to: startEventDate).day!
//            print(daysRemaining)
//        }
//    }
//}
