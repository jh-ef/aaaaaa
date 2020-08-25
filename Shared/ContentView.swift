//
//  ContentView.swift
//  Shared
//
//  Created by jonathan on Aug/25/20.
//

import SwiftUI
import EventKit
import class UIKit.UIApplication
import Combine

extension EKEvent: Identifiable {
    public var id: String {
        self.calendarItemIdentifier
    }
}

struct EventsView: View {
    @State private var events = [EKEvent]()
    private let store = EKEventStore()
    private let eventsChangePublisher = NotificationCenter.default.publisher(for: .EKEventStoreChanged)
    
    func refreshEvents() {
        let calendars = store.calendars(for: .event)
        let predicate = store.predicateForEvents(withStart: Date().addingTimeInterval(-20000), end: Date().addingTimeInterval(20000), calendars: calendars)
        let events = store.events(matching: predicate)
        self.events = events
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(events) { event in
                Text(event.title)
            }
        }
        .padding()
    
        .onAppear() {
            refreshEvents()
        }
        .onReceive(eventsChangePublisher) { _ in
            refreshEvents()
        }
    }
}


struct MainAppContentView: View {
    @State private var authStatus = EKEventStore.authorizationStatus(for: .event)
    
    var body: some View {
        switch authStatus {
        case .authorized:
            EventsView()
        case .notDetermined:
            Button("Authorize") {
                EKEventStore().requestAccess(to: .event) { success, error in
                    authStatus = EKEventStore.authorizationStatus(for: .event)
                }
            }
        default:
            HStack {
                Text("Cannot auth. Go to")
                Link("Settings", destination: URL(string: UIApplication.openSettingsURLString)!)
            }
        }
    }
}

