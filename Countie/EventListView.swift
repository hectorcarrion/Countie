//
//  EventListView.swift
//  Countie
//
//  Created by yakk on 12/23/23.
//

import SwiftUI

struct EventListView: View {
    @State private var showingAddEventView = false
    @State private var editingEvent: Event?
    @ObservedObject private var eventsManager = EventsManager.shared

    var body: some View {
        NavigationView {
            Group {
                if eventsManager.events.isEmpty {
                    emptyStateView
                } else {
                    listContent
                }
            }
            .navigationTitle("Counties")
            .navigationBarItems(trailing: addButton)
            .onAppear(perform: eventsManager.loadEvents)
            .refreshable {
                eventsManager.loadEvents()
            }
            .sheet(isPresented: $showingAddEventView) {
                EventEditView()
            }
            .sheet(item: $editingEvent) { event in
                EventEditView(event: event)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private var listContent: some View {
        List {
            ForEach(eventsManager.events) { event in
                Button(action: {
                    self.editingEvent = event
                }) {
                    HStack {
                        Text(event.name)
                        Spacer()
                        Text(event.date, formatter: Self.dateFormatter)
                    }
                }
            }
            .onDelete(perform: deleteEvent)
            if eventsManager.events.count > 0 && eventsManager.events.count < 5 {
                Text("Tip: to add widgets to your lock screen, tap and hold it, then press 'Customize'")
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .onTapGesture {
                        UIApplication.shared.open(URL(string: "https://youtube.com/shorts/1RuF2LUAuWQ?si=bUmS5_VNyxief5xl")!, options: [:])
                    }
            } else if eventsManager.events.count == 5 {
                Text("Countie currently supports up to 5 widgets, you can tap to edit or swipe to delete")
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private var addButton: some View {
        Button(action: { showingAddEventView = true }) {
            Image(systemName: "plus.circle.fill")
        }
        .disabled(eventsManager.events.count >= eventsManager.maxWidgets)
    }

    private func deleteEvent(at offsets: IndexSet) {
        offsets.forEach { index in
            let event = eventsManager.events[index]
            eventsManager.delete(event: event)
        }
    }

    private static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Text("Hello 👋🏼")
                .font(.title)
                .padding(.top, 50)
            
            Text("Tap the '+' button to add a new Countie")
                .padding(.horizontal)
                .multilineTextAlignment(.center)
            
            Text("Tip: you can add ✈️🎄🎂 to their names!")
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
    }
}

struct EventListView_Previews: PreviewProvider {
    static var previews: some View {
        EventListView()
    }
}


