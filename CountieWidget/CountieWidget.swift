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
    let userDefaultsSuiteName = "group.com.hectorcarrion.Countie"
    let widgetIdentifier: Int
    
    init(widgetIdentifier: Int) {
        self.widgetIdentifier = widgetIdentifier
    }

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), eventName: "Event", configuration: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = createEntry(for: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        
        // Calculate the start of the current day
        let calendar = Calendar.current
        let currentDate = Date()
        let startOfCurrentDay = calendar.startOfDay(for: currentDate)

        // Create entries for the next 7 days
        for dayOffset in 0..<7 {
            guard let entryDate = calendar.date(byAdding: .day, value: dayOffset, to: startOfCurrentDay) else {
                continue
            }

            let entry = createEntry(for: entryDate)
            entries.append(entry)
        }

        // Use the start of the next day as the refresh date for the last entry
        let nextRefreshDate = calendar.date(byAdding: .day, value: 1, to: entries.last?.date ?? currentDate)!

        let timeline = Timeline(entries: entries, policy: .after(nextRefreshDate))
        completion(timeline)
    }
    
    private func createEntry(for date: Date) -> SimpleEntry {
        let eventKey = "EVENT_KEY_\(widgetIdentifier)"
        let eventDateKey = "EVDAY_KEY_\(widgetIdentifier)"
        let daySetKey = "DAYSET_KEY_\(widgetIdentifier)"
        
        guard let userDefaults = UserDefaults(suiteName: userDefaultsSuiteName),
              let eventName = userDefaults.string(forKey: eventKey),
              let eventDate = userDefaults.object(forKey: eventDateKey) as? Date,
              let setDate = userDefaults.object(forKey: daySetKey) as? Date else {
            return SimpleEntry(date: date, eventName: "not onboarded", configuration: nil)
        }

        let startOfEventDate = Calendar.current.startOfDay(for: eventDate)
        let startOfSetDate = Calendar.current.startOfDay(for: setDate)
        let startOfCurrentDate = Calendar.current.startOfDay(for: date)
        
        let totalDays = Calendar.current.dateComponents([.day], from: startOfSetDate, to: startOfEventDate).day ?? 0
        let daysElapsed = Calendar.current.dateComponents([.day], from: startOfSetDate, to: startOfCurrentDate).day ?? 0

        let configuration = EventConfiguration(daysElapsed: daysElapsed, daysRemaining: totalDays - daysElapsed, totalDays: totalDays)
        return SimpleEntry(date: startOfCurrentDate, eventName: eventName, configuration: configuration)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let eventName: String
    let configuration: EventConfiguration?
}

struct EventConfiguration {
    let daysElapsed: Int
    let daysRemaining: Int
    let totalDays: Int
    
    var progress: Float {
        guard totalDays > 0 else { return 1.0 }

        let progressValue = Float(daysElapsed) / Float(totalDays)
        return min(progressValue, 1.0) // Ensures progress does not exceed 1
    }
    
    var isEventToday: Bool {
        daysRemaining == 0
    }
    
    var isPreEvent: Bool {
        daysRemaining > 0
    }
    
    var isPostEvent: Bool {
        daysRemaining < 0
    }
    
    var dayDescription: String {
        switch daysRemaining {
        case 1:
            return "day until"
        case 0:
            return "is today!"
        case -1:
            return "day since"
        default:
            return isPreEvent ? "days until" : "days since"
        }
    }
}

struct CountieWidgetEntryView : View {
    @Environment(\.widgetFamily) var widgetFamily
    var entry: Provider.Entry

    var body: some View {
        if let configuration = entry.configuration {
            configuredBody(configuration: configuration)
                .containerBackground(for: .widget) {
                    Color(UIColor.systemBackground) // or any other color you want for the background
                }
        } else {
            Text("Setup in Countie")
                .multilineTextAlignment(.center)
                .containerBackground(for: .widget) {
                    Color(UIColor.systemBackground) // or any other color you want for the background
                }
        }
    }

    @ViewBuilder
    private func configuredBody(configuration: EventConfiguration) -> some View {
        switch widgetFamily {
        case .accessoryRectangular:
            rectangularFamilyView(configuration: configuration)
                .containerBackground(for: .widget) {
                    Color(UIColor.systemBackground) // or any other color you want for the background
                }
        case .accessoryCircular:
            circularFamilyView(configuration: configuration)
                .containerBackground(for: .widget) {
                    Color(UIColor.systemBackground) // or any other color you want for the background
                }
        case .accessoryInline:
            inlineFamilyView(configuration: configuration)
                .containerBackground(for: .widget) {
                    Color(UIColor.systemBackground) // or any other color you want for the background
                }
        default:
            Text("Not implemented")
        }
    }

