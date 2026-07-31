//
//  QuizView.swift
//  personalized-medical-learning-ios
//

import SwiftUI

struct QuizView: View {
    var topicPath: String
    var onBack: () -> Void = {}

    @StateObject private var viewModel: QuizViewModel
    @State private var confidenceSelection: ConfidenceLevel?

    init(topicPath: String, onBack: @escaping () -> Void = {}) {
        self.topicPath = topicPath
        self.onBack = onBack
        _viewModel = StateObject(wrappedValue: QuizViewModel(topicPath: topicPath))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                QuizHeaderView(onBack: onBack, viewModel: viewModel)

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
                        onSelectOption: { viewModel.selectOption($0) },
                        onPrevious: { viewModel.goToPrevious() },
                        onNext: { viewModel.goToNext() }
                    )
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .background(Theme.bg)
        .safeAreaInset(edge: .bottom) {
            if viewModel.currentQuestion != nil {
                ConfidenceSelectorView(selection: $confidenceSelection)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 12)
                    .background(Theme.bg)
            }
        }
        .task {
            await viewModel.loadQuestions()
        }
        .onChange(of: viewModel.currentIndex) {
            confidenceSelection = nil
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
