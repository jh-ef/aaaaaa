//
//  EventIndicators.swift
//  EventWidgets
//
//

import SwiftUI
import EventKit

extension EKEventAvailability {
	var color: Color {
		switch self {
		case .notSupported:
			return .gray
		case .busy:
			return .red
		case .free:
			return .clear
		case .tentative:
			return .blue
		case .unavailable:
			return .red
		@unknown default:
			return .clear
		}
	}
}
