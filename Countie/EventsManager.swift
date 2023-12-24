//
//  EventsViewModel.swift
//  Countie
//
//  Created by yakk on 12/23/23.
//

import Foundation
import WidgetKit

extension Date: RawRepresentable {
    public var rawValue: String {
        Self.formatter.string(from: self)
    }
    
    public init?(rawValue: String) {
        guard let date = Self.formatter.date(from: rawValue) else {
            return nil
        }
        self = date
    }
    
    private static let formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
}

class EventsManager: ObservableObject {
    static let shared = EventsManager()
    private let userDefaults = UserDefaults(suiteName: "group.com.hectorcarrion.Countie")
    public let maxWidgets = 5

    @Published var events: [Event] = []

    private init() {
        loadEvents()
    }

    func save(event: Event) {
        if let index = events.firstIndex(where: { $0.id == event.id }) {
            events[index] = event
        } else {
            if events.count < maxWidgets {
                events.append(event)
            } else {
                // Handle the case where the limit is reached
                print("Maximum number of events reached.")
                return
            }
        }
        saveEventsToUserDefaults()
        WidgetCenter.shared.reloadAllTimelines()
    }

    func delete(event: Event) {
        events.removeAll(where: { $0.id == event.id })
        saveEventsToUserDefaults()
        WidgetCenter.shared.reloadAllTimelines()
    }

    private func saveEventsToUserDefaults() {
        for (index, event) in events.enumerated() {
            let eventKey = "EVENT_KEY_\(index + 1)"
            let eventDateKey = "EVDAY_KEY_\(index + 1)"
            let daySetKey = "DAYSET_KEY_\(index + 1)"
            
            userDefaults?.set(event.name, forKey: eventKey)
            userDefaults?.set(event.date, forKey: eventDateKey)
            // Assuming `setDate` should be the current date when saving
            userDefaults?.set(Date(), forKey: daySetKey)
        }

        // Clear data for any unused widget identifiers
        if events.count < maxWidgets {
            for i in (events.count + 1)...maxWidgets {
                userDefaults?.removeObject(forKey: "EVENT_KEY_\(i)")
                userDefaults?.removeObject(forKey: "EVDAY_KEY_\(i)")
                userDefaults?.removeObject(forKey: "DAYSET_KEY_\(i)")
            }
        }
    }

    func loadEvents() {
        var loadedEvents = [Event]()
        for i in 1...maxWidgets {
            let eventKey = "EVENT_KEY_\(i)"
            let eventDateKey = "EVDAY_KEY_\(i)"
            
            if let name = userDefaults?.string(forKey: eventKey),
               let date = userDefaults?.object(forKey: eventDateKey) as? Date {
                let event = Event(id: UUID(), name: name, date: date)
                loadedEvents.append(event)
            }
        }
        events = loadedEvents
    }
}

