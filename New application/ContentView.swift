//
//  ContentView.swift
//  Reflect
//
//  Created by Jon on 11/4/26.
//

import SwiftUI
import SwiftData

enum AppTab: Hashable {
    case dashboard
    case journal
    case calendar
    case insights
}

struct ContentView: View {
    @State private var selectedTab: AppTab = .dashboard
    @State private var showingSettings = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            TabView(selection: $selectedTab) {
                Tab("Home", systemImage: "house.fill", value: .dashboard) {
                    DashboardView(selectedTab: $selectedTab)
                }

                Tab("Journal", systemImage: "book.closed", value: .journal) {
                    JournalListView()
                }

                Tab("Calendar", systemImage: "calendar", value: .calendar) {
                    CalendarView()
                }

                Tab("Insights", systemImage: "chart.line.uptrend.xyaxis", value: .insights) {
                    InsightsView()
                }
            }
            .tint(.reflectAccent)

            // Settings button overlay
            Button {
                showingSettings = true
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.body)
                    .foregroundStyle(Color.reflectTextSecondary)
                    .padding(Spacing.sm)
                    .background(
                        Circle()
                            .fill(Color.reflectSurface.opacity(0.8))
                    )
            }
            .buttonStyle(.plain)
            .padding(.trailing, Spacing.md)
            .padding(.top, Spacing.xs)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: JournalEntry.self, inMemory: true)
}
