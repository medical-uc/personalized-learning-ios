//
//  FlashcardAPI.swift
//  personalized-medical-learning-ios
//

import Foundation

extension APIClient {
    func getAllCards() async throws -> [FlashcardOut] {
        try await get(path: "flashcards/cards")
    }

    func startFlashcardSession(topicPath: String? = nil, size: Int? = nil) async throws -> StartFlashcardSessionResponse {
        guard let token = SessionManager.token else {
            throw APIError.server("You must be signed in to start a flashcard session.")
        }
        let path = topicPath.map { "flashcards/topics/\($0)/sessions" } ?? "flashcards/sessions"
        return try await send(
            path: path,
            body: StartFlashcardSessionRequest(size: size),
            expectedStatus: 200,
            token: token
        )
    }

    func endFlashcardSession(sessionId: String) async throws -> EndFlashcardSessionResponse {
        guard let token = SessionManager.token else {
            throw APIError.server("You must be signed in to end a flashcard session.")
        }
        return try await post(path: "flashcards/sessions/\(sessionId)/end", expectedStatus: 200, token: token)
    }

    func cancelFlashcardSession(sessionId: String) async throws -> EndFlashcardSessionResponse {
        guard let token = SessionManager.token else {
            throw APIError.server("You must be signed in to cancel a flashcard session.")
        }
        return try await post(path: "flashcards/sessions/\(sessionId)/cancel", expectedStatus: 200, token: token)
    }

    func getFlashcardSessionHistory() async throws -> [FlashcardSessionHistoryItem] {
        guard let token = SessionManager.token else {
            throw APIError.server("You must be signed in to view flashcard session history.")
        }
        let response: FlashcardSessionHistoryResponse = try await get(path: "flashcards/sessions/history", token: token)
        return response.items
    }

    func revealCard(uid: String) async throws -> FlashcardRevealResponse {
        try await post(path: "flashcards/cards/\(uid)/reveal", expectedStatus: 200)
    }

    func logReview(uid: String, sessionId: String, rating: FlashcardRating) async throws -> LogFlashcardReviewResponse {
        guard let token = SessionManager.token else {
            throw APIError.server("You must be signed in to log a review.")
        }
        let response: LogFlashcardReviewResponse = try await send(
            path: "flashcards/cards/\(uid)/log",
            body: LogFlashcardReviewRequest(sessionId: sessionId, rating: rating),
            expectedStatus: 200,
            token: token
        )
        postEnergyAwarded(response.energyAwarded, balance: response.energyBalance)
        return response
    }

    func getDueFlashcards() async throws -> [DueFlashcardItem] {
        guard let token = SessionManager.token else {
            throw APIError.server("You must be signed in to view review items.")
        }
        let response: DueFlashcardResponse = try await get(path: "flashcards/review/due", token: token)
        return response.items
    }

    func getFlashcardHistory() async throws -> [FlashcardHistoryItem] {
        guard let token = SessionManager.token else {
            throw APIError.server("You must be signed in to view flashcard history.")
        }
        let response: FlashcardHistoryResponse = try await get(path: "flashcards/history", token: token)
        return response.items
    }
}
