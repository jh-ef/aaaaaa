//
//  ContentView.swift
//  Shared
//
//  Created by jonathan on Aug/25/20.
//

import SwiftUI
import EventKit
import Combine

#if os(iOS)
import class UIKit.UIApplication
#endif

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
			if !events.isEmpty {
				ForEach(events) { event in
					Text(event.title)
				}
			} else {
				Text("No Events")
					.font(.callout)
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
				.navigationTitle("Events")
		case .notDetermined:
			Button("Authorize") {
				EKEventStore().requestAccess(to: .event) { success, error in
					authStatus = EKEventStore.authorizationStatus(for: .event)
				}
			}
		default:
			HStack {
				Text("Cannot auth. Go to")
				OpenSettingsLink()
			}
		}		
    }
}

struct OpenSettingsLink: View {
	var body: some View {
		let url: URL
		#if os(iOS)
		url = URL(string: UIApplication.openSettingsURLString)!
		#elseif os(macOS)
		url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Calendars")!
		#endif
		return Link("Settings", destination: url)
	}
}
