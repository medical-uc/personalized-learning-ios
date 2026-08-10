//
//  QuizResultView.swift
//  personalized-medical-learning-ios
//

import SwiftUI

struct QuizResultView: View {
    let summary: QuizResultSummary
    var onBack: () -> Void = {}

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 24) {
                    header
                    scoreCard
                    statsRow

                    if !summary.reviewQuestions.isEmpty {
                        reviewSection
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 100)
            }

            doneButton
                .padding(.horizontal, 24)
                .padding(.top, 12)
                .padding(.bottom, 24)
                .background(.ultraThinMaterial)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.bg)
    }

    private var reviewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Review Answers")
                .font(.headline)
                .foregroundStyle(Theme.dark)

            ForEach(summary.reviewQuestions) { question in
                ReviewQuestionCard(question: question)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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

private struct ReviewQuestionCard: View {
    let question: QuizQuestion

    private var stateColor: Color {
        switch question.state {
        case .correct: return .green
        case .incorrect: return .red
        case .unanswered: return .secondary
        }
    }

    private var stateIcon: String {
        switch question.state {
        case .correct: return "checkmark.circle.fill"
        case .incorrect: return "xmark.circle.fill"
        case .unanswered: return "circle.dashed"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                Text("Question \(question.index)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.dark)
                Spacer()
                Image(systemName: stateIcon).foregroundStyle(stateColor)
            }

            Text(question.prompt)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Theme.dark)
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: 10) {
                ForEach(question.options) { option in
                    ReviewOptionRow(option: option, question: question)
                }
            }

            if question.selectedIndex == nil {
                Text("Not answered")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    ZStack {
                        Circle().fill(Theme.dark).frame(width: 24, height: 24)
                        Image(systemName: "lightbulb.fill").font(.caption2).foregroundStyle(.white)
                    }
                    Text(question.explanationTitle).font(.caption.bold())
                }

                Text(question.explanationBody)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Reference: \(question.reference)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding(12)
            .background(Theme.mint.opacity(0.4))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

private struct ReviewOptionRow: View {
    let option: QuizOption
    let question: QuizQuestion

    private var isSelected: Bool { option.id == question.selectedIndex }
    private var isCorrect: Bool { option.id == question.correctIndex }

    private var borderColor: Color {
        if isCorrect { return .green.opacity(0.4) }
        if isSelected { return .red.opacity(0.4) }
        return Color.black.opacity(0.06)
    }

    private var backgroundColor: Color {
        if isCorrect { return Color.green.opacity(0.08) }
        if isSelected { return Color.red.opacity(0.08) }
        return Color.white
    }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(isCorrect ? Color.green : Theme.dark)
                    .frame(width: 32, height: 32)
                Text(option.letter)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
            }

            Text(option.text)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Theme.dark)

            Spacer()

            if isCorrect {
                Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
            } else if isSelected {
                Image(systemName: "xmark.circle.fill").foregroundStyle(.red)
            } else {
                Circle()
                    .stroke(Color.black.opacity(0.15), lineWidth: 1.5)
                    .frame(width: 22, height: 22)
            }
        }
        .padding(16)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(borderColor, lineWidth: 1.5))
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
