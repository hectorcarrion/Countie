//
//  CountieWidget.swift
//  CountieWidget
//
//  Created by Hector Carrion on 11/24/22.
//

import WidgetKit
import SwiftUI
import Foundation

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), daysElapsed: 1, daysRemaining: 42, totalDays: 2, eventName: "Event")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        
        if (UserDefaults(suiteName:"group.com.hectorcarrion.Countie")!.object(forKey: "EVENT_KEY") != nil) && (UserDefaults(suiteName:"group.com.hectorcarrion.Countie")!.object(forKey: "EVDAY_KEY") != nil) && (UserDefaults(suiteName:"group.com.hectorcarrion.Countie")!.object(forKey: "DAYSET_KEY") != nil) {
            
            
            let currentDate = Date()
            let eventName = UserDefaults(suiteName:"group.com.hectorcarrion.Countie")?.object(forKey: "EVENT_KEY") ?? "err load"
            let eventDate = UserDefaults(suiteName:"group.com.hectorcarrion.Countie")?.object(forKey: "EVDAY_KEY") ?? Date()
            
            let today = UserDefaults(suiteName:"group.com.hectorcarrion.Countie")!.object(forKey: "EVENT_DAY") ?? false
            
            if today as! Bool == true {
                let entry = SimpleEntry(date: Date(), daysElapsed: 50, daysRemaining: 0, totalDays: 0, eventName: eventName as! String)
                completion(entry)
            } else {
                let startDate = Calendar.current.startOfDay(for: currentDate)
                let totalDays = Calendar.current.dateComponents([.day], from: startDate, to: eventDate as! Date).day!
                let setDate = UserDefaults(suiteName:"group.com.hectorcarrion.Countie")?.object(forKey: "DAYSET_KEY") ?? Date()
                let daysElapsed = Calendar.current.dateComponents([.day], from: setDate as! Date, to: Date() ).day!
                
                let entry = SimpleEntry(date: currentDate, daysElapsed: daysElapsed, daysRemaining: totalDays, totalDays: totalDays, eventName: eventName as! String)
                completion(entry)
            }
            
        } else {
            let entry = SimpleEntry(date: Date(), daysElapsed: 1, daysRemaining: 14, totalDays: 1, eventName: "not onboarded")
            completion(entry)
        }
        
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        let currentDate = Date()
    
        if (UserDefaults(suiteName:"group.com.hectorcarrion.Countie")!.object(forKey: "EVENT_KEY") != nil) && (UserDefaults(suiteName:"group.com.hectorcarrion.Countie")!.object(forKey: "EVDAY_KEY") != nil) && (UserDefaults(suiteName:"group.com.hectorcarrion.Countie")!.object(forKey: "DAYSET_KEY") != nil) {
            
            let eventName = UserDefaults(suiteName:"group.com.hectorcarrion.Countie")?.object(forKey: "EVENT_KEY") ?? "err load"
            let eventDate = UserDefaults(suiteName:"group.com.hectorcarrion.Countie")?.object(forKey: "EVDAY_KEY") ?? Date()
            let startEventDate = Calendar.current.startOfDay(for: eventDate as! Date)
            
            let startDate = Calendar.current.startOfDay(for: currentDate)
            let totalDays = Calendar.current.dateComponents([.day], from: startDate, to: startEventDate).day!
            let setDate = UserDefaults(suiteName:"group.com.hectorcarrion.Countie")?.object(forKey: "DAYSET_KEY") ?? Date()
            
            //let ratio: Float = Float(100 / totalDays) // div by zero
            
            // Generate a timeline consisting of seven entries a day apart, starting from the current date.
            for dayOffset in 0 ..< 7 {
                let entryDate = Calendar.current.date(byAdding: .day, value: dayOffset, to: currentDate)!
                let trigger = Calendar.current.startOfDay(for: entryDate)
                let daysElapsed = Calendar.current.dateComponents([.day], from: setDate as! Date, to: trigger).day!
                let daysRemaining = Calendar.current.dateComponents([.day], from: trigger, to: startEventDate).day!
                
                let entry = SimpleEntry(date: trigger, daysElapsed: daysElapsed, daysRemaining: daysRemaining, totalDays: totalDays, eventName: eventName as! String)
                entries.append(entry)
            }
            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
        } else {
            entries.append(SimpleEntry(date: currentDate, daysElapsed: 1, daysRemaining: 14, totalDays: 2, eventName: "not onboarded"))
            let upDate = Calendar.current.date(byAdding: .second, value: 30, to: currentDate)!
            let timeline = Timeline(entries: entries, policy: .after(upDate))
            completion(timeline)
        }
    }
}

