//
//  SubjectMasteryDetailView.swift
//  personalized-medical-learning-ios
//

import SwiftUI

/// Subject-level rollup of the same BKT mastery shown per-topic. subject.progress is a
/// plain mean of its topics' p_know (see StudySubject.progress) — there's no separate
/// BKT state at subject granularity, so this view explains the number by decomposing it
/// back into the topics that produced it, rather than pretending it has its own history.
struct SubjectMasteryDetailView: View {
    let subject: StudySubject
    var onSelectTopic: (Topic) -> Void = { _ in }
    @Environment(\.dismiss) private var dismiss

    private var level: MasteryLevel { MasteryLevel(pKnow: subject.progress) }

    private var bandCounts: [(level: MasteryLevel, count: Int)] {
        [MasteryLevel.strong, .developing, .needsWork].map { band in
            (band, subject.topics.filter { MasteryLevel(pKnow: $0.progress) == band }.count)
        }
    }

    private var weakestTopics: [Topic] {
        subject.topics.sorted { $0.progress < $1.progress }.prefix(5).map { $0 }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    summaryCard
                    bandBreakdown
                    weakestTopicsSection
                }
                .padding(20)
            }
            .background(Theme.bg)
            .navigationTitle("Subject Mastery")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private var summaryCard: some View {
        VStack(spacing: 12) {
            Text("\(Int((subject.progress * 100).rounded()))%")
                .font(.system(size: 44, weight: .bold))
                .foregroundStyle(level.tint)

            Text(level.label)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(level.tint)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(level.tint.opacity(0.12))
                .clipShape(Capsule())

            Text("This is the average knowledge level across all \(subject.topics.count) topics in \(subject.name) — not its own separate score. Each topic keeps its own BKT estimate; this number just summarizes them.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var bandBreakdown: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Topics by level")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.dark)

            VStack(spacing: 8) {
                ForEach(bandCounts, id: \.level) { entry in
                    HStack(spacing: 10) {
                        Circle()
                            .fill(entry.level.tint)
                            .frame(width: 8, height: 8)
                        Text(entry.level.label)
                            .font(.caption.weight(.medium))
                            .foregroundStyle(Theme.dark)
                        Spacer()
                        Text("\(entry.count)")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var weakestTopicsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Bringing this subject down")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.dark)

            if weakestTopics.isEmpty {
                Text("No topics yet.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                VStack(spacing: 8) {
                    ForEach(weakestTopics) { topic in
                        Button {
                            onSelectTopic(topic)
                        } label: {
                            weakTopicRow(topic)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func weakTopicRow(_ topic: Topic) -> some View {
        let topicLevel = MasteryLevel(pKnow: topic.progress)
        return HStack(spacing: 10) {
            Text(topic.name)
                .font(.caption.weight(.medium))
                .foregroundStyle(Theme.dark)
                .lineLimit(1)
            Spacer()
            Text("\(Int((topic.progress * 100).rounded()))%")
                .font(.caption.weight(.semibold))
                .foregroundStyle(topicLevel.tint)
            Image(systemName: "chevron.right")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    RootView()
}
