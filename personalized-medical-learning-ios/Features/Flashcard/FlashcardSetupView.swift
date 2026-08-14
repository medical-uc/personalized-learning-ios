//
//  FlashcardSetupView.swift
//  personalized-medical-learning-ios
//

import SwiftUI

/// Two-step setup mirroring QuizSetupView: pick a topic (or study everything due),
/// then preview the session before starting. Passing nil topicPath through to
/// FlashcardViewModel keeps the existing all-cards, due-first session behavior.
struct FlashcardSetupView: View {
    var preselectedTopicPath: String?
    var onBack: () -> Void = {}
    var onBegin: (String?) -> Void = { _ in }

    @StateObject private var viewModel = FlashcardSetupViewModel()
    @State private var currentStep: FlashcardSetupStep
    @State private var selectedTopicID: String?

    init(preselectedTopicPath: String? = nil, onBack: @escaping () -> Void = {}, onBegin: @escaping (String?) -> Void = { _ in }) {
        self.preselectedTopicPath = preselectedTopicPath
        self.onBack = onBack
        self.onBegin = onBegin
        _currentStep = State(initialValue: preselectedTopicPath == nil ? .topics : .start)
        _selectedTopicID = State(initialValue: preselectedTopicPath)
    }

    private var selectedTopic: QuizTopic? {
        viewModel.topics.first { $0.id == selectedTopicID }
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
            if currentStep == .topics {
                FloatingNextButton { currentStep = .start }
            }
        }
        .task {
            await viewModel.loadTopics()
        }
        .task(id: currentStep) {
            guard currentStep == .start else { return }
            await viewModel.loadPreview(topicPath: selectedTopic?.path)
        }
    }

    @ViewBuilder
    private func stepContent(for step: FlashcardSetupStep) -> some View {
        switch step {
        case .topics:
            VStack(alignment: .leading, spacing: 12) {
                StudyEverythingRow(isSelected: selectedTopicID == nil) {
                    selectedTopicID = nil
                }
                ChooseTopicsStepView(
                    topics: viewModel.topics,
                    isLoading: viewModel.isLoadingTopics,
                    errorMessage: viewModel.topicsErrorMessage,
                    selectedTopicID: $selectedTopicID,
                    onRetry: { Task { await viewModel.loadTopics() } }
                )
            }
        case .start:
            SessionPreviewStepView(
                topic: selectedTopic,
                isLoading: viewModel.isLoadingPreview,
                errorMessage: viewModel.previewErrorMessage,
                preview: viewModel.preview,
                onEditTopics: { currentStep = .topics },
                onBegin: { onBegin(selectedTopic?.path) }
            )
        }
    }
}

private struct StudyEverythingRow: View {
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 14) {
                ZStack {
                    Circle().fill(Theme.dark.opacity(0.15)).frame(width: 44, height: 44)
                    Image(systemName: "square.stack.3d.up.fill").foregroundStyle(Theme.dark)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Study Everything Due").font(.subheadline.bold()).foregroundStyle(Theme.dark)
                    Text("No topic filter — due cards first, then weakest topics").font(.caption2).foregroundStyle(.secondary)
                }

                Spacer()

                ZStack {
                    Circle()
                        .fill(isSelected ? Theme.dark : Color.white)
                        .overlay(Circle().stroke(Color.black.opacity(0.15), lineWidth: isSelected ? 0 : 1.5))
                        .frame(width: 26, height: 26)
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white)
                    }
                }
            }
            .padding(14)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(isSelected ? Theme.dark : Color.clear, lineWidth: 1.5))
        }
        .buttonStyle(.plain)
    }
}

private struct SessionPreviewStepView: View {
    let topic: QuizTopic?
    let isLoading: Bool
    let errorMessage: String?
    let preview: FlashcardSessionPreview?
    var onEditTopics: () -> Void
    var onBegin: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if isLoading {
                ProgressView("Loading…")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 60)
            } else if let errorMessage {
                Text(errorMessage)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            } else if let preview {
                HStack(spacing: 0) {
                    PreviewStatTile(icon: "clock.badge.exclamationmark", tint: .orange, value: "\(preview.dueCount)", label: "Due Now")
                    PreviewStatTile(icon: "square.stack.3d.up.fill", tint: Theme.dark, value: "\(preview.totalCount)", label: "Total Cards")
                    if let weakestTopic = preview.weakestTopic {
                        PreviewStatTile(icon: "target", tint: .red, value: "\(weakestTopic.percent)%", label: "Weakest")
                    }
                }
                .padding(.vertical, 4)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.black.opacity(0.08)))

                HStack {
                    Text("Topic").font(.subheadline.bold()).foregroundStyle(Theme.dark)
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

                HStack(spacing: 12) {
                    ZStack {
                        Circle().fill((topic?.tint ?? Theme.dark).opacity(0.15)).frame(width: 36, height: 36)
                        Image(systemName: topic?.icon ?? "square.stack.3d.up.fill").font(.subheadline).foregroundStyle(topic?.tint ?? Theme.dark)
                    }
                    Text(topic?.name ?? "All Topics").font(.subheadline.bold()).foregroundStyle(Theme.dark)
                    Spacer()
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Theme.bg)
                .clipShape(RoundedRectangle(cornerRadius: 14))

                Divider()

                if let weakestTopic = preview.weakestTopic {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle().fill(weakestTopic.tint.opacity(0.15)).frame(width: 36, height: 36)
                            Image(systemName: "exclamationmark.triangle.fill").font(.subheadline).foregroundStyle(weakestTopic.tint)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Focus Area").font(.caption).foregroundStyle(.secondary)
                            Text(weakestTopic.topicName).font(.subheadline.bold()).foregroundStyle(Theme.dark)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Theme.bg)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                Text(preview.dueCount > 0
                     ? "Due cards come first, then the rest ordered by what needs the most work."
                     : "Nothing's due right now — you'll review cards ordered by what needs the most work.")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Button(action: onBegin) {
                    HStack(spacing: 6) {
                        Text("Begin Session")
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
                .disabled(preview.totalCount == 0)
            }
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

#Preview {
    FlashcardSetupView()
}
