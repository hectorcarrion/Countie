//
//  TestWidgets.swift
//  CountieWidgetExtension
//
//  Created by yakk on 12/24/23.
//

import WidgetKit
import SwiftUI

// Define a simple provider that does not use UserDefaults
struct TestProvider: TimelineProvider {
    func placeholder(in context: Context) -> TestEntry {
        TestEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (TestEntry) -> ()) {
        let entry = TestEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = TestEntry(date: Date())
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

// Define a simple timeline entry
struct TestEntry: TimelineEntry {
    let date: Date
}

// Define a simple widget entry view
struct SimpleCountieWidgetEntryView : View {
    var entry: TestProvider.Entry

    var body: some View {
        Text(entry.date, style: .time)
            .multilineTextAlignment(.center)
            .containerBackground(for: .widget) {
                Color(UIColor.systemBackground) // or any other color you want for the background
            }
    }
}

// Define a simple widget for each family
struct SimpleAccessoryInlineWidget: Widget {
    let kind: String = "SimpleAccessoryInlineWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TestProvider()) { entry in
            SimpleCountieWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Simple Inline Widget")
        .description("This is a simple inline widget.")
        .supportedFamilies([.accessoryInline])
    }
}

struct SimpleAccessoryCircularWidget: Widget {
    let kind: String = "SimpleAccessoryCircularWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TestProvider()) { entry in
            SimpleCountieWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Simple Circular Widget")
        .description("This is a simple circular widget.")
        .supportedFamilies([.accessoryCircular])
    }
}

struct SimpleAccessoryRectangularWidget: Widget {
    let kind: String = "SimpleAccessoryRectangularWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TestProvider()) { entry in
            SimpleCountieWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Simple Rectangular Widget")
        .description("This is a simple rectangular widget.")
        .supportedFamilies([.accessoryRectangular])
    }
}

