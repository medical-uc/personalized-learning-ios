//
//  APIClientProtocol.swift
//  personalized-medical-learning-ios
//

import Foundation

/// Every network-facing method ViewModels call on APIClient. ViewModels should depend
/// on this protocol (`client: any APIClientProtocol`) rather than the concrete
/// APIClient type, so a mock conforming to this protocol can be substituted in tests.
protocol APIClientProtocol: AnyObject {
    // Auth
    func registerStudent(fullName: String, studentNumber: String, academicYear: Int) async throws -> StudentRegisterResponse
    func loginStudent(studentNumber: String) async throws -> SessionResponse
    func logoutStudent(token: String) async throws
    func checkSession() async -> SessionCheckResponse?

    // Dashboard
    func getStudentProfile() async throws -> StudentProfileResponse
    func getStreak() async throws -> StreakResponse
    func restoreStreak() async throws -> RestoreStreakResponse
    func getEnergy() async throws -> EnergyResponse
    func getNudge() async throws -> NudgeResponse

    // Subjects
    func listTopics() async throws -> [String]
    func listSubjects() async throws -> [SubjectOut]

    // Quiz
    func getQuestions(topicPath: String) async throws -> [QuestionOut]
    func getAllQuestions() async throws -> [QuestionOut]
    func checkAnswer(uid: String, selectedIndex: Int) async throws -> CheckAnswerResponse
    func logAttempt(uid: String, sessionId: String, selectedIndex: Int, confidence: String, timeTakenSeconds: Double, nextReviewDays: Int?) async throws -> LogAttemptResponse
    func startSession(topicPath: String) async throws -> StartSessionResponse
    func startBatchSession(size: Int?) async throws -> StartBatchSessionResponse
    func endSession(sessionId: String) async throws -> EndSessionResponse
    func cancelSession(sessionId: String) async throws -> CancelSessionResponse

    // Flashcards
    func getAllCards() async throws -> [FlashcardOut]
    func startFlashcardSession(topicPath: String?, size: Int?) async throws -> StartFlashcardSessionResponse
    func endFlashcardSession(sessionId: String) async throws -> EndFlashcardSessionResponse
    func cancelFlashcardSession(sessionId: String) async throws -> EndFlashcardSessionResponse
    func getFlashcardSessionHistory() async throws -> [FlashcardSessionHistoryItem]
    func revealCard(uid: String) async throws -> FlashcardRevealResponse
    func logReview(uid: String, sessionId: String, rating: FlashcardRating) async throws -> LogFlashcardReviewResponse
    func getDueFlashcards() async throws -> [DueFlashcardItem]
    func getFlashcardHistory() async throws -> [FlashcardHistoryItem]

    // Mastery
    func getDueForReview() async throws -> [DueReviewItem]
    @discardableResult
    func putMastery(_ items: [MasteryUpdateItem]) async throws -> UpdateMasteryResponse

    // History
    func getHistory() async throws -> [HistoryItem]
}

extension APIClient: APIClientProtocol {}
