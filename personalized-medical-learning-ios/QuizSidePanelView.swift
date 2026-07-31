//
//  QuizSidePanelView.swift
//  personalized-medical-learning-ios
//

import SwiftUI

struct QuizSidePanelView: View {
    @ObservedObject var viewModel: QuizViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            QuizProgressCard(viewModel: viewModel)
            QuestionNavigatorCard(viewModel: viewModel)
            GetHelpCard()
        }
    }
}

struct QuizNavigatorPopoverContent: View {
    @ObservedObject var viewModel: QuizViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                QuizProgressCard(viewModel: viewModel)
                QuestionNavigatorCard(viewModel: viewModel)
            }
            .padding(20)
        }
        .frame(width: 340, height: 480)
    }
}

struct QuizProgressCard: View {
    @ObservedObject var viewModel: QuizViewModel

    private var percentText: String {
        "\(Int((viewModel.progress * 100).rounded()))%"
    }

    var body: some View {
        VStack(spacing: 18) {
            Text("Quiz Progress")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            ZStack {
                Circle()
                    .stroke(Theme.bg, lineWidth: 10)
                Circle()
                    .trim(from: 0, to: viewModel.progress)
                    .stroke(Theme.dark, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 2) {
                    Text(percentText).font(.title.bold())
                    Text("\(viewModel.totalQuestions - viewModel.unansweredCount) of \(viewModel.totalQuestions) answered")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 140, height: 140)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                StatPill(icon: "checkmark.circle.fill", tint: .green, value: "\(viewModel.correctCount)", label: "Correct")
                StatPill(icon: "xmark.circle.fill", tint: .red, value: "\(viewModel.incorrectCount)", label: "Incorrect")
                StatPill(icon: "circle", tint: .secondary, value: "\(viewModel.unansweredCount)", label: "Unanswered")
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

struct QuestionNavigatorCard: View {
    @ObservedObject var viewModel: QuizViewModel
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
                ForEach(Array(viewModel.navigatorStates.enumerated()), id: \.offset) { index, state in
                    Button {
                        viewModel.jumpTo(index: index)
                    } label: {
                        NavigatorCell(number: index + 1, state: state, isCurrent: index == viewModel.currentIndex)
                    }
                    .buttonStyle(.plain)
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
        QuizSidePanelView(viewModel: QuizViewModel(topicPath: "cardiology"))
            .padding()
            .frame(width: 340)
    }
    .background(Theme.bg)
}
