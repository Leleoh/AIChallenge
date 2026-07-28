//
//  AIChallengeApp.swift
//  AIChallenge
//
//  Created by Leonel Ferraz Hernandez on 14/07/26.
//

import SwiftUI
import AppIntents

@main
struct AIChallengeApp: App {
    init() {
        MOOVNIShortcuts.updateAppShortcutParameters()
    }
    
    var body: some Scene {
        WindowGroup {
            CowsGameMenuView(isPresented: .constant(true))
        }
    }
}
