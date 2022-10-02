//
//  EventView.swift
//  EventWidgets
//
//

import SwiftUI
import EventKit

struct EventView: View {
	let event: EKEvent
	
	var body: some View {
		VStack(alignment: .leading) {
			Text(event.title)
				.font(.subheadline).bold()
			HStack {
				Circle()
					.fill(event.availability.color)
					.frame(width: 10, height: 10)
				
				Text(event.startDate...event.endDate)
				
				Spacer()
			}.font(.caption)
		}
	}
}
