//
//  ContentView.swift
//  Shared
//
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

extension Date {
	func weekBoundaries() -> (Date, Date)? {
		let cal = Calendar.autoupdatingCurrent
		let components = cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
		guard let startOfWeek = cal.date(from: components) else {
			return nil
		}

		let endOfWeekOffset = cal.weekdaySymbols.count - 1
		let endOfWeekComponents = DateComponents(day: endOfWeekOffset, hour: 23, minute: 59, second: 59)
		guard let endOfWeek = cal.date(byAdding: endOfWeekComponents, to: startOfWeek) else {
			return nil
		}
		return (startOfWeek, endOfWeek)
	}
}

struct EventsList: View {
    @State private var events = [EKEvent]()
    private let store = EKEventStore()
    private let eventsChangePublisher = NotificationCenter.default.publisher(for: .EKEventStoreChanged)
    
    func refreshEvents() {
        let calendars = store.calendars(for: .event)
		let date = Date()
		let fallbackInterval: TimeInterval = 3600 * 24 * 3.5
		let (start, end) = date.weekBoundaries() ??
			// As fallback to proper calendar calculations, use ~7 days around date
			(date.addingTimeInterval(-fallbackInterval), date.addingTimeInterval(fallbackInterval))
        let predicate = store.predicateForEvents(withStart: start, end: end, calendars: calendars)
        let events = store.events(matching: predicate)
        self.events = events
    }
    
    var body: some View {
		List {
		if !events.isEmpty {
			ForEach(events) { event in
				EventView(event: event)
			}
		} else {
			Text("No Events")
				.font(.callout)
			}
		}.listStyle(.inset)
        .padding()
		.refreshable {
			refreshEvents()
		}
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
			EventsList()
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