struct SimpleEntry: TimelineEntry {
    // custom date object (ICCV date)
    let date: Date
    let daysElapsed: Int
    let daysRemaining: Int
    let totalDays: Int
    let eventName: String
}

struct CountieWidgetEntryView : View {
    @Environment(\.widgetFamily) var widgetFamily
    var entry: Provider.Entry
    var body: some View {
        if entry.eventName == "not onboarded" {
            Text("Open Countie to set-up")
                .multilineTextAlignment(.center)
        } else {
            switch widgetFamily {
                case .accessoryRectangular:

                    // Interesting choice here between leading and center
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(alignment: .center) {
                            if entry.daysRemaining >= 1 || entry.daysRemaining < 0 {
                                Text(String(abs(entry.daysRemaining)))
                                    .font(.title)
                            } else if entry.daysRemaining == 0 {
    //                            Image(systemName: "checkmark.circle.fill")
    //                                .font(.custom("check", size: 30))
                                Text("🎉")
                                    .font(.title)
                            }
                            //Spacer()
                            VStack(alignment: .leading, spacing: 2) {
                                if entry.daysRemaining == 1 {
                                    Text("day until")
                                } else if entry.daysRemaining >= 1 {
                                    Text("days until")
                                } else if entry.daysRemaining == -1 {
                                    Text("day since")
                                } else if entry.daysRemaining == 0 {
                                    Text("today is")
                                } else {
                                    Text("days since")
                                }
                                Text(entry.eventName)
                                    .fontWeight(.semibold)
                            }
                        }
                        if entry.daysRemaining < 0 {
                            Gauge(value: 1.0) {}
                                .gaugeStyle(.accessoryLinearCapacity)
                                .opacity(1)
                        } else if entry.totalDays == 0 {
                            Gauge(value: 1.0) {}
                                .gaugeStyle(.accessoryLinearCapacity)
                                .opacity(1)
                        } else {
                            let ratio: Float = Float(100/entry.totalDays)
                            Gauge(value: (ratio * Float(entry.daysElapsed))/100) {}
                                .gaugeStyle(.accessoryLinearCapacity)
                                .opacity(1)
                        }
                    }
                    
                default:
                    Text("Not implemented")
            }
        }
    }
}

struct CountieWidget: Widget {
    let kind: String = "CountieWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            CountieWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Countie")
        .description("Select your countdown or countup widget.")
        .supportedFamilies([.accessoryRectangular])
    }
}

struct CountieWidget_Previews: PreviewProvider {
    static var previews: some View {
        CountieWidgetEntryView(entry: SimpleEntry(date: Date(), daysElapsed: 50, daysRemaining: -2, totalDays: 0, eventName: "Disney! ✈️"))
            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
            .previewDisplayName("Rectangular")
    }
}


//let currentDate = Date()
//let formatter = DateFormatter()
//formatter.dateFormat = "yyyy/MM/dd HH:mm"
//let event = formatter.date(from: UserDefaults.standard.string(forKey: "DATE_KEY")!)! // clean !
//let eventName = UserDefaults.standard.string(forKey: "NAME_KEY")! // clean this up
//print(UserDefaults.standard.string(forKey: "DATE_KEY")!)
//print(event)
//print(eventName)
