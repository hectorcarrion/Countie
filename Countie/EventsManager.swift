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
    private let iCloudStore = NSUbiquitousKeyValueStore.default
    public let maxWidgets = 5

    @Published var events: [Event] = []

    private init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(ubiquitousStoreDidChange),
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: iCloudStore
        )
        iCloudStore.synchronize()
        loadEvents()
    }

    @objc private func ubiquitousStoreDidChange(notification: Notification) {
        // When iCloud keys change, update local user defaults
        loadEvents()
    }

    func save(event: Event) {
        if let index = events.firstIndex(where: { $0.id == event.id }) {
            events[index] = event
        } else {
            if events.count < maxWidgets {
                events.append(event)
            } else {
                print("Maximum number of events reached.")
                return
            }
        }
        saveEventsToUserDefaults()
        saveEventsToiCloud()
        WidgetCenter.shared.reloadAllTimelines()
    }

    func delete(event: Event) {
        events.removeAll(where: { $0.id == event.id })
        saveEventsToUserDefaults()
        saveEventsToiCloud()
        WidgetCenter.shared.reloadAllTimelines()
    }

    private func saveEventsToUserDefaults() {
        print("saving to local")
        for (index, event) in events.enumerated() {
            print(event)
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
    
    private func saveEventsToiCloud() {
        print("Saving to iCloud")
        let eventsData = events.map { try? JSONEncoder().encode($0) }
        iCloudStore.set(eventsData, forKey: "events")
        iCloudStore.synchronize() // Force the data to be pushed to iCloud
    }

    func loadEvents() {
        // Load from iCloud first
        if let eventsData = iCloudStore.array(forKey: "events") as? [Data] {
            events = eventsData.compactMap { data in
                try? JSONDecoder().decode(Event.self, from: data)
            }
            print("Downloaded Events:")
            print(events)
            print("Empty?")
            print(events.isEmpty)
            print()
            
            if !events.isEmpty {
                // Successfully loaded from iCloud, update UserDefaults
                print("loading from icloud")
                saveEventsToUserDefaults()
                return
            } else {
                
            }
        }
        
        // If iCloud data is not available, load from UserDefaults
        print("loading form local")
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
        saveEventsToiCloud() // Sync the loaded UserDefaults data to iCloud
    }
}

