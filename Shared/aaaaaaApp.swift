//
//  EventWidgetsApp.swift
//  Shared
//
//

import SwiftUI

@main
struct EventWidgetsApp: App {
    var body: some Scene {
        WindowGroup {
#if os(iOS)
			NavigationStack {
				MainAppContentView()
			}
#elseif os(macOS)
			MainAppContentView()
				.frame(maxWidth: .infinity, maxHeight: .infinity)
#endif
        }
    }
}
