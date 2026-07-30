//
//  SubjectDetailView.swift
//  personalized-medical-learning-ios
//

import SwiftUI

struct SubjectDetailView: View {
    let subject: Subject
    var onBack: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HeroCard(subject: subject, onBack: onBack)
            TopicsSection(subject: subject)
            BottomSection(subject: subject)
        }
    }
}

private struct HeroCard: View {
    let subject: Subject
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

                Button {} label: {
                    Image(systemName: "bookmark")
                        .foregroundStyle(Theme.dark)
                        .frame(width: 36, height: 36)
                        .background(Color.white)
                        .clipShape(Circle())
                }

                Button {} label: {
                    Image(systemName: "ellipsis")
                        .foregroundStyle(Theme.dark)
                        .frame(width: 36, height: 36)
                        .background(Color.white)
                        .clipShape(Circle())
                }
            }

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 10) {
                        Text(subject.name).font(.largeTitle.bold())
                        Text("\(Int(subject.progress * 100))% Mastered")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Theme.dark)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.white)
                            .clipShape(Capsule())
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        ProgressView(value: subject.progress)
                            .tint(Theme.dark)
                        Text("\(subject.masteredConcepts) / \(subject.concepts) concepts mastered")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: 420)

                    Text(subject.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: 460, alignment: .leading)
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
    let subject: Subject

    var body: some View {
        let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

        LazyVGrid(columns: columns, spacing: 14) {
            StatTile(icon: "book", value: "\(subject.concepts)", label: "Concepts")
            StatTile(icon: "questionmark.circle", value: "\(subject.questions)", label: "Questions")
            StatTile(icon: "rectangle.stack", value: "\(subject.flashcards)", label: "Flashcards")
            StatTile(icon: "clock", value: subject.timeStudied, label: "Time Studied")
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
    let subject: Subject

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Topics").font(.title3.bold())
                Spacer()
                Button {} label: {
                    HStack(spacing: 6) {
                        Image(systemName: "point.3.connected.trianglepath.dotted")
                        Text("Learning Path")
                    }
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Theme.dark)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Theme.bg)
                    .clipShape(Capsule())
                }
            }

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

    private var progressColor: Color {
        if topic.progress >= 0.8 { return .green }
        if topic.progress >= 0.5 { return .orange }
        return .red
    }

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

            VStack(alignment: .leading, spacing: 4) {
                Text(topic.name).font(.subheadline.weight(.semibold))
                Text(topic.description).font(.caption2).foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Text("\(Int(topic.progress * 100))%")
                .font(.subheadline.weight(.semibold))
                .frame(width: 44, alignment: .trailing)

            ProgressView(value: topic.progress)
                .tint(progressColor)
                .frame(width: 120)

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(topic.concepts) concepts").font(.caption2).foregroundStyle(.secondary)
                Text("\(topic.flashcards) flashcards").font(.caption2).foregroundStyle(.secondary)
            }
            .frame(width: 100, alignment: .trailing)

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 6)
    }
}

private struct BottomSection: View {
    let subject: Subject

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .top, spacing: 20) {
                RecommendedNextCard(subject: subject)
                    .frame(maxWidth: .infinity)
                RelatedConceptsCard(subject: subject)
                    .frame(maxWidth: .infinity)
            }

            VStack(alignment: .leading, spacing: 20) {
                RecommendedNextCard(subject: subject)
                RelatedConceptsCard(subject: subject)
            }
        }
    }
}

private struct RecommendedNextCard: View {
    let subject: Subject

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle().fill(Theme.dark).frame(width: 44, height: 44)
                Image(systemName: "sparkles").foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Recommended Next").font(.subheadline.bold())
                Text("Based on your progress, we recommend")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(subject.recommendedTopic).font(.subheadline.weight(.semibold))

                Button {} label: {
                    Text("Start Learning")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Theme.dark)
                        .clipShape(Capsule())
                }
                .padding(.top, 4)
            }

            Spacer(minLength: 0)
        }
        .padding(18)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

private struct RelatedConceptsCard: View {
    let subject: Subject

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Related Concepts").font(.subheadline.bold())
                Spacer()
                Image(systemName: "chevron.right").font(.caption).foregroundStyle(.secondary)
            }

            FlowLayout(spacing: 8) {
                ForEach(subject.relatedConcepts, id: \.self) { concept in
                    Text(concept)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Theme.dark)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Theme.bg)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(18)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

private struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > width, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }

        return CGSize(width: width, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

#Preview {
    ScrollView {
        SubjectDetailView(subject: SubjectData.subjects[0])
            .padding(24)
    }
    .background(Theme.bg)
}
