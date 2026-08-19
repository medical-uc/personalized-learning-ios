//
//  RootView.swift
//  personalized-medical-learning-ios
//

import SwiftUI

struct RootView: View {
    var onLogOut: () -> Void = {}

    @State private var selection: SidebarItem = .dashboard
    @State private var activeTopicPath: String?
    @State private var activeTopicPaths: [String]?
    @State private var activeQuestionCount: Int = 10
    @State private var activeReviewModeEnabled: Bool = true
    @State private var isBatchQuizStarted = false
    @State private var isQuizInProgress = false
    @State private var pendingSelection: SidebarItem?
    @State private var preselectedSetupTopicPath: String?
    @State private var quizSetupStartsWithAllDue = false
    @State private var energyToastAmount: Int?
    @State private var isFlashcardSessionStarted = false
    @State private var isFlashcardProgressUnsaved = false
    @State private var activeFlashcardTopicPath: String?
    @State private var preselectedFlashcardSetupTopicPath: String?
    @State private var flashcardSetupStartsWithAllDue = false
    @State private var isOffline = !Reachability.shared.isOnline
    @State private var pendingFlashcardSelection: SidebarItem?

    private func requestSelect(_ item: SidebarItem) {
        guard item != selection else { return }
        if isQuizInProgress && selection == .quiz {
            pendingSelection = item
        } else if isFlashcardProgressUnsaved && selection == .flashcards {
            pendingFlashcardSelection = item
        } else {
            if selection == .quiz && !isBatchQuizStarted && activeTopicPath == nil && activeTopicPaths == nil {
                preselectedSetupTopicPath = nil
                quizSetupStartsWithAllDue = false
            }
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
                        onReviewDue: { request in
                            switch request.source {
                            case .quiz:
                                // No per-topic due-only quiz mode yet — always the
                                // cross-topic due batch regardless of which row was tapped.
                                // Routes through QuizSetupView's due-preview step rather
                                // than starting the session immediately.
                                activeTopicPath = nil
                                activeTopicPaths = nil
                                isBatchQuizStarted = false
                                quizSetupStartsWithAllDue = true
                                selection = .quiz
                            case .flashcard:
                                if let topicPath = request.topicPath {
                                    preselectedFlashcardSetupTopicPath = topicPath
                                    flashcardSetupStartsWithAllDue = false
                                } else {
                                    preselectedFlashcardSetupTopicPath = nil
                                    flashcardSetupStartsWithAllDue = true
                                }
                                selection = .flashcards
                            }
                        }
                    )
                case .quiz:
                    if isBatchQuizStarted {
                        QuizView(
                            questionCount: activeQuestionCount,
                            isReviewModeEnabled: activeReviewModeEnabled,
                            onBack: {
                                isBatchQuizStarted = false
                                selection = .dashboard
                            },
                            onProgressChange: { isQuizInProgress = $0 }
                        )
                    } else if let activeTopicPath {
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
                    } else if let activeTopicPaths {
                        QuizView(
                            topicPaths: activeTopicPaths,
                            questionCount: activeQuestionCount,
                            isReviewModeEnabled: activeReviewModeEnabled,
                            onBack: {
                                self.activeTopicPaths = nil
                                selection = .dashboard
                            },
                            onProgressChange: { isQuizInProgress = $0 }
                        )
                    } else {
                        QuizSetupView(
                            preselectedTopicPath: preselectedSetupTopicPath,
                            startWithAllDue: quizSetupStartsWithAllDue,
                            onBack: {
                                preselectedSetupTopicPath = nil
                                quizSetupStartsWithAllDue = false
                                selection = .dashboard
                            },
                            onStart: { topics, settings in
                                preselectedSetupTopicPath = nil
                                if topics.count == 1 {
                                    activeTopicPath = topics[0].path
                                } else {
                                    activeTopicPaths = topics.map(\.path)
                                }
                                activeQuestionCount = settings.questionCount
                                activeReviewModeEnabled = settings.isReviewModeEnabled
                            },
                            onStartDueBatch: { settings in
                                quizSetupStartsWithAllDue = false
                                isBatchQuizStarted = true
                                activeReviewModeEnabled = settings.isReviewModeEnabled
                            }
                        )
                    }
                case .flashcards:
                    if isFlashcardSessionStarted {
                        FlashcardView(
                            topicPath: activeFlashcardTopicPath,
                            onBack: {
                                isFlashcardSessionStarted = false
                                activeFlashcardTopicPath = nil
                            },
                            onProgressChange: { isFlashcardProgressUnsaved = $0 }
                        )
                        .onDisappear {
                            isFlashcardSessionStarted = false
                            activeFlashcardTopicPath = nil
                            isFlashcardProgressUnsaved = false
                        }
                    } else {
                        FlashcardSetupView(
                            preselectedTopicPath: preselectedFlashcardSetupTopicPath,
                            startWithAllDue: flashcardSetupStartsWithAllDue,
                            onBack: {
                                preselectedFlashcardSetupTopicPath = nil
                                flashcardSetupStartsWithAllDue = false
                                selection = .dashboard
                            },
                            onBegin: { topicPath in
                                preselectedFlashcardSetupTopicPath = nil
                                flashcardSetupStartsWithAllDue = false
                                activeFlashcardTopicPath = topicPath
                                isFlashcardSessionStarted = true
                            }
                        )
                    }
                case .subjects:
                    SubjectsView(onBack: { selection = .dashboard })
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
                activeTopicPaths = nil
                isBatchQuizStarted = false
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
        .alert(
            "Leave flashcards?",
            isPresented: Binding(
                get: { pendingFlashcardSelection != nil },
                set: { if !$0 { pendingFlashcardSelection = nil } }
            )
        ) {
            Button("Leave", role: .destructive) {
                isFlashcardProgressUnsaved = false
                isFlashcardSessionStarted = false
                activeFlashcardTopicPath = nil
                if let pendingFlashcardSelection {
                    selection = pendingFlashcardSelection
                }
                pendingFlashcardSelection = nil
            }
            Button("Keep Going", role: .cancel) {
                pendingFlashcardSelection = nil
            }
        } message: {
            Text("Your progress on this session will be lost if you leave now.")
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
