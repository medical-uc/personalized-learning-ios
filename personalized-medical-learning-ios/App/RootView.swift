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
    @State private var activeReviewModeEnabled: Bool = true
    @State private var isQuizInProgress = false
    @State private var pendingSelection: SidebarItem?
    @State private var preselectedSetupTopicPath: String?
    @State private var energyToastAmount: Int?
    @State private var isFlashcardSessionStarted = false
    @State private var activeFlashcardTopicPath: String?
    @State private var preselectedFlashcardSetupTopicPath: String?
    @State private var isOffline = !Reachability.shared.isOnline

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
                            preselectedSetupTopicPath = topic.path
                            selection = .quiz
                        },
                        onReviewDue: { soonestDue in
                            switch soonestDue.source {
                            case .quiz:
                                activeTopicPath = soonestDue.topicPath
                                selection = .quiz
                            case .flashcard:
                                isFlashcardSessionStarted = true
                                selection = .flashcards
                            }
                        }
                    )
                case .quiz:
                    if let activeTopicPath {
                        QuizView(
                            topicPath: activeTopicPath,
                            questionCount: activeQuestionCount,
                            isReviewModeEnabled: activeReviewModeEnabled,
                            onBack: {
                                self.activeTopicPath = nil
                                selection = .dashboard
                            },
                            onProgressChange: { isQuizInProgress = $0 }
                        )
                    } else {
                        QuizSetupView(
                            preselectedTopicPath: preselectedSetupTopicPath,
                            onBack: {
                                preselectedSetupTopicPath = nil
                                selection = .dashboard
                            },
                            onStart: { topic, settings in
                                preselectedSetupTopicPath = nil
                                activeTopicPath = topic.path
                                activeQuestionCount = settings.questionCount
                                activeReviewModeEnabled = settings.isReviewModeEnabled
                            }
                        )
                    }
                case .flashcards:
                    if isFlashcardSessionStarted {
                        FlashcardView(topicPath: activeFlashcardTopicPath, onBack: {
                            isFlashcardSessionStarted = false
                            activeFlashcardTopicPath = nil
                        })
                        .onDisappear {
                            isFlashcardSessionStarted = false
                            activeFlashcardTopicPath = nil
                        }
                    } else {
                        FlashcardSetupView(
                            preselectedTopicPath: preselectedFlashcardSetupTopicPath,
                            onBack: {
                                preselectedFlashcardSetupTopicPath = nil
                                selection = .dashboard
                            },
                            onBegin: { topicPath in
                                preselectedFlashcardSetupTopicPath = nil
                                activeFlashcardTopicPath = topicPath
                                isFlashcardSessionStarted = true
                            }
                        )
                    }
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
        .overlay(alignment: .top) {
            VStack(spacing: 8) {
                if isOffline {
                    OfflineBanner()
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
                if let energyToastAmount {
                    EnergyAwardedToast(amount: energyToastAmount)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .padding(.top, 16)
        }
        .animation(.spring(duration: 0.35), value: energyToastAmount)
        .animation(.spring(duration: 0.35), value: isOffline)
        .onReceive(NotificationCenter.default.publisher(for: .energyAwarded)) { notification in
            guard let amount = notification.userInfo?[EnergyAwardedKey.amount] as? Int else { return }
            energyToastAmount = amount
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                if energyToastAmount == amount {
                    energyToastAmount = nil
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .networkStatusChanged)) { notification in
            isOffline = (notification.userInfo?[Reachability.isOnlineKey] as? Bool).map { !$0 } ?? isOffline
        }
    }
}

private struct OfflineBanner: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "wifi.slash")
                .foregroundStyle(.white)
            Text("You're offline")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(Color.red.opacity(0.85))
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
    }
}

private struct EnergyAwardedToast: View {
    let amount: Int

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "bolt.fill")
                .foregroundStyle(.orange)
            Text("+\(amount) Energy")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(Theme.dark)
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
    }
}

#Preview {
    RootView()
}
