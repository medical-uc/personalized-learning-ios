//
//  QuizSetupView.swift
//  personalized-medical-learning-ios
//

import SwiftUI

struct QuizSetupView: View {
    var onBack: () -> Void = {}
    var onStart: (Set<UUID>, QuizSettings) -> Void = { _, _ in }

    @State private var currentStep: QuizSetupStep = .topics
    @State private var selectedTopicIDs: Set<UUID> = Set(
        QuizSetupData.topics.filter { QuizSetupData.recommendedTopicNames.contains($0.name) }.map(\.id)
    )
    @State private var customTopics: [QuizTopic] = []
    @State private var settings = QuizSettings()

    private var allTopics: [QuizTopic] {
        QuizSetupData.topics + customTopics
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                QuizHeaderView(onBack: onBack)

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
    }

    @ViewBuilder
    private func stepContent(for step: QuizSetupStep) -> some View {
        switch step {
        case .topics:
            ChooseTopicsStepView(
                topics: allTopics,
                selectedTopicIDs: $selectedTopicIDs,
                onAddCustomTopic: { name in
                    let topic = QuizTopic(name: name, icon: "star.fill", tint: Theme.dark, mastery: 0, isCustom: true)
                    customTopics.append(topic)
                    selectedTopicIDs.insert(topic.id)
                },
                onNext: { currentStep = .settings }
            )
        case .settings:
            QuizSettingsStepView(
                settings: $settings,
                onBack: { currentStep = .topics },
                onNext: { currentStep = .start }
            )
        case .start:
            StartQuizStepView(
                topicCount: selectedTopicIDs.count,
                settings: settings,
                onBack: { currentStep = .settings },
                onStart: { onStart(selectedTopicIDs, settings) }
            )
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
                        .fill(Color.black.opacity(0.12))
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
                        .fill(isActive || isComplete ? Theme.dark : Color.white)
                        .overlay(Circle().stroke(Theme.dark.opacity(isActive || isComplete ? 0 : 0.2), lineWidth: 1.5))
                        .frame(width: 32, height: 32)
                    if isComplete {
                        Image(systemName: "checkmark")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white)
                    } else {
                        Text("\(step.rawValue + 1)")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(isActive || isComplete ? .white : Theme.dark)
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(step.title).font(.headline).foregroundStyle(Theme.dark)
                    Text(step.subtitle).font(.caption).foregroundStyle(.secondary)
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
    @Binding var selectedTopicIDs: Set<UUID>
    var onAddCustomTopic: (String) -> Void
    var onNext: () -> Void

    @State private var searchText = ""
    @State private var isAddingCustomTopic = false
    @State private var customTopicName = ""

    private var filteredTopics: [QuizTopic] {
        guard !searchText.isEmpty else { return topics }
        return topics.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Choose Topics").font(.title3.bold()).foregroundStyle(Theme.dark)
            Text("Select the topics you want to be tested on.")
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

            HStack {
                Text("Subjects").font(.subheadline.bold())
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "sparkles")
                    Text("Recommended for you")
                }
                .font(.caption.weight(.medium))
                .foregroundStyle(Theme.dark)
            }

            VStack(spacing: 10) {
                ForEach(filteredTopics) { topic in
                    TopicRow(
                        topic: topic,
                        isSelected: selectedTopicIDs.contains(topic.id)
                    ) {
                        if selectedTopicIDs.contains(topic.id) {
                            selectedTopicIDs.remove(topic.id)
                        } else {
                            selectedTopicIDs.insert(topic.id)
                        }
                    }
                }
            }

            if isAddingCustomTopic {
                HStack(spacing: 10) {
                    TextField("Custom topic name", text: $customTopicName)
                        .textFieldStyle(.plain)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Theme.bg)
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                    Button("Add") {
                        let trimmed = customTopicName.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        onAddCustomTopic(trimmed)
                        customTopicName = ""
                        isAddingCustomTopic = false
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Theme.dark)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }

            HStack {
                Button {
                    isAddingCustomTopic.toggle()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                        Text("Add Custom Topic")
                    }
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Theme.dark)
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
                    .background(selectedTopicIDs.isEmpty ? Theme.dark.opacity(0.4) : Theme.dark)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(selectedTopicIDs.isEmpty)
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

                VStack(alignment: .leading, spacing: 6) {
                    Text(topic.name).font(.subheadline.bold()).foregroundStyle(Theme.dark)
                    HStack(spacing: 8) {
                        ProgressView(value: Double(topic.mastery), total: 100)
                            .tint(topic.masteryColor)
                            .frame(width: 140)
                        Text("\(topic.mastery)% Mastery")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isSelected ? Theme.dark : Color.white)
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.black.opacity(0.15), lineWidth: isSelected ? 0 : 1.5))
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

            SettingRow(title: "Question Count", subtitle: "How many questions?") {
                Menu {
                    ForEach(QuizSetupOptions.questionCounts, id: \.self) { count in
                        Button("\(count)") { settings.questionCount = count }
                    }
                } label: {
                    PickerLabel(text: "\(settings.questionCount)")
                }
            }

            Divider()

            VStack(alignment: .leading, spacing: 14) {
                SettingRow(title: "Question Type", subtitle: "Select question format") {
                    PickerLabel(text: settings.selectedQuestionTypes.count == QuestionType.allCases.count ? "All Types" : "\(settings.selectedQuestionTypes.count) Selected")
                }

                FlowQuestionTypes(settings: $settings)
            }

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

private struct StartQuizStepView: View {
    let topicCount: Int
    let settings: QuizSettings
    var onBack: () -> Void
    var onStart: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Start Quiz").font(.title3.bold()).foregroundStyle(Theme.dark)
            Text("You're all set! Let's begin.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Divider()

            VStack(spacing: 10) {
                SummaryRow(icon: "book.closed", label: "Topics", value: "\(topicCount) selected")
                SummaryRow(icon: "list.number", label: "Questions", value: "\(settings.questionCount)")
                SummaryRow(icon: "square.grid.2x2", label: "Question Types", value: "\(settings.selectedQuestionTypes.count) selected")
                SummaryRow(icon: "timer", label: "Timer", value: settings.isTimerEnabled ? "\(settings.secondsPerQuestion) sec/question" : "Off")
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

                Button(action: onStart) {
                    HStack(spacing: 6) {
                        Text("Start Quiz")
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

private struct SummaryRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(Theme.bg).frame(width: 36, height: 36)
                Image(systemName: icon).font(.subheadline).foregroundStyle(Theme.dark)
            }
            Text(label).font(.subheadline.weight(.medium)).foregroundStyle(Theme.dark)
            Spacer()
            Text(value).font(.subheadline).foregroundStyle(.secondary)
        }
        .padding(14)
        .background(Theme.bg)
        .clipShape(RoundedRectangle(cornerRadius: 14))
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

private struct FlowQuestionTypes: View {
    @Binding var settings: QuizSettings
    let columns = [GridItem(.adaptive(minimum: 130), spacing: 10)]

    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 10) {
            ForEach(QuestionType.allCases) { type in
                let isSelected = settings.selectedQuestionTypes.contains(type)
                Button {
                    if isSelected {
                        settings.selectedQuestionTypes.remove(type)
                    } else {
                        settings.selectedQuestionTypes.insert(type)
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: type.icon)
                        Text(type.rawValue)
                    }
                    .font(.caption.weight(.medium))
                    .foregroundStyle(isSelected ? .white : Theme.dark)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background(isSelected ? Theme.dark : Theme.bg)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    QuizSetupView()
}
