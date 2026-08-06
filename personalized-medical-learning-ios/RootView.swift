//
//  RootView.swift
//  personalized-medical-learning-ios
//

import SwiftUI

struct RootView: View {
    var onLogOut: () -> Void = {}

    @State private var selection: SidebarItem = .dashboard
    @State private var activeTopicPath: String?
    @State private var activeQuestionCount: Int = 10
    @State private var isQuizInProgress = false
    @State private var pendingSelection: SidebarItem?
    @State private var flashcardTopicPath: String?

    private func requestSelect(_ item: SidebarItem) {
        guard item != selection else { return }
        if isQuizInProgress && selection == .quiz {
            pendingSelection = item
        } else {
            selection = item
        }
    }

    var body: some View {
        HStack(spacing: 0) {
            SidebarView(selection: selection, onSelect: requestSelect)

            Group {
                switch selection {
                case .dashboard:
                    DashboardView(
                        onPracticeTopic: { topic in
                            activeTopicPath = topic.path
                            activeQuestionCount = 10
                            selection = .quiz
                        },
                        onViewAllWeakAreas: { selection = .mastery }
                    )
                case .quiz:
                    if let activeTopicPath {
                        QuizView(
                            topicPath: activeTopicPath,
                            questionCount: activeQuestionCount,
                            onBack: {
                                self.activeTopicPath = nil
                                selection = .dashboard
                            },
                            onProgressChange: { isQuizInProgress = $0 }
                        )
                    } else {
                        QuizSetupView(
                            onBack: { selection = .dashboard },
                            onStart: { topic, settings in
                                activeTopicPath = topic.path
                                activeQuestionCount = settings.questionCount
                            }
                        )
                    }
                case .flashcards:
                    if let flashcardTopicPath {
                        FlashcardView(topicPath: flashcardTopicPath, onBack: { selection = .dashboard })
                    } else {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .task {
                                flashcardTopicPath = (try? await APIClient.shared.listTopics())?.first
                            }
                    }
                case .subjects:
                    SubjectsView(onBack: { selection = .dashboard })
                case .bookmarks:
                    BookmarkView(onBack: { selection = .dashboard })
                case .history:
                    HistoryView(onBack: { selection = .dashboard })
                case .mastery:
                    MasteryView(onBack: { selection = .dashboard })
                case .settings:
                    SettingsView(onLogOut: onLogOut)
                default:
                    DashboardView()
                }
            }
        }
        .background(Theme.bg)
        .ignoresSafeArea(edges: .bottom)
        .alert(
            "Leave quiz?",
            isPresented: Binding(
                get: { pendingSelection != nil },
                set: { if !$0 { pendingSelection = nil } }
            )
        ) {
            Button("Leave Quiz", role: .destructive) {
                isQuizInProgress = false
                activeTopicPath = nil
                if let pendingSelection {
                    selection = pendingSelection
                }
                pendingSelection = nil
            }
            Button("Keep Going", role: .cancel) {
                pendingSelection = nil
            }
        } message: {
            Text("Your progress on this quiz will be lost if you leave now.")
        }
    }
}

#Preview {
    RootView()
}
