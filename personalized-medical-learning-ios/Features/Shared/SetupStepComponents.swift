//
//  SetupStepComponents.swift
//  personalized-medical-learning-ios
//

import SwiftUI

/// Shared by QuizSetupStep and FlashcardSetupStep so both flows can reuse
/// StepBreadcrumbBar without duplicating it per feature.
protocol SetupStep: CaseIterable, Identifiable, Equatable where AllCases: RandomAccessCollection {
    var rawValue: Int { get }
    var title: String { get }
    var subtitle: String { get }
}

struct StepBreadcrumbBar<Step: SetupStep>: View {
    let currentStep: Step
    let onTap: (Step) -> Void

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(Step.allCases)) { step in
                BreadcrumbItem(
                    step: step,
                    isActive: step == currentStep,
                    isComplete: step.rawValue < currentStep.rawValue
                ) {
                    onTap(step)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

private struct BreadcrumbItem<Step: SetupStep>: View {
    let step: Step
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

                Spacer(minLength: 0)
            }
        }
        .buttonStyle(.plain)
        .disabled(!isComplete)
    }
}

struct FloatingNextButton: View {
    var onNext: () -> Void

    var body: some View {
        Button(action: onNext) {
            HStack(spacing: 6) {
                Text("Next")
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
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(.ultraThinMaterial)
    }
}

struct PreviewStatTile: View {
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

/// Topic-choose step shared by QuizSetupView and FlashcardSetupView — search,
/// weakest-mastery recommendations, and subject-grouped topic list all behave
/// identically between the two flows.
struct ChooseTopicsStepView: View {
    let topics: [QuizTopic]
    let isLoading: Bool
    let errorMessage: String?
    @Binding var selectedTopicID: String?
    var onRetry: () -> Void

    @State private var searchText = ""
    @State private var expandedSubject: String?

    private var groups: [QuizSubjectGroup] {
        let grouped = Dictionary(grouping: topics, by: \.subject)
        return grouped.keys.sorted().map { subject in
            QuizSubjectGroup(subject: subject, topics: grouped[subject]!.sorted { $0.name < $1.name })
        }
    }

    /// Weakest-mastery topics still present in this session's topic list, capped at 3 —
    /// nudges the learner toward BKTStore's lowest p_know entries instead of leaving
    /// topic choice unguided. Only surfaces topics below the 70% mastery bar; anything
    /// at or above that is already considered mastered and doesn't need recommending.
    private var recommendedTopics: [(topic: QuizTopic, entry: MasteryEntry)] {
        guard searchText.isEmpty else { return [] }
        let topicsByPath = Dictionary(uniqueKeysWithValues: topics.map { ($0.path, $0) })
        return BKTStore.allEntries()
            .filter { $0.percent < 70 }
            .compactMap { entry in topicsByPath[entry.topicPath].map { (topic: $0, entry: entry) } }
            .prefix(3)
            .map { $0 }
    }

    private var filteredTopics: [QuizTopic]? {
        guard !searchText.isEmpty else { return nil }
        return topics.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.subject.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
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

            if !recommendedTopics.isEmpty {
                RecommendedTopicsSection(
                    entries: recommendedTopics,
                    selectedTopicID: selectedTopicID
                ) { topic in
                    selectedTopicID = topic.id
                }
            }

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
            } else if let filteredTopics {
                VStack(spacing: 10) {
                    if filteredTopics.isEmpty {
                        Text("No topics match \"\(searchText)\".")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                    } else {
                        ForEach(filteredTopics) { topic in
                            TopicRow(
                                topic: topic,
                                subtitle: topic.subject,
                                isSelected: selectedTopicID == topic.id
                            ) {
                                selectedTopicID = topic.id
                            }
                        }
                    }
                }
            } else {
                VStack(spacing: 10) {
                    ForEach(groups) { group in
                        SubjectGroupSection(
                            group: group,
                            isExpanded: expandedSubject == group.subject,
                            selectedTopicID: $selectedTopicID,
                            onToggle: {
                                expandedSubject = expandedSubject == group.subject ? nil : group.subject
                            }
                        )
                    }
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

private struct RecommendedTopicsSection: View {
    let entries: [(topic: QuizTopic, entry: MasteryEntry)]
    let selectedTopicID: String?
    let onSelect: (QuizTopic) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.orange)
                Text("Recommended for You")
                    .font(.subheadline.bold())
                    .foregroundStyle(Theme.dark)
            }
            Text("A few areas worth another look, based on your quiz performance.")
                .font(.caption)
                .foregroundStyle(.secondary)

            VStack(spacing: 8) {
                ForEach(entries, id: \.topic.id) { pair in
                    RecommendedTopicRow(
                        topic: pair.topic,
                        entry: pair.entry,
                        isSelected: selectedTopicID == pair.topic.id
                    ) {
                        onSelect(pair.topic)
                    }
                }
            }
        }
        .padding(14)
        .background(Color.orange.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.orange.opacity(0.2)))
    }
}

private struct RecommendedTopicRow: View {
    let topic: QuizTopic
    let entry: MasteryEntry
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 14) {
                ZStack {
                    Circle().fill(topic.tint.opacity(0.15)).frame(width: 40, height: 40)
                    Image(systemName: topic.icon).foregroundStyle(topic.tint)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(topic.name).font(.subheadline.bold()).foregroundStyle(Theme.dark)
                    Text(topic.subject).font(.caption2).foregroundStyle(.secondary)
                }

                Spacer()

                Text(entry.statusLabel)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(entry.tint)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(entry.tint.opacity(0.12))
                    .clipShape(Capsule())

                ZStack {
                    Circle()
                        .fill(isSelected ? Theme.dark : Color.white)
                        .overlay(Circle().stroke(Color.black.opacity(0.15), lineWidth: isSelected ? 0 : 1.5))
                        .frame(width: 24, height: 24)
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.white)
                    }
                }
            }
            .padding(12)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

