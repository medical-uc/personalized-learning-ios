//
//  HistoryAPI.swift
//  personalized-medical-learning-ios
//

import Foundation

extension APIClient {
    func getHistory() async throws -> [HistoryItem] {
        guard let token = SessionManager.token else {
            throw APIError.server("You must be signed in to view history.")
        }
        let response: HistoryListResponse = try await get(path: "quiz/history", token: token)
        return response.items
    }
}
