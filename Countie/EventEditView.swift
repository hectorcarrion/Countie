//
//  EventEditView.swift
//  Countie
//
//  Created by yakk on 12/23/23.
//

import SwiftUI

struct EventEditView: View {
    var event: Event?
    @State private var name: String = ""
    @State private var date: Date = Date()
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    TextField("Name...", text: $name)
                    DatePicker("Enter event date", selection: $date, displayedComponents: [.date])
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .onChange(of: date) {
                            hideKeyboard()
                        }
                }
                .navigationTitle(event == nil ? "New Countie 🤩" : "Edit Countie ✏️")
                .navigationBarItems(leading: cancelButton, trailing: saveButton)
                .onAppear(perform: setup)
                
                Text("Tip: circular widgets adopt the first letter (or emoji) in their name as their label")
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private var cancelButton: some View {
        Button("Cancel") {
            presentationMode.wrappedValue.dismiss()
        }
    }

    private var saveButton: some View {
        Button("Save") {
            let eventToSave = Event(id: event?.id ?? UUID(), name: name, date: date)
            EventsManager.shared.save(event: eventToSave)
            presentationMode.wrappedValue.dismiss()
        }
        .disabled(name.isEmpty)
    }

    private func setup() {
        if let event = event {
            name = event.name
            date = event.date
        }
    }
}

struct EventEditView_Previews: PreviewProvider {
    static var previews: some View {
        EventEditView()
    }
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