private struct SubjectGroupSection: View {
    let group: QuizSubjectGroup
    let isExpanded: Bool
    @Binding var selectedTopicID: String?
    var onToggle: () -> Void

    private var selectedTopicInGroup: QuizTopic? {
        group.topics.first { $0.id == selectedTopicID }
    }

    var body: some View {
        VStack(spacing: 10) {
            Button(action: onToggle) {
                HStack(spacing: 14) {
                    ZStack {
                        Circle().fill(Theme.dark.opacity(0.1)).frame(width: 44, height: 44)
                        Image(systemName: "folder.fill").foregroundStyle(Theme.dark)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(group.subject).font(.subheadline.bold()).foregroundStyle(Theme.dark)
                        Text(selectedTopicInGroup.map { "Selected: \($0.name)" } ?? "\(group.topics.count) topics")
                            .font(.caption2)
                            .foregroundStyle(selectedTopicInGroup == nil ? .secondary : Theme.dark)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .padding(14)
                .background(Theme.bg)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(selectedTopicInGroup == nil ? Color.clear : Theme.dark, lineWidth: 1.5)
                )
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(spacing: 8) {
                    ForEach(group.topics) { topic in
                        TopicRow(
                            topic: topic,
                            subtitle: nil,
                            isSelected: selectedTopicID == topic.id
                        ) {
                            selectedTopicID = topic.id
                        }
                    }
                }
                .padding(.leading, 16)
            }
        }
    }
}

private struct TopicRow: View {
    let topic: QuizTopic
    var subtitle: String? = nil
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 14) {
                ZStack {
                    Circle().fill(topic.tint.opacity(0.15)).frame(width: 44, height: 44)
                    Image(systemName: topic.icon).foregroundStyle(topic.tint)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(topic.name).font(.subheadline.bold()).foregroundStyle(Theme.dark)
                    if let subtitle {
                        Text(subtitle).font(.caption2).foregroundStyle(.secondary)
                    }
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
            .background(Theme.bg)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }
}
