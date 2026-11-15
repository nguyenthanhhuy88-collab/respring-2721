// SPDX-License-Identifier: GPL-3.0-only
// RespringApp.swift — Respring 27, entry point.

import SwiftUI

@main
struct RespringApp: App {
    @StateObject private var model = NeoSpringModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(model)
        }
    }
}
