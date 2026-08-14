//
//  QuizMultiTopicPicker.swift
//  personalized-medical-learning-ios
//

import SwiftUI

/// Quiz-only fork of ChooseTopicsStepView (Features/Shared/SetupStepComponents.swift)
/// — same search/recommend/subject-group layout, but selection is a capped Set instead
/// of a single id, since QuizViewModel now draws its 10 questions from up to
/// QuizSetupView.maxTopics topics at once. FlashcardSetupView keeps the single-select
/// original; forking here avoids adding multi-select branching to a component the
/// flashcard flow doesn't need.
struct MultiChooseTopicsStepView: View {
    let topics: [QuizTopic]
    let isLoading: Bool
    let errorMessage: String?
    @Binding var selectedTopicIDs: Set<String>
    let maxSelection: Int
    var onRetry: () -> Void

    @State private var searchText = ""
    @State private var expandedSubject: String?

    private var isAtLimit: Bool { selectedTopicIDs.count >= maxSelection }

    private func toggle(_ topic: QuizTopic) {
        if selectedTopicIDs.contains(topic.id) {
            selectedTopicIDs.remove(topic.id)
        } else if !isAtLimit {
            selectedTopicIDs.insert(topic.id)
        }
    }

    private var groups: [QuizSubjectGroup] {
        let grouped = Dictionary(grouping: topics, by: \.subject)
        return grouped.keys.sorted().map { subject in
            QuizSubjectGroup(subject: subject, topics: grouped[subject]!.sorted { $0.name < $1.name })
        }
    }

    /// Weakest-mastery topics, same 70%-mastery cutoff and cap-of-3 as the single-select
    /// version — nudges toward BKTStore's lowest p_know entries without limiting the
    /// student to only those.
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

            HStack(spacing: 6) {
                Image(systemName: "info.circle")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("Choose up to \(maxSelection) topics (\(selectedTopicIDs.count)/\(maxSelection) selected).")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if !recommendedTopics.isEmpty {
                MultiRecommendedTopicsSection(
                    entries: recommendedTopics,
                    selectedTopicIDs: selectedTopicIDs,
                    isAtLimit: isAtLimit
                ) { topic in
                    toggle(topic)
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
                            MultiTopicRow(
                                topic: topic,
                                subtitle: topic.subject,
                                isSelected: selectedTopicIDs.contains(topic.id),
                                isDisabled: isAtLimit && !selectedTopicIDs.contains(topic.id)
                            ) {
                                toggle(topic)
                            }
                        }
                    }
                }
            } else {
                VStack(spacing: 10) {
                    ForEach(groups) { group in
                        MultiSubjectGroupSection(
                            group: group,
                            isExpanded: expandedSubject == group.subject,
                            selectedTopicIDs: selectedTopicIDs,
                            isAtLimit: isAtLimit,
                            onToggle: {
                                expandedSubject = expandedSubject == group.subject ? nil : group.subject
                            },
                            onToggleTopic: toggle
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

private struct MultiRecommendedTopicsSection: View {
    let entries: [(topic: QuizTopic, entry: MasteryEntry)]
    let selectedTopicIDs: Set<String>
    let isAtLimit: Bool
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
                    let isSelected = selectedTopicIDs.contains(pair.topic.id)
                    MultiRecommendedTopicRow(
                        topic: pair.topic,
                        entry: pair.entry,
                        isSelected: isSelected,
                        isDisabled: isAtLimit && !isSelected
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

private struct MultiRecommendedTopicRow: View {
    let topic: QuizTopic
    let entry: MasteryEntry
    let isSelected: Bool
    let isDisabled: Bool
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

                MultiSelectCheckmark(isSelected: isSelected)
            }
            .padding(12)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .opacity(isDisabled ? 0.4 : 1)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }
}

private struct MultiSubjectGroupSection: View {
    let group: QuizSubjectGroup
    let isExpanded: Bool
    let selectedTopicIDs: Set<String>
    let isAtLimit: Bool
    var onToggle: () -> Void
    var onToggleTopic: (QuizTopic) -> Void

    private var selectedCountInGroup: Int {
        group.topics.filter { selectedTopicIDs.contains($0.id) }.count
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
                        Text(selectedCountInGroup > 0 ? "\(selectedCountInGroup) selected" : "\(group.topics.count) topics")
                            .font(.caption2)
                            .foregroundStyle(selectedCountInGroup == 0 ? .secondary : Theme.dark)
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
                        .stroke(selectedCountInGroup == 0 ? Color.clear : Theme.dark, lineWidth: 1.5)
                )
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(spacing: 8) {
                    ForEach(group.topics) { topic in
                        let isSelected = selectedTopicIDs.contains(topic.id)
                        MultiTopicRow(
                            topic: topic,
                            subtitle: nil,
                            isSelected: isSelected,
                            isDisabled: isAtLimit && !isSelected
                        ) {
                            onToggleTopic(topic)
                        }
                    }
                }
                .padding(.leading, 16)
            }
        }
    }
}

private struct MultiTopicRow: View {
    let topic: QuizTopic
    var subtitle: String? = nil
    let isSelected: Bool
    let isDisabled: Bool
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

                MultiSelectCheckmark(isSelected: isSelected)
            }
            .padding(14)
            .background(Theme.bg)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .opacity(isDisabled ? 0.4 : 1)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }
}

private struct MultiSelectCheckmark: View {
    let isSelected: Bool

    var body: some View {
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
}
