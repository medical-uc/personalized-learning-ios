//
//  QuizView.swift
//  personalized-medical-learning-ios
//

import SwiftUI

struct QuizView: View {
    var topicPath: String
    var questionCount: Int?
    var onBack: () -> Void = {}
    var onProgressChange: (Bool) -> Void = { _ in }

    @StateObject private var viewModel: QuizViewModel
    @State private var confidenceSelection: ConfidenceLevel?
    @State private var resultSummary: QuizResultSummary?
    @State private var showExitConfirm = false

    init(topicPath: String, questionCount: Int? = nil, onBack: @escaping () -> Void = {}, onProgressChange: @escaping (Bool) -> Void = { _ in }) {
        self.topicPath = topicPath
        self.questionCount = questionCount
        self.onBack = onBack
        self.onProgressChange = onProgressChange
        _viewModel = StateObject(wrappedValue: QuizViewModel(topicPath: topicPath, questionCount: questionCount))
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
                        isNextEnabled: confidenceSelection != nil,
                        confidenceSelection: $confidenceSelection,
                        onSelectOption: { viewModel.selectOption($0, confidence: confidenceSelection) },
                        onPrevious: { viewModel.goToPrevious() },
                        onNext: {
                            if viewModel.isLastQuestion {
                                let summary = viewModel.resultSummary
                                Task {
                                    await viewModel.finishQuiz()
                                    onProgressChange(false)
                                    resultSummary = summary
                                }
                            } else {
                                viewModel.goToNext()
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
            viewModel.onQuestionAppear()
        }
        .onChange(of: confidenceSelection) {
            if let confidenceSelection {
                viewModel.confirmConfidence(confidenceSelection)
            }
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
