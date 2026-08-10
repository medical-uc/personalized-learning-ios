//
//  QuizAPI.swift
//  personalized-medical-learning-ios
//

import Foundation

extension APIClient {
    func getQuestions(topicPath: String) async throws -> [QuestionOut] {
        try await get(path: "quiz/topics/\(topicPath)/questions")
    }

    func checkAnswer(uid: String, selectedIndex: Int) async throws -> CheckAnswerResponse {
        try await send(
            path: "quiz/questions/\(uid)/check",
            body: CheckAnswerRequest(selectedIndex: selectedIndex),
            expectedStatus: 200
        )
    }

    func logAttempt(uid: String, sessionId: String, selectedIndex: Int, confidence: String, timeTakenSeconds: Double, nextReviewDays: Int? = nil) async throws -> LogAttemptResponse {
        guard let token = SessionManager.token else {
            throw APIError.server("You must be signed in to submit an answer.")
        }
        return try await send(
            path: "quiz/questions/\(uid)/log",
            body: LogAttemptRequest(sessionId: sessionId, selectedIndex: selectedIndex, confidence: confidence, timeTakenSeconds: timeTakenSeconds, nextReviewDays: nextReviewDays),
            expectedStatus: 200,
            token: token
        )
    }

    func startSession(topicPath: String) async throws -> StartSessionResponse {
        guard let token = SessionManager.token else {
            throw APIError.server("You must be signed in to start a quiz.")
        }
        return try await post(path: "quiz/topics/\(topicPath)/sessions", expectedStatus: 200, token: token)
    }

    func endSession(sessionId: String) async throws -> EndSessionResponse {
        guard let token = SessionManager.token else {
            throw APIError.server("You must be signed in to end a quiz.")
        }
        let response: EndSessionResponse = try await post(path: "quiz/sessions/\(sessionId)/end", expectedStatus: 200, token: token)
        postEnergyAwarded(response.energyAwarded, balance: response.energyBalance)
        return response
    }

    func cancelSession(sessionId: String) async throws -> CancelSessionResponse {
        guard let token = SessionManager.token else {
            throw APIError.server("You must be signed in to cancel a quiz.")
        }
        return try await post(path: "quiz/sessions/\(sessionId)/cancel", expectedStatus: 200, token: token)
    }
}
