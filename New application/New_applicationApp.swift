//
//  ReflectApp.swift
//  Reflect
//
//  Created by Jon on 11/4/26.
//

import SwiftUI
import SwiftData

@main
struct ReflectApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var showingSplash = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .opacity(showingSplash ? 0 : 1)
                    .fullScreenCover(isPresented: .init(
                        get: { !hasCompletedOnboarding && !showingSplash },
                        set: { if !$0 { hasCompletedOnboarding = true } }
                    )) {
                        OnboardingView()
                    }

                if showingSplash {
                    SplashScreen {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            showingSplash = false
                        }
                    }
                    .transition(.opacity)
                }
            }
        }
        .modelContainer(for: JournalEntry.self)
    }
}