    @ViewBuilder
    private func rectangularFamilyView(configuration: EventConfiguration) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            headerView(configuration: configuration)
                .containerBackground(for: .widget) {
                    Color(UIColor.systemBackground) // or any other color you want for the background
                }
            gaugeView(configuration: configuration)
                .containerBackground(for: .widget) {
                    Color(UIColor.systemBackground) // or any other color you want for the background
                }
        }
    }
    
    private func circularFamilyView(configuration: EventConfiguration) -> some View {
        OpenGauge(value: configuration.progress, label: {
            if configuration.isEventToday {
                Image(systemName: "checkmark.circle.fill")
                    .font(.footnote)
            } else {
                Text(String(entry.eventName.prefix(1)))
                    .font(.footnote)
            }
        }, centerView: {
            if configuration.isEventToday {
                Text(String(entry.eventName.prefix(1)))
                    .font(.title)
            } else {
                if configuration.isPostEvent {
                    Text("-" + String(abs(configuration.daysRemaining)))
                        .font(.title)
                } else {
                    Text(String(abs(configuration.daysRemaining)))
                        .font(.title)
                }
            }
        }).containerBackground(for: .widget) {
            Color(UIColor.systemBackground) // or any other color you want for the background
        }
    }
    
    private func inlineFamilyView(configuration: EventConfiguration) -> some View {
        if configuration.isEventToday {
            Text(entry.eventName + " is today!")
        } else if configuration.isPreEvent {
            Text(entry.eventName + " in " + String(configuration.daysRemaining) + " days")
        } else {
            Text(String(configuration.daysRemaining * -1) + " days since " + entry.eventName)
        }
    }
    
    private func headerView(configuration: EventConfiguration) -> some View {
        HStack(alignment: .center) {
            dayCountView(configuration: configuration)
                .containerBackground(for: .widget) {
                    Color(UIColor.systemBackground) // or any other color you want for the background
                }
            eventDescriptionView(configuration: configuration)
                .containerBackground(for: .widget) {
                    Color(UIColor.systemBackground) // or any other color you want for the background
                }
        }
    }
    
    private func dayCountView(configuration: EventConfiguration) -> some View {
        if configuration.isEventToday {
            Text(Image(systemName: "checkmark.circle.fill"))
                .font(.title)
        } else {
            Text(String(abs(configuration.daysRemaining)))
                .font(.title)
        }
    }
    
    private func eventDescriptionView(configuration: EventConfiguration) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            if configuration.isEventToday {
                Text(entry.eventName)
                    .fontWeight(.semibold)
                Text(configuration.dayDescription)
            } else {
                Text(configuration.dayDescription)
                Text(entry.eventName)
                    .fontWeight(.semibold)
            }
        }
    }
    
    private func gaugeView(configuration: EventConfiguration) -> some View {
        Gauge(value: configuration.progress) {}
            .gaugeStyle(.accessoryLinearCapacity)
            .opacity(1)
            .containerBackground(for: .widget) {
                Color(UIColor.systemBackground) // or any other color you want for the background
            }
    }
}


struct CountieWidget1: Widget {
    let kind: String = "CountieWidget1"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider(widgetIdentifier: 1)) { entry in
            CountieWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Countie 1")
        .description("First Countie on your list, open the app to edit.")
        .supportedFamilies([.accessoryRectangular, .accessoryCircular, .accessoryInline])
    }
}

struct CountieWidget2: Widget {
    let kind: String = "CountieWidget2"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider(widgetIdentifier: 2)) { entry in
            CountieWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Countie 2")
        .description("Second Countie on your list, open the app to edit.")
        .supportedFamilies([.accessoryRectangular, .accessoryCircular, .accessoryInline])
    }
}

struct CountieWidget3: Widget {
    let kind: String = "CountieWidget3"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider(widgetIdentifier: 3)) { entry in
            CountieWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Countie 3")
        .description("Third Countie on your list, open the app to edit.")
        .supportedFamilies([.accessoryRectangular, .accessoryCircular, .accessoryInline])
    }
}

struct CountieWidget4: Widget {
    let kind: String = "CountieWidget4"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider(widgetIdentifier: 4)) { entry in
            CountieWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Countie 4")
        .description("Fourth Countie on your list, open the app to edit.")
        .supportedFamilies([.accessoryRectangular, .accessoryCircular, .accessoryInline])
    }
}

