//
//  QuizView.swift
//  personalized-medical-learning-ios
//

import SwiftUI

struct QuizView: View {
    var topicPath: String
    var questionCount: Int?
    var isReviewModeEnabled: Bool = true
    var onBack: () -> Void = {}
    var onProgressChange: (Bool) -> Void = { _ in }

    @StateObject private var viewModel: QuizViewModel
    @State private var confidenceSelection: ConfidenceLevel?
    @State private var nextReviewSelection: NextReviewOption?
    @State private var resultSummary: QuizResultSummary?
    @State private var showExitConfirm = false

    init(topicPath: String, questionCount: Int? = nil, isReviewModeEnabled: Bool = true, onBack: @escaping () -> Void = {}, onProgressChange: @escaping (Bool) -> Void = { _ in }) {
        self.topicPath = topicPath
        self.questionCount = questionCount
        self.isReviewModeEnabled = isReviewModeEnabled
        self.onBack = onBack
        self.onProgressChange = onProgressChange
        _viewModel = StateObject(wrappedValue: QuizViewModel(topicPath: topicPath, questionCount: questionCount, isReviewModeEnabled: isReviewModeEnabled))
    }

    var body: some View {
        if let resultSummary {
            QuizResultView(summary: resultSummary, onBack: onBack)
        } else {
            quizBody
        }
    }

    private func requestExit() {
        showExitConfirm = true
    }

    private func confirmExit() {
        onProgressChange(false)
        onBack()
    }

    private var quizBody: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                QuizHeaderView(onBack: requestExit, viewModel: viewModel)

                if viewModel.isLoading {
                    ProgressView("Loading questions…")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 60)
                } else if let errorMessage = viewModel.errorMessage, viewModel.questions.isEmpty {
                    QuizErrorView(message: errorMessage) {
                        Task { await viewModel.loadQuestions() }
                    }
                } else if let question = viewModel.currentQuestion {
                    QuestionCardView(
                        question: question,
                        totalQuestions: viewModel.totalQuestions,
                        isReviewModeEnabled: viewModel.isReviewModeEnabled,
                        confidenceSelection: $confidenceSelection,
                        nextReviewSelection: $nextReviewSelection,
                        onSelectOption: { viewModel.selectOption($0) },
                        onPrevious: { viewModel.goToPrevious() },
                        onCheck: { confidence in
                            Task { await viewModel.checkCurrentAnswer(confidence: confidence) }
                        },
                        onNext: {
                            guard let confidenceSelection else { return }
                            let isLastQuestion = viewModel.isLastQuestion
                            let days = nextReviewSelection?.rawValue
                            Task {
                                await viewModel.logCurrentAnswer(confidence: confidenceSelection, nextReviewDays: days)
                                if isLastQuestion {
                                    await viewModel.finishQuiz()
                                    onProgressChange(false)
                                    resultSummary = viewModel.resultSummary
                                } else {
                                    viewModel.goToNext()
                                }
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .background(Theme.bg)
        .alert(
            "Leave quiz?",
            isPresented: $showExitConfirm
        ) {
            Button("Leave Quiz", role: .destructive, action: confirmExit)
            Button("Keep Going", role: .cancel) {}
        } message: {
            Text("Your progress on this quiz will be lost if you leave now.")
        }
        .task {
            await viewModel.loadQuestions()
            viewModel.onQuestionAppear()
            if viewModel.currentQuestion != nil {
                onProgressChange(true)
            }
        }
        .onChange(of: viewModel.currentIndex) {
            confidenceSelection = nil
            nextReviewSelection = nil
            viewModel.onQuestionAppear()
        }
        .onDisappear {
            viewModel.stopTimer()
            Task { await viewModel.cancelQuiz() }
        }
    }
}

private struct QuizErrorView: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Retry", action: onRetry)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Theme.dark)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

#Preview {
    RootView()
}
