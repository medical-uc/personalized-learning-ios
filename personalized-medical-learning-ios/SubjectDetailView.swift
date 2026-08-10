//
//  SubjectDetailView.swift
//  personalized-medical-learning-ios
//

import SwiftUI

struct SubjectDetailView: View {
    let subject: StudySubject
    var onBack: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HeroCard(subject: subject, onBack: onBack)
            TopicsSection(subject: subject)
        }
    }
}

private struct HeroCard: View {
    let subject: StudySubject
    var onBack: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(Theme.dark)
                        .frame(width: 36, height: 36)
                        .background(Color.white)
                        .clipShape(Circle())
                }

                Spacer()
            }

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 10) {
                        Text(subject.name).font(.largeTitle.bold())
                        Text(MasteryLevel(pKnow: subject.progress).label)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Theme.dark)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.white)
                            .clipShape(Capsule())
                    }

                    Text("\(subject.masteredConcepts) / \(subject.topics.count) topics mastered")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 0)

                Image(systemName: subject.icon)
                    .font(.system(size: 90))
                    .foregroundStyle(subject.tint)
                    .opacity(0.85)
            }

            StatTilesRow(subject: subject)
        }
        .padding(28)
        .background(subject.tint.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

private struct StatTilesRow: View {
    let subject: StudySubject

    var body: some View {
        let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

        LazyVGrid(columns: columns, spacing: 14) {
            StatTile(icon: "list.bullet", value: "\(subject.topics.count)", label: "Topics")
            StatTile(icon: "questionmark.circle", value: "\(subject.questionCount)", label: "Questions")
            StatTile(icon: "rectangle.stack", value: "\(subject.flashcardCount)", label: "Flashcards")
        }
    }
}

private struct StatTile: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(Theme.dark)
            VStack(alignment: .leading, spacing: 2) {
                Text(value).font(.title3.bold())
                Text(label).font(.caption2).foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

private struct TopicsSection: View {
    let subject: StudySubject

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Topics").font(.title3.bold())

            if subject.topics.isEmpty {
                Text("No topics yet.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity)
            } else {
                VStack(spacing: 12) {
                    ForEach(subject.topics) { topic in
                        TopicRow(topic: topic)
                    }
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

private struct TopicRow: View {
    let topic: Topic

    private var level: MasteryLevel { MasteryLevel(pKnow: topic.progress) }

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(topic.isComplete ? Color.green.opacity(0.15) : Theme.bg)
                    .frame(width: 32, height: 32)
                if topic.isComplete {
                    Image(systemName: "checkmark").font(.caption.bold()).foregroundStyle(.green)
                } else {
                    Text("\(topic.number)").font(.caption.weight(.semibold))
                }
            }

            Text(topic.name)
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(level.label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(level.tint)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(width: 76, alignment: .trailing)

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(topic.questionCount) questions").font(.caption2).foregroundStyle(.secondary)
                Text("\(topic.flashcardCount) flashcards").font(.caption2).foregroundStyle(.secondary)
            }
            .frame(width: 100, alignment: .trailing)

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    RootView()
}
