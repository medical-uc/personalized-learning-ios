//
//  QuizSidePanelView.swift
//  personalized-medical-learning-ios
//

import SwiftUI

struct QuizSidePanelView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            QuizProgressCard()
            QuestionNavigatorCard()
            GetHelpCard()
        }
    }
}

private struct QuizProgressCard: View {
    private var progress: Double { Double(3) / Double(QuizData.totalQuestions) }

    var body: some View {
        VStack(spacing: 18) {
            Text("Quiz Progress")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            ZStack {
                Circle()
                    .stroke(Theme.bg, lineWidth: 10)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Theme.dark, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 2) {
                    Text("30%").font(.title.bold())
                    Text("3 of 10 answered").font(.caption2).foregroundStyle(.secondary)
                }
            }
            .frame(width: 140, height: 140)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                StatPill(icon: "checkmark.circle.fill", tint: .green, value: "\(QuizData.correctCount)", label: "Correct")
                StatPill(icon: "xmark.circle.fill", tint: .red, value: "\(QuizData.incorrectCount)", label: "Incorrect")
                StatPill(icon: "circle", tint: .secondary, value: "\(QuizData.unansweredCount)", label: "Unanswered")
                StatPill(icon: "circle", tint: .secondary, value: QuizData.avgTime, label: "Avg. Time")
            }
        }
        .padding(18)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

private struct StatPill: View {
    let icon: String
    let tint: Color
    let value: String
    let label: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(tint)
            VStack(alignment: .leading, spacing: 0) {
                Text(value).font(.subheadline.bold())
                Text(label).font(.caption2).foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(Theme.bg)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct QuestionNavigatorCard: View {
    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Question Navigator").font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                LegendRow(icon: "checkmark.circle.fill", tint: .green, text: "Correct")
                LegendRow(icon: "xmark.circle.fill", tint: .red, text: "Incorrect")
                LegendRow(icon: "circle", tint: .secondary, text: "Unanswered")
                LegendRow(icon: "bookmark.fill", tint: Theme.dark, text: "Bookmarked")
            }

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(Array(QuizData.navigatorStates.enumerated()), id: \.offset) { index, state in
                    NavigatorCell(number: index + 1, state: state, isCurrent: index == 2)
                }
            }
        }
        .padding(18)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

private struct LegendRow: View {
    let icon: String
    let tint: Color
    let text: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon).font(.caption).foregroundStyle(tint)
            Text(text).font(.caption).foregroundStyle(.secondary)
        }
    }
}

private struct NavigatorCell: View {
    let number: Int
    let state: QuestionState
    let isCurrent: Bool

    private var background: Color {
        switch state {
        case .correct: return Color.green.opacity(0.12)
        case .incorrect: return Color.red.opacity(0.12)
        case .unanswered: return Theme.bg
        }
    }

    var body: some View {
        VStack(spacing: 2) {
            Text("\(number)").font(.subheadline.weight(.semibold))
            if state == .correct {
                Image(systemName: "checkmark").font(.system(size: 8)).foregroundStyle(.green)
            } else if state == .incorrect {
                Image(systemName: "xmark").font(.system(size: 8)).foregroundStyle(.red)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(background)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isCurrent ? Theme.dark : Color.clear, lineWidth: 2)
        )
    }
}

private struct GetHelpCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Need Help?").font(.headline)
            Text("See an explanation, hint, or related notes.")
                .font(.caption)
                .foregroundStyle(.secondary)

            Button {} label: {
                HStack(spacing: 6) {
                    Image(systemName: "bubble.left")
                    Text("Get Help")
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.dark)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Theme.bg)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(18)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    ScrollView {
        QuizSidePanelView()
            .padding()
            .frame(width: 340)
    }
    .background(Theme.bg)
}
