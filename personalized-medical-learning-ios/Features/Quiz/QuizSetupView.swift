//
//  QuizSetupView.swift
//  personalized-medical-learning-ios
//

import SwiftUI

struct QuizSetupView: View {
    /// Pre-selects a topic and jumps straight to the Preview step — used by
    /// "Practice Now" on the dashboard's Focus Areas card, which already knows the
    /// topic and just needs the learner to confirm before starting.
    var preselectedTopicPath: String?
    /// Skips topic selection and shows a due-for-review preview (count + settings)
    /// instead of the topic-based one — mirrors FlashcardSetupView's startWithAllDue.
    var startWithAllDue: Bool = false
    var onBack: () -> Void = {}
    /// Up to 3 topics — the question-selection algorithm (QuizViewModel) draws from all
    /// of them and weights toward whichever the student is weakest in, rather than a
    /// single fixed topic.
    var onStart: ([QuizTopic], QuizSettings) -> Void = { _, _ in }
    /// Confirmed from the due-review preview (startWithAllDue) — starts the cross-topic
    /// due batch instead of a topic-scoped session.
    var onStartDueBatch: (QuizSettings) -> Void = { _ in }

    static let maxTopics = 3

    @StateObject private var viewModel = QuizSetupViewModel()
    @State private var currentStep: QuizSetupStep
    @State private var selectedTopicIDs: Set<String>
    @State private var settings = QuizSettings()

    init(
        preselectedTopicPath: String? = nil,
        startWithAllDue: Bool = false,
        onBack: @escaping () -> Void = {},
        onStart: @escaping ([QuizTopic], QuizSettings) -> Void = { _, _ in },
        onStartDueBatch: @escaping (QuizSettings) -> Void = { _ in }
    ) {
        self.preselectedTopicPath = preselectedTopicPath
        self.startWithAllDue = startWithAllDue
        self.onBack = onBack
        self.onStart = onStart
        self.onStartDueBatch = onStartDueBatch
        _currentStep = State(initialValue: (preselectedTopicPath == nil && !startWithAllDue) ? .topics : .start)
        _selectedTopicIDs = State(initialValue: preselectedTopicPath.map { Set([$0]) } ?? [])
    }

    private var selectedTopics: [QuizTopic] {
        viewModel.topics.filter { selectedTopicIDs.contains($0.id) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(currentStep.title)
                        .font(.largeTitle.bold())
                        .foregroundStyle(Theme.dark)
                    Text(currentStep.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 24)

                StepBreadcrumbBar(currentStep: currentStep) { step in
                    guard step.rawValue < currentStep.rawValue else { return }
                    currentStep = step
                }

                stepContent(for: currentStep)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .background(Theme.bg)
        .safeAreaInset(edge: .bottom) {
            if currentStep == .topics, !selectedTopicIDs.isEmpty {
                FloatingNextButton { currentStep = .start }
            }
        }
        .task {
            if startWithAllDue {
                await viewModel.loadDueCount()
            } else {
                await viewModel.loadTopics()
            }
        }
    }

    @ViewBuilder
    private func stepContent(for step: QuizSetupStep) -> some View {
        switch step {
        case .topics:
            MultiChooseTopicsStepView(
                topics: viewModel.topics,
                isLoading: viewModel.isLoading,
                errorMessage: viewModel.errorMessage,
                selectedTopicIDs: $selectedTopicIDs,
                maxSelection: Self.maxTopics,
                onRetry: { Task { await viewModel.loadTopics() } }
            )
        case .start:
            if startWithAllDue {
                QuizDuePreviewStepView(
                    dueCount: viewModel.dueCount,
                    isLoading: viewModel.isLoadingDueCount,
                    errorMessage: viewModel.dueCountErrorMessage,
                    settings: $settings,
                    onRetry: { Task { await viewModel.loadDueCount() } },
                    onBegin: { onStartDueBatch(settings) }
                )
            } else if !selectedTopics.isEmpty {
                QuizPreviewStepView(
                    topics: selectedTopics,
                    settings: $settings,
                    onEditTopics: { currentStep = .topics },
                    onBegin: { onStart(selectedTopics, settings) }
                )
            }
        }
    }
}

private struct QuizPreviewStepView: View {
    let topics: [QuizTopic]
    @Binding var settings: QuizSettings
    var onEditTopics: () -> Void
    var onBegin: () -> Void

