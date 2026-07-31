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
    @Published private(set) var elapsedSeconds = 0
    @Published var errorMessage: String?

    let topicPath: String
    private let client: APIClient
    private var timerCancellable: AnyCancellable?
    private var questionShownAt: Date?
    private var answerTimeTaken: [String: Double] = [:]
    private var sessionId: String?

    init(topicPath: String, client: APIClient = .shared) {
        self.topicPath = topicPath
        self.client = client
    }

    var elapsedTimeText: String {
        let minutes = elapsedSeconds / 60
        let seconds = elapsedSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func startTimer() {
        guard timerCancellable == nil else { return }
        elapsedSeconds = 0
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.elapsedSeconds += 1
            }
    }

    func stopTimer() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }

    func onQuestionAppear() {
        questionShownAt = Date()
    }

    var currentQuestion: QuizQuestion? {
        questions.indices.contains(currentIndex) ? questions[currentIndex] : nil
    }

    var totalQuestions: Int { questions.count }
    var isLastQuestion: Bool { currentIndex + 1 >= questions.count }

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
            async let questionsTask = client.getQuestions(topicPath: topicPath)
            async let sessionTask = client.startSession(topicPath: topicPath)
            let (out, session) = try await (questionsTask, sessionTask)
            questions = out.enumerated().map { index, question in
                QuizQuestion(index: index + 1, questionOut: question)
            }
            sessionId = session.sessionId
            currentIndex = 0
            startTimer()
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
        }
    }

    func selectOption(_ optionIndex: Int, confidence: ConfidenceLevel?) {
        guard var question = currentQuestion, question.selectedIndex == nil else { return }
        question.selectedIndex = optionIndex
        questions[currentIndex] = question
        let questionID = question.id

        answerTimeTaken[questionID] = Date().timeIntervalSince(questionShownAt ?? Date())

        Task {
            await checkAnswer(optionIndex: optionIndex, questionID: questionID)
            if let confidence {
                await logAttempt(optionIndex: optionIndex, questionID: questionID, confidence: confidence)
            }
        }
    }

    func confirmConfidence(_ confidence: ConfidenceLevel) {
        guard let question = currentQuestion, let selectedIndex = question.selectedIndex, !question.isLogged else { return }
        Task {
            await logAttempt(optionIndex: selectedIndex, questionID: question.id, confidence: confidence)
        }
    }

    private func checkAnswer(optionIndex: Int, questionID: String) async {
        do {
            let result = try await client.checkAnswer(uid: questionID, selectedIndex: optionIndex)
            guard let index = questions.firstIndex(where: { $0.id == questionID }) else { return }
            questions[index].correctIndex = result.correctIndex
        } catch {
            guard let index = questions.firstIndex(where: { $0.id == questionID }) else { return }
            questions[index].selectedIndex = nil
            errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
        }
    }

    private func logAttempt(optionIndex: Int, questionID: String, confidence: ConfidenceLevel) async {
        guard let index = questions.firstIndex(where: { $0.id == questionID }), !questions[index].isLogged else { return }
        guard let sessionId else { return }
        isSubmitting = true
        defer { isSubmitting = false }

        let timeTaken = answerTimeTaken[questionID] ?? 0

        do {
            _ = try await client.logAttempt(
                uid: questionID,
                sessionId: sessionId,
                selectedIndex: optionIndex,
                confidence: confidence.apiValue,
                timeTakenSeconds: timeTaken
            )
            guard let index = questions.firstIndex(where: { $0.id == questionID }) else { return }
            questions[index].isLogged = true
            answerTimeTaken.removeValue(forKey: questionID)
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
        }
    }

    func finishQuiz() async {
        stopTimer()
        guard let sessionId else { return }
        do {
            _ = try await client.endSession(sessionId: sessionId)
        } catch {
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

    var resultSummary: QuizResultSummary {
        QuizResultSummary(
            topicPath: topicPath,
            totalQuestions: totalQuestions,
            correctCount: correctCount,
            incorrectCount: incorrectCount,
            unansweredCount: unansweredCount,
            elapsedSeconds: elapsedSeconds
        )
    }

    func toggleBookmark() {
        guard questions.indices.contains(currentIndex) else { return }
        questions[currentIndex].isBookmarked.toggle()
    }
}
