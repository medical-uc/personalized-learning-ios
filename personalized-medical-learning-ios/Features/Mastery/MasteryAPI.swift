//
//  MasteryAPI.swift
//  personalized-medical-learning-ios
//

import Foundation

extension APIClient {
    func getDueForReview() async throws -> [DueReviewItem] {
        guard let token = SessionManager.token else {
            throw APIError.server("You must be signed in to view review items.")
        }
        let response: DueReviewResponse = try await get(path: "quiz/review/due", token: token)
        return response.items
    }

    /// Pushes this device's on-device BKT state (see BKTStore) for the given topics up to
    /// the server so it's backed up/synced across devices — the server does no BKT math of
    /// its own, it just persists whatever p_know the client computed.
    @discardableResult
    func putMastery(_ items: [MasteryUpdateItem]) async throws -> UpdateMasteryResponse {
        guard let token = SessionManager.token else {
            throw APIError.server("You must be signed in to sync mastery.")
        }
        return try await send(
            path: "quiz/mastery",
            body: UpdateMasteryRequest(items: items),
            expectedStatus: 200,
            method: "PUT",
            token: token
        )
    }
}
