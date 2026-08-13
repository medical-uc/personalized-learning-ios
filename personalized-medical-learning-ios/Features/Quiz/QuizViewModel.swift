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
    let isReviewModeEnabled: Bool
    private let questionCount: Int?
    private let client: any APIClientProtocol
    private var timerCancellable: AnyCancellable?
    private var questionShownAt: Date?
    private var answerTimeTaken: [String: Double] = [:]
    private var sessionId: String?

    init(topicPath: String, questionCount: Int? = nil, isReviewModeEnabled: Bool = true, client: any APIClientProtocol = APIClient.shared) {
        self.topicPath = topicPath
        self.questionCount = questionCount
        self.isReviewModeEnabled = isReviewModeEnabled
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
        resumeTimer()
    }

    func resumeTimer() {
        guard timerCancellable == nil else { return }
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.elapsedSeconds += 1
            }
    }

    func pauseTimer() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }

    func stopTimer() {
        pauseTimer()
    }

    func onQuestionAppear() {
        questionShownAt = Date()
        if currentQuestion?.selectedIndex == nil {
            resumeTimer()
        } else {
            pauseTimer()
        }
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
            let limited = questionCount.map { Array(out.prefix($0)) } ?? out
            questions = limited.enumerated().map { index, question in
                QuizQuestion(index: index + 1, questionOut: question)
            }
            sessionId = session.sessionId
            currentIndex = 0
            startTimer()
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
        }
    }

    /// Freely re-selectable until checkCurrentAnswer() locks the question — a student
    /// can change their pick any number of times before tapping "Check Answer".
    func selectOption(_ optionIndex: Int) {
        guard var question = currentQuestion, question.correctIndex == nil else { return }
        question.selectedIndex = optionIndex
        questions[currentIndex] = question

        answerTimeTaken[question.id] = Date().timeIntervalSince(questionShownAt ?? Date())
        pauseTimer()
    }

    /// Reveals correct/incorrect + explanation — called once the student taps
    /// "Check Answer" (after picking both an option and a confidence level), not the
    /// moment they pick an option. confidence feeds BKTStore directly here (rather than
    /// waiting for logCurrentAnswer's server log) since p_slip/p_guess are now
    /// confidence-conditional and this is the first point both correct/incorrect and
    /// confidence are both known.
    func checkCurrentAnswer(confidence: ConfidenceLevel) async {
        guard let question = currentQuestion, let selectedIndex = question.selectedIndex, question.correctIndex == nil else { return }
        await checkAnswer(optionIndex: selectedIndex, questionID: question.id, confidence: confidence)
    }

    /// Logs the current question's attempt — called once the student taps Next/Finish,
    /// so both their confidence and next-review choice are captured in a single write.
    func logCurrentAnswer(confidence: ConfidenceLevel, nextReviewDays: Int?) async {
        guard let question = currentQuestion, let selectedIndex = question.selectedIndex, !question.isLogged else { return }
        await logAttempt(optionIndex: selectedIndex, questionID: question.id, confidence: confidence, nextReviewDays: nextReviewDays)
    }

    private func checkAnswer(optionIndex: Int, questionID: String, confidence: ConfidenceLevel) async {
        do {
            let result = try await client.checkAnswer(uid: questionID, selectedIndex: optionIndex)
            guard let index = questions.firstIndex(where: { $0.id == questionID }) else { return }
            questions[index].correctIndex = result.correctIndex
            questions[index].explanationBody = result.explanation
            let topicPath = questions[index].topicPath
            BKTStore.record(topicPath: topicPath, correct: result.correct, confidence: confidence)
            syncMastery(topicPath: topicPath)
        } catch {
            guard let index = questions.firstIndex(where: { $0.id == questionID }) else { return }
            questions[index].selectedIndex = nil
            errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
        }
    }

    private func logAttempt(optionIndex: Int, questionID: String, confidence: ConfidenceLevel, nextReviewDays: Int?) async {
        guard let index = questions.firstIndex(where: { $0.id == questionID }), !questions[index].isLogged else { return }
        guard let sessionId else { return }
        isSubmitting = true
        defer { isSubmitting = false }

        let timeTaken = answerTimeTaken[questionID] ?? 0

        do {
            let result = try await client.logAttempt(
                uid: questionID,
                sessionId: sessionId,
                selectedIndex: optionIndex,
                confidence: confidence.apiValue,
                timeTakenSeconds: timeTaken,
                nextReviewDays: nextReviewDays
            )
            guard let index = questions.firstIndex(where: { $0.id == questionID }) else { return }
            questions[index].isLogged = true
            questions[index].nextReviewAt = result.nextReviewAt
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
            self.sessionId = nil
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
        }
        await syncMastery()
    }

    /// Pushes this session's on-device BKT results (see BKTStore, updated per-answer in
    /// checkAnswer()) up to the server so they survive across devices/reinstalls. Best-effort:
    /// the device's BKTStore is already the source of truth and the student has already seen
    /// their results, so a sync failure here shouldn't surface as a quiz-ending error. Kept as
    /// a session-end safety net alongside the per-answer sync in checkAnswer(), in case a
    /// per-answer push was dropped (e.g. offline mid-quiz).
    private func syncMastery() async {
        let topicPaths = Set(questions.map(\.topicPath))
        guard !topicPaths.isEmpty else { return }
        let items = topicPaths.map { MasteryUpdateItem(topicPath: $0, pKnow: BKTStore.pKnow(for: $0)) }
        _ = try? await client.putMastery(items)
    }

    /// Fire-and-forget push of a single topic's freshly-updated p_know, right after
    /// checkAnswer() records it — so the server stays current within one answer instead of
    /// lagging until finishQuiz(). Detached so it never blocks the answer-reveal/Next UI on
    /// a network roundtrip; failures are silently dropped, same as syncMastery() above.
    private func syncMastery(topicPath: String) {
        let item = MasteryUpdateItem(topicPath: topicPath, pKnow: BKTStore.pKnow(for: topicPath))
        Task {
            _ = try? await client.putMastery([item])
        }
    }

    func cancelQuiz() async {
        stopTimer()
        guard let sessionId else { return }
        self.sessionId = nil
        _ = try? await client.cancelSession(sessionId: sessionId)
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
            elapsedSeconds: elapsedSeconds,
            reviewQuestions: isReviewModeEnabled ? [] : questions
        )
    }

    func toggleBookmark() {
        guard questions.indices.contains(currentIndex) else { return }
        questions[currentIndex].isBookmarked.toggle()
    }
}
