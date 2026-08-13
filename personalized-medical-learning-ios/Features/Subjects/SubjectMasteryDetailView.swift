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
    @State private var showInfo = false

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

            HStack(spacing: 6) {
                Text(level.label)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(level.tint)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(level.tint.opacity(0.12))
                    .clipShape(Capsule())

                Button(action: { showInfo = true }) {
                    Image(systemName: "info.circle")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .popover(isPresented: $showInfo) {
                    MasteryInfoView()
                }
            }

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

private struct MasteryInfoView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("How this score works")
                .font(.headline)
                .foregroundStyle(Theme.dark)

            Text("This is an estimate of how well you actually know a topic — not just your last quiz grade.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 10) {
                InfoBullet(text: "It weighs your answer by how confident you said you were — a confident right answer counts more than a lucky guess.")
                InfoBullet(text: "A confident wrong answer counts as a real gap, not a slip — it moves your score down more than an unsure or guessing miss.")
                InfoBullet(text: "It updates a little after every question you answer, correct or not.")
            }

            Text("Topics needing the most work surface first so you know what to practice next.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(20)
        .frame(width: 320)
    }
}

private struct InfoBullet: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(Theme.dark.opacity(0.5))
                .frame(width: 5, height: 5)
                .padding(.top, 6)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(Theme.dark)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    RootView()
}