    /// Total quiz time = per-question timer × question count, now that both are fixed
    /// defaults (60s, 10 questions) with no settings UI to override them.
    private var totalTimeText: String {
        guard settings.isTimerEnabled else { return "Off" }
        let totalSeconds = settings.secondsPerQuestion * settings.questionCount
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return seconds == 0 ? "\(minutes) min" : "\(minutes)m \(seconds)s"
    }

    private var topicsLabel: String {
        topics.count == 1 ? topics[0].name : "\(topics.count) topics"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 0) {
                PreviewStatTile(icon: "book.closed.fill", tint: Theme.dark, value: topicsLabel, label: "Topics")
                PreviewStatTile(icon: "list.number", tint: .purple, value: "\(settings.questionCount)", label: "Questions")
                PreviewStatTile(icon: "clock.fill", tint: .blue, value: totalTimeText, label: "Total Time")
            }
            .padding(.vertical, 4)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.black.opacity(0.08)))

            HStack {
                Text(topics.count == 1 ? "Topic" : "Topics (\(topics.count)/\(QuizSetupView.maxTopics))")
                    .font(.subheadline.bold())
                    .foregroundStyle(Theme.dark)
                Spacer()
                Button(action: onEditTopics) {
                    HStack(spacing: 4) {
                        Text("Edit")
                        Image(systemName: "pencil")
                    }
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Theme.dark)
                }
                .buttonStyle(.plain)
            }

            VStack(spacing: 8) {
                ForEach(topics) { topic in
                    HStack(spacing: 12) {
                        ZStack {
                            Circle().fill(topic.tint.opacity(0.15)).frame(width: 36, height: 36)
                            Image(systemName: topic.icon).font(.subheadline).foregroundStyle(topic.tint)
                        }
                        Text(topic.name).font(.subheadline.bold()).foregroundStyle(Theme.dark)
                        Spacer()
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Theme.bg)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }

            Text("Questions are drawn from all selected topics, weighted toward whichever you're weakest in.")
                .font(.caption)
                .foregroundStyle(.secondary)

            Divider()

            SettingRow(title: "Review Mode", subtitle: "See explanations after each question") {
                Toggle("", isOn: $settings.isReviewModeEnabled)
                    .labelsHidden()
                    .tint(Theme.dark)
            }

            Button(action: onBegin) {
                HStack(spacing: 6) {
                    Text("Begin Quiz")
                    Image(systemName: "chevron.right")
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Theme.dark)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

/// Preview step for the cross-topic due-review batch (started from the dashboard's
/// Due for Review card) — no topic list to edit since the batch spans every topic with
/// something due, so this just confirms the count before starting.
private struct QuizDuePreviewStepView: View {
    let dueCount: Int?
    let isLoading: Bool
    let errorMessage: String?
    @Binding var settings: QuizSettings
    var onRetry: () -> Void
    var onBegin: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if let errorMessage {
                VStack(alignment: .leading, spacing: 10) {
                    Text(errorMessage)
                        .font(.subheadline)
                        .foregroundStyle(.red)
                    Button("Retry", action: onRetry)
                        .font(.subheadline.weight(.semibold))
                }
            } else {
                HStack(spacing: 0) {
                    PreviewStatTile(
                        icon: "arrow.clockwise",
                        tint: .orange,
                        value: isLoading ? "…" : "\(dueCount ?? 0)",
                        label: "Due Now"
                    )
                    PreviewStatTile(icon: "clock.fill", tint: .blue, value: totalTimeText, label: "Total Time")
                }
                .padding(.vertical, 4)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.black.opacity(0.08)))

                Text("Questions you've answered before, due for a spaced-repetition review, across every topic.")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Divider()

                SettingRow(title: "Review Mode", subtitle: "See explanations after each question") {
                    Toggle("", isOn: $settings.isReviewModeEnabled)
                        .labelsHidden()
                        .tint(Theme.dark)
                }

                Button(action: onBegin) {
                    HStack(spacing: 6) {
                        Text("Begin Quiz")
                        Image(systemName: "chevron.right")
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Theme.dark)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                .disabled(isLoading || (dueCount ?? 0) == 0)
            }
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private var totalTimeText: String {
        guard settings.isTimerEnabled, let dueCount else { return "—" }
        let totalSeconds = settings.secondsPerQuestion * dueCount
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return seconds == 0 ? "\(minutes) min" : "\(minutes)m \(seconds)s"
    }
}

private struct SettingRow<Accessory: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder let accessory: Accessory

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline.bold()).foregroundStyle(Theme.dark)
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            accessory
        }
    }
}

#Preview {
    QuizSetupView()
}
