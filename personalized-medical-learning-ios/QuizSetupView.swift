//
//  QuizSetupView.swift
//  personalized-medical-learning-ios
//

import SwiftUI

struct QuizSetupView: View {
    var onBack: () -> Void = {}
    var onStart: (QuizTopic, QuizSettings) -> Void = { _, _ in }

    @StateObject private var viewModel = QuizSetupViewModel()
    @State private var currentStep: QuizSetupStep = .topics
    @State private var selectedTopicID: String?
    @State private var settings = QuizSettings()

    private var selectedTopic: QuizTopic? {
        viewModel.topics.first { $0.id == selectedTopicID }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Create a Quiz")
                        .font(.largeTitle.bold())
                        .foregroundStyle(Theme.dark)
                    Text("Customize your quiz to focus on what matters most to you.")
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
        .task {
            await viewModel.loadTopics()
        }
    }

    @ViewBuilder
    private func stepContent(for step: QuizSetupStep) -> some View {
        switch step {
        case .topics:
            ChooseTopicsStepView(
                topics: viewModel.topics,
                isLoading: viewModel.isLoading,
                errorMessage: viewModel.errorMessage,
                selectedTopicID: $selectedTopicID,
                onRetry: { Task { await viewModel.loadTopics() } },
                onNext: { currentStep = .settings }
            )
        case .settings:
            QuizSettingsStepView(
                settings: $settings,
                onBack: { currentStep = .topics },
                onNext: { currentStep = .start }
            )
        case .start:
            if let selectedTopic {
                QuizPreviewStepView(
                    topic: selectedTopic,
                    settings: settings,
                    onEditTopics: { currentStep = .topics },
                    onBegin: { onStart(selectedTopic, settings) }
                )
            }
        }
    }
}

private struct StepBreadcrumbBar: View {
    let currentStep: QuizSetupStep
    let onTap: (QuizSetupStep) -> Void

    var body: some View {
        HStack(spacing: 0) {
            ForEach(QuizSetupStep.allCases) { step in
                BreadcrumbItem(
                    step: step,
                    isActive: step == currentStep,
                    isComplete: step.rawValue < currentStep.rawValue
                ) {
                    onTap(step)
                }

                if step != QuizSetupStep.allCases.last {
                    Rectangle()
                        .fill(Color.black)
                        .frame(height: 1)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

private struct BreadcrumbItem: View {
    let step: QuizSetupStep
    let isActive: Bool
    let isComplete: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(isActive ? Theme.dark.opacity(0.6) : (isComplete ? Theme.dark : Color.black.opacity(0.08)))
                        .frame(width: 32, height: 32)
                    if isComplete {
                        Image(systemName: "checkmark")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white)
                    } else {
                        Text("\(step.rawValue + 1)")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(isActive ? .white : .secondary)
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(step.title)
                        .font(.headline)
                        .foregroundStyle(Theme.dark)
                    Text(step.subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .fixedSize(horizontal: true, vertical: false)
        }
        .buttonStyle(.plain)
        .disabled(!isComplete)
    }
}

private struct ChooseTopicsStepView: View {
    let topics: [QuizTopic]
    let isLoading: Bool
    let errorMessage: String?
    @Binding var selectedTopicID: String?
    var onRetry: () -> Void
    var onNext: () -> Void

    @State private var searchText = ""

    private var filteredTopics: [QuizTopic] {
        guard !searchText.isEmpty else { return topics }
        return topics.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Choose a Topic").font(.title3.bold()).foregroundStyle(Theme.dark)
            Text("Select the topic you want to be tested on.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                TextField("Search topics or keywords...", text: $searchText)
                    .textFieldStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Theme.bg)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black.opacity(0.06)))

            if isLoading {
                ProgressView("Loading topics…")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            } else if let errorMessage {
                VStack(spacing: 12) {
                    Text(errorMessage)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    Button("Retry", action: onRetry)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Theme.dark)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            } else {
                VStack(spacing: 10) {
                    ForEach(filteredTopics) { topic in
                        TopicRow(
                            topic: topic,
                            isSelected: selectedTopicID == topic.id
                        ) {
                            selectedTopicID = topic.id
                        }
                    }
                }
            }

            HStack {
                Spacer()

                Button(action: onNext) {
                    HStack(spacing: 6) {
                        Text("Next")
                        Image(systemName: "chevron.right")
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(selectedTopicID == nil ? Theme.dark.opacity(0.4) : Theme.dark)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(selectedTopicID == nil)
            }
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

private struct TopicRow: View {
    let topic: QuizTopic
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 14) {
                ZStack {
                    Circle().fill(topic.tint.opacity(0.15)).frame(width: 44, height: 44)
                    Image(systemName: topic.icon).foregroundStyle(topic.tint)
                }

                Text(topic.name).font(.subheadline.bold()).foregroundStyle(Theme.dark)

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
            .background(Theme.bg)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }
}

private struct QuizSettingsStepView: View {
    @Binding var settings: QuizSettings
    var onBack: () -> Void
    var onNext: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Quiz Settings").font(.title3.bold()).foregroundStyle(Theme.dark)
            Text("Set the preferences for your quiz.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Divider()

            SettingRow(title: "Timer", subtitle: "Add time limit per question") {
                HStack(spacing: 10) {
                    if settings.isTimerEnabled {
                        Menu {
                            ForEach(QuizSetupOptions.timerOptions, id: \.self) { seconds in
                                Button("\(seconds) sec") { settings.secondsPerQuestion = seconds }
                            }
                        } label: {
                            PickerLabel(text: "\(settings.secondsPerQuestion) sec")
                        }
                    }
                    Toggle("", isOn: $settings.isTimerEnabled)
                        .labelsHidden()
                        .tint(Theme.dark)
                }
            }

            Divider()

            SettingRow(title: "Review Mode", subtitle: "See explanations after each question") {
                Toggle("", isOn: $settings.isReviewModeEnabled)
                    .labelsHidden()
                    .tint(Theme.dark)
            }

            HStack {
                Button(action: onBack) {
                    Text("Back")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.dark)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.white)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black.opacity(0.12)))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)

                Spacer()

                Button(action: onNext) {
                    HStack(spacing: 6) {
                        Text("Next")
                        Image(systemName: "chevron.right")
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Theme.dark)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

private struct QuizPreviewStepView: View {
    let topic: QuizTopic
    let settings: QuizSettings
    var onEditTopics: () -> Void
    var onBegin: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Quiz Preview").font(.title3.bold()).foregroundStyle(Theme.dark)
            Text("Review your quiz before starting.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 0) {
                PreviewStatTile(icon: "book.closed.fill", tint: Theme.dark, value: topic.name, label: "Topic")
                PreviewStatTile(icon: "clock.fill", tint: .blue, value: settings.isTimerEnabled ? "\(settings.secondsPerQuestion) sec" : "Off", label: "Per Question")
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

private struct PreviewStatTile: View {
    let icon: String
    let tint: Color
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle().fill(tint.opacity(0.15)).frame(width: 44, height: 44)
                Image(systemName: icon).foregroundStyle(tint)
            }
            Text(value).font(.title3.bold()).foregroundStyle(Theme.dark)
            Text(label).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
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

private struct PickerLabel: View {
    let text: String

    var body: some View {
        HStack(spacing: 6) {
            Text(text).font(.subheadline.weight(.medium)).foregroundStyle(Theme.dark)
            Image(systemName: "chevron.down").font(.caption2).foregroundStyle(.secondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black.opacity(0.12)))
    }
}

#Preview {
    QuizSetupView()
}