struct CountieWidget5: Widget {
    let kind: String = "CountieWidget5"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider(widgetIdentifier: 5)) { entry in
            CountieWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Countie 5")
        .description("Fith Countie on your list, open the app to edit.")
        .supportedFamilies([.accessoryRectangular, .accessoryCircular, .accessoryInline])
    }
}

struct CountieWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Preview for an upcoming event in 3 days
            CountieWidgetEntryView(entry: SimpleEntry(date: Date(), eventName: "Christmas", configuration: EventConfiguration(daysElapsed: 1, daysRemaining: 3, totalDays: 3)))
                .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
                .previewDisplayName("Upcoming Rectangular")
            
            // Preview for an upcoming event in 3 days
            CountieWidgetEntryView(entry: SimpleEntry(date: Date(), eventName: "🎄 Christmas", configuration: EventConfiguration(daysElapsed: 1, daysRemaining: 3, totalDays: 3)))
                .previewContext(WidgetPreviewContext(family: .accessoryCircular))
                .previewDisplayName("Upcoming Circular")
            
            // Preview for an upcoming event in 3 days
            CountieWidgetEntryView(entry: SimpleEntry(date: Date(), eventName: "Christmas 🎄", configuration: EventConfiguration(daysElapsed: 1, daysRemaining: 3, totalDays: 3)))
                .previewContext(WidgetPreviewContext(family: .accessoryInline))
                .previewDisplayName("Upcoming Line")
            
            // Preview for an event happening today
            CountieWidgetEntryView(entry: SimpleEntry(date: Date(), eventName: "Christmas", configuration: EventConfiguration(daysElapsed: 1, daysRemaining: 0, totalDays: 1)))
                .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
                .previewDisplayName("Today Rectangular")
            
            // Preview for an event happening today
            CountieWidgetEntryView(entry: SimpleEntry(date: Date(), eventName: "🎄 Christmas", configuration: EventConfiguration(daysElapsed: 1, daysRemaining: 0, totalDays: 1)))
                .previewContext(WidgetPreviewContext(family: .accessoryCircular))
                .previewDisplayName("Today Circular")
            
            // Preview for an event happening today
            CountieWidgetEntryView(entry: SimpleEntry(date: Date(), eventName: "Christmas 🎄", configuration: EventConfiguration(daysElapsed: 1, daysRemaining: 0, totalDays: 1)))
                .previewContext(WidgetPreviewContext(family: .accessoryInline))
                .previewDisplayName("Today Line")
            
            // Preview for a past event 2 days ago
            CountieWidgetEntryView(entry: SimpleEntry(date: Date(), eventName: "Christmas", configuration: EventConfiguration(daysElapsed: 3, daysRemaining: -2, totalDays: 3)))
                .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
                .previewDisplayName("Past Rectangular")
            
            // Preview for a past event 2 days ago
            CountieWidgetEntryView(entry: SimpleEntry(date: Date(), eventName: "Christmas", configuration: EventConfiguration(daysElapsed: 3, daysRemaining: -2, totalDays: 3)))
                .previewContext(WidgetPreviewContext(family: .accessoryCircular))
                .previewDisplayName("Past Circular")
            
            // Preview for a past event 2 days ago
            CountieWidgetEntryView(entry: SimpleEntry(date: Date(), eventName: "Christmas 🎄", configuration: EventConfiguration(daysElapsed: 3, daysRemaining: -2, totalDays: 3)))
                .previewContext(WidgetPreviewContext(family: .accessoryInline))
                .previewDisplayName("Past Line")
            
            // Preview for the not configured state
            CountieWidgetEntryView(entry: SimpleEntry(date: Date(), eventName: "Not Configured", configuration: nil))
                .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
                .previewDisplayName("Not Configured Rectangular")
            
            // Preview for the not configured state
            CountieWidgetEntryView(entry: SimpleEntry(date: Date(), eventName: "Not Configured", configuration: nil))
                .previewContext(WidgetPreviewContext(family: .accessoryCircular))
                .previewDisplayName("Not Configured Circular")
            
            // Preview for the not configured state
            CountieWidgetEntryView(entry: SimpleEntry(date: Date(), eventName: "Not Configured", configuration: nil))
                .previewContext(WidgetPreviewContext(family: .accessoryInline))
                .previewDisplayName("Not Configured Line")
        }
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
