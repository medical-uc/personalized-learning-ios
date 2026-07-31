//
//  QuizResultView.swift
//  personalized-medical-learning-ios
//

import SwiftUI

struct QuizResultView: View {
    let summary: QuizResultSummary
    var onBack: () -> Void = {}

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                header
                scoreCard
                statsRow
                doneButton
            }
            .padding(24)
            .frame(maxWidth: 520)
        }
        .frame(maxWidth: .infinity)
        .background(Theme.bg)
    }

    private var header: some View {
        VStack(spacing: 8) {
            Text("Quiz Complete")
                .font(.title.bold())
                .foregroundStyle(Theme.dark)
            Text(summary.topicPath)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 40)
    }

    private var scoreCard: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Theme.mint)
                    .frame(width: 120, height: 120)
                Text("\(summary.scorePercent)%")
                    .font(.title.bold())
                    .foregroundStyle(Theme.dark)
            }

            Text("\(summary.correctCount) of \(summary.totalQuestions) correct")
                .font(.headline)
                .foregroundStyle(Theme.dark)
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var statsRow: some View {
        HStack(spacing: 12) {
            ResultStatTile(icon: "checkmark.circle.fill", tint: .green, value: "\(summary.correctCount)", label: "Correct")
            ResultStatTile(icon: "xmark.circle.fill", tint: .red, value: "\(summary.incorrectCount)", label: "Incorrect")
            ResultStatTile(icon: "circle.dashed", tint: .secondary, value: "\(summary.unansweredCount)", label: "Skipped")
            ResultStatTile(icon: "clock.fill", tint: Theme.dark, value: summary.elapsedTimeText, label: "Time")
        }
    }

    private var doneButton: some View {
        Button(action: onBack) {
            Text("Back to Dashboard")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Theme.dark)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

private struct ResultStatTile: View {
    let icon: String
    let tint: Color
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(tint)
            Text(value)
                .font(.subheadline.bold())
                .foregroundStyle(Theme.dark)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    QuizResultView(
        summary: QuizResultSummary(
            topicPath: "cardiology",
            totalQuestions: 10,
            correctCount: 7,
            incorrectCount: 2,
            unansweredCount: 1,
            elapsedSeconds: 425
        )
    )
}
