//
//  QuizViewModel.swift
//  personalized-medical-learning-ios
//

import Foundation
import Combine

@MainActor
final class QuizViewModel: ObservableObject {
    @Published private(set) var questions: [QuizQuestion] = []
    @Published private(set) var currentIndex = 0
    @Published private(set) var isLoading = false
    @Published private(set) var isSubmitting = false
    @Published var errorMessage: String?

    let topicPath: String
    private let client: APIClient

    init(topicPath: String, client: APIClient = .shared) {
        self.topicPath = topicPath
        self.client = client
    }

    var currentQuestion: QuizQuestion? {
        questions.indices.contains(currentIndex) ? questions[currentIndex] : nil
    }

    var totalQuestions: Int { questions.count }

    var correctCount: Int { questions.filter { $0.state == .correct }.count }
    var incorrectCount: Int { questions.filter { $0.state == .incorrect }.count }
    var unansweredCount: Int { questions.filter { $0.state == .unanswered }.count }
    var navigatorStates: [QuestionState] { questions.map(\.state) }

    var progress: Double {
        guard totalQuestions > 0 else { return 0 }
        let answered = totalQuestions - unansweredCount
        return Double(answered) / Double(totalQuestions)
    }

    func loadQuestions() async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            let out = try await client.getQuestions(topicPath: topicPath)
            questions = out.enumerated().map { index, question in
                QuizQuestion(index: index + 1, questionOut: question)
            }
            currentIndex = 0
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
        }
    }

    func selectOption(_ optionIndex: Int) {
        guard var question = currentQuestion, question.selectedIndex == nil else { return }
        question.selectedIndex = optionIndex
        questions[currentIndex] = question

        Task {
            await submitAnswer(optionIndex: optionIndex, questionID: question.id)
        }
    }

    private func submitAnswer(optionIndex: Int, questionID: String) async {
        isSubmitting = true
        defer { isSubmitting = false }

        do {
            let result = try await client.submitAnswer(uid: questionID, selectedIndex: optionIndex)
            guard let index = questions.firstIndex(where: { $0.id == questionID }) else { return }
            questions[index].correctIndex = result.correctIndex
        } catch {
            guard let index = questions.firstIndex(where: { $0.id == questionID }) else { return }
            questions[index].selectedIndex = nil
            errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
        }
    }

    func goToNext() {
        guard currentIndex + 1 < questions.count else { return }
        currentIndex += 1
    }

    func goToPrevious() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
    }

    func jumpTo(index: Int) {
        guard questions.indices.contains(index) else { return }
        currentIndex = index
    }

    func toggleBookmark() {
        guard questions.indices.contains(currentIndex) else { return }
        questions[currentIndex].isBookmarked.toggle()
    }
}
