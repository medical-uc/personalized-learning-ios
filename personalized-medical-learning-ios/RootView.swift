//
//  RootView.swift
//  personalized-medical-learning-ios
//

import SwiftUI

struct RootView: View {
    var onLogOut: () -> Void = {}

    @State private var selection: SidebarItem = .dashboard
    @State private var isQuizInProgress = false

    var body: some View {
        HStack(spacing: 0) {
            SidebarView(selection: $selection)

            Group {
                switch selection {
                case .dashboard:
                    DashboardView()
                case .quiz:
                    if isQuizInProgress {
                        QuizView(onBack: {
                            isQuizInProgress = false
                            selection = .dashboard
                        })
                    } else {
                        QuizSetupView(
                            onBack: { selection = .dashboard },
                            onStart: { _, _ in isQuizInProgress = true }
                        )
                    }
                case .flashcards:
                    FlashcardView(onBack: { selection = .dashboard })
                case .subjects:
                    SubjectsView(onBack: { selection = .dashboard })
                case .bookmarks:
                    BookmarkView(onBack: { selection = .dashboard })
                case .history:
                    HistoryView(onBack: { selection = .dashboard })
                case .settings:
                    SettingsView(onLogOut: onLogOut)
                default:
                    DashboardView()
                }
            }
        }
        .background(Theme.bg)
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview {
    RootView()
}
