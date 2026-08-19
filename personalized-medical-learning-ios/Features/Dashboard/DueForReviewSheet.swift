//
//  DueForReviewSheet.swift
//  personalized-medical-learning-ios
//

import SwiftUI

/// What to review when a row (or the "Review All" button) is tapped. Quiz has no
/// per-topic due-only session mode today, so quiz rows always resolve to the all-due
/// batch; flashcards support a true per-topic due-only setup, so `topicPath` is threaded
/// through and used to scope that session.
struct ReviewRequest {
    let source: NudgeSource
    let topicPath: String?
}

struct DueForReviewSheet: View {
    let totalDueCount: Int
    let breakdown: [NudgeTopicBreakdown]
    var onReviewTopic: (ReviewRequest) -> Void

    @Environment(\.dismiss) private var dismiss

    private var quizRows: [NudgeTopicBreakdown] { breakdown.filter { $0.source == .quiz } }
    private var flashcardRows: [NudgeTopicBreakdown] { breakdown.filter { $0.source == .flashcard } }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("\(totalDueCount) item\(totalDueCount == 1 ? "" : "s") due for review")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    if !quizRows.isEmpty {
                        section(title: "Quiz Questions", rows: quizRows)
                    }

                    if !flashcardRows.isEmpty {
                        section(title: "Flashcards", rows: flashcardRows)
                    }
                }
                .padding(20)
            }
            .background(Theme.bg)
            .navigationTitle("Due for Review")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private func section(title: String, rows: [NudgeTopicBreakdown]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.headline)

            VStack(spacing: 10) {
                ForEach(rows) { row in
                    DueTopicRow(row: row) {
                        onReviewTopic(ReviewRequest(source: row.source, topicPath: row.topicPath))
                    }
                }
            }
        }
    }
}

private struct DueTopicRow: View {
    let row: NudgeTopicBreakdown
    var onTap: () -> Void

    private var icon: String { row.source == .quiz ? "questionmark.circle" : "rectangle.stack" }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                ZStack {
                    Circle().fill(Color.orange.opacity(0.15)).frame(width: 40, height: 40)
                    Image(systemName: icon).foregroundStyle(.orange)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(row.topicName)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.dark)
                        .lineLimit(1)
                    Text(row.subjectName)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer(minLength: 8)

                Text("\(row.dueCount)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.orange)

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(14)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }
}
