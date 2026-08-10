//
//  QuestionCardView.swift
//  personalized-medical-learning-ios
//

import SwiftUI

struct QuestionCardView: View {
    let question: QuizQuestion
    var totalQuestions: Int = 1
    var isNextEnabled: Bool = true
    var isReviewModeEnabled: Bool = true
    @Binding var confidenceSelection: ConfidenceLevel?
    @Binding var nextReviewSelection: NextReviewOption?
    var onSelectOption: (Int) -> Void = { _ in }
    var onPrevious: () -> Void = {}
    var onNext: () -> Void = {}

    private var isLastQuestion: Bool { question.index >= totalQuestions }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            questionHeader
            promptText
            optionsList

            if question.selectedIndex != nil {
                if isReviewModeEnabled {
                    ExplanationCard(question: question)
                }
                ConfidenceSelectorView(selection: $confidenceSelection)
                if confidenceSelection != nil {
                    NextReviewSelectorView(selection: $nextReviewSelection)
                }
            }

            footer
        }
        .padding(24)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var questionHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Question \(question.index)/\(totalQuestions)")
                    .font(.headline)

                HStack(spacing: 8) {
                    Text(question.subject)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Theme.dark)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Theme.mint)
                        .clipShape(Capsule())

                    HStack(spacing: 4) {
                        Image(systemName: "chart.bar.fill").font(.caption2)
                        Text(question.difficulty.rawValue).font(.caption.weight(.medium))
                    }
                    .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
    }

    private var promptText: some View {
        Text(question.prompt)
            .font(.title2.weight(.semibold))
            .fixedSize(horizontal: false, vertical: true)
    }

    private var optionsList: some View {
        VStack(spacing: 12) {
            ForEach(question.options) { option in
                OptionRow(option: option, question: question) {
                    onSelectOption(option.id)
                }
            }
        }
    }

    private var footer: some View {
        HStack {
            Button(action: onPrevious) {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.left")
                    Text("Previous")
                }
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Theme.dark)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Theme.bg)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(question.index <= 1)
            .opacity(question.index <= 1 ? 0.4 : 1)

            Spacer()

            Button(action: onNext) {
                HStack(spacing: 6) {
                    Text(isLastQuestion ? "Finish" : "Next")
                    Image(systemName: isLastQuestion ? "checkmark" : "arrow.right")
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Theme.dark)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(!isNextEnabled)
            .opacity(isNextEnabled ? 1 : 0.4)
        }
    }
}

private struct OptionRow: View {
    let option: QuizOption
    let question: QuizQuestion
    let onTap: () -> Void

    private var isSelected: Bool { option.id == question.selectedIndex }
    private var isCorrect: Bool { option.id == question.correctIndex }
    private var showResult: Bool { question.selectedIndex != nil }

    private var borderColor: Color {
        guard showResult else { return Color.black.opacity(0.06) }
        if isCorrect { return .green.opacity(0.4) }
        if isSelected { return .red.opacity(0.4) }
        return Color.black.opacity(0.06)
    }

    private var backgroundColor: Color {
        guard showResult else { return Color.white }
        if isCorrect { return Color.green.opacity(0.08) }
        if isSelected { return Color.red.opacity(0.08) }
        return Color.white
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(showResult && isCorrect ? Color.green : Theme.dark)
                        .frame(width: 32, height: 32)
                    Text(option.letter)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                }

                Text(option.text)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Theme.dark)

                Spacer()

                if showResult && isCorrect {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                } else if showResult && isSelected {
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
        .buttonStyle(.plain)
        .disabled(showResult)
    }
}

private struct ExplanationCard: View {
    let question: QuizQuestion

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    ZStack {
                        Circle().fill(Theme.dark).frame(width: 28, height: 28)
                        Image(systemName: "lightbulb.fill").font(.caption).foregroundStyle(.white)
                    }
                    Text(question.explanationTitle).font(.subheadline.bold())
                }

                Text(question.explanationBody)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                HStack {
                    Text("Reference: \(question.reference)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: "flag").font(.caption2)
                        Text("Report an issue").font(.caption.weight(.medium))
                    }
                    .foregroundStyle(.secondary)
                }
                .padding(.top, 4)
            }

            Image(systemName: "heart.text.square.fill")
                .font(.system(size: 44))
                .foregroundStyle(Theme.dark.opacity(0.3))
        }
        .padding(16)
        .background(Theme.mint.opacity(0.4))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    ScrollView {
        QuestionCardView(question: QuizData.sampleQuestion, confidenceSelection: .constant(.unsure), nextReviewSelection: .constant(nil))
            .padding()
    }
    .background(Theme.bg)
}
