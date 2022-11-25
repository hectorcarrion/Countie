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

    var body: some View {
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
                    WidgetCenter.shared.reloadAllTimelines()
                }
                .onAppear {
                    self.eventName = savedName
                }
            DatePicker("Enter event date", selection: $eventDate, displayedComponents: [.date])
                .datePickerStyle(GraphicalDatePickerStyle())
                //.frame(maxHeight: 400)
                .onChange(of: eventDate) { text in
                    self.savedDate = eventDate
                    UserDefaults(suiteName:"group.com.hectorcarrion.Countie")!.set(eventDate, forKey: "EVDAY_KEY")
                    UserDefaults(suiteName:"group.com.hectorcarrion.Countie")!.set(Date(), forKey: "DAYSET_KEY")
                    self.hideKeyboard()
                    WidgetCenter.shared.reloadAllTimelines()
                }
                .onAppear {
                    self.eventDate = savedDate
                }
            Text("2. Customize lock screen to set widget")
                .font(.headline)
                .multilineTextAlignment(.center)
            Text("You can also set past dates for a countup")
            Spacer()
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
