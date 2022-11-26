//
//  ContentView.swift
//  Countie
//
//  Created by Hector Carrion on 11/24/22.
//

import SwiftUI
import Foundation
import WidgetKit

extension Date: RawRepresentable {
    private static let formatter = ISO8601DateFormatter()
    
    public var rawValue: String {
        Date.formatter.string(from: self)
    }
    
    public init?(rawValue: String) {
        self = Date.formatter.date(from: rawValue) ?? Date()
    }
}

struct ContentView: View {
    @State public var eventDate = Date()
    @State public var eventName = ""
    @AppStorage("NAME_KEY") var savedName = ""
    @AppStorage("DATE_KEY") var savedDate = Date()
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        var update: Bool = false
        
        VStack {
            Text("1. Enter event name and date")
                .font(.title)
                .multilineTextAlignment(.center)
            Text("Psst, you can use emoji 🥳")
            TextField("Name...", text: $eventName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(.title2)
                .onChange(of: eventName) { text in
                    self.savedName = eventName
                    UserDefaults(suiteName:"group.com.hectorcarrion.Countie")!.set(eventName, forKey: "EVENT_KEY")
                    //WidgetCenter.shared.reloadAllTimelines()
                    update = true
                }
                .onAppear {
                    self.eventName = savedName
                }
            DatePicker("Enter event date", selection: $eventDate, displayedComponents: [.date])
                .datePickerStyle(GraphicalDatePickerStyle())
                //.frame(maxHeight: 400)
                .onChange(of: eventDate) { text in
                    self.savedDate = eventDate
                    let a = Calendar.current.startOfDay(for: eventDate)
                    let b = Calendar.current.startOfDay(for: Date())
                    if a == b {
                        print("Today is event day")
                        UserDefaults(suiteName:"group.com.hectorcarrion.Countie")!.set(true, forKey: "EVENT_DAY")
                    } else {
                        UserDefaults(suiteName:"group.com.hectorcarrion.Countie")!.set(false, forKey: "EVENT_DAY")
                    }
                    UserDefaults(suiteName:"group.com.hectorcarrion.Countie")!.set(eventDate, forKey: "EVDAY_KEY")
                    UserDefaults(suiteName:"group.com.hectorcarrion.Countie")!.set(Date(), forKey: "DAYSET_KEY")
                    self.hideKeyboard()
                    //WidgetCenter.shared.reloadAllTimelines()
                    //prettyPrint()
                    update = true
                }
                .onAppear {
                    self.eventDate = savedDate
                }
            Text("2. Customize lock screen to set widget")
                .font(.headline)
                .multilineTextAlignment(.center)
            Text("You can also set past dates for a countup")
            //Text("Many changes continously may require a second to update (system refresh budget limits)...")
                .multilineTextAlignment(.center)
            Spacer()
                .onChange(of: scenePhase) { newPhase in
                    if newPhase == .active {
                        print("Active")
                    } else if newPhase == .inactive {
                        print("Inactive")
                        if update == true {
                            WidgetCenter.shared.reloadAllTimelines()
                            update = false
                        }
                    } else if newPhase == .background {
                        print("Background")
                    }
                    
                }
        }.padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif


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
