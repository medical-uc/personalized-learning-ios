//
//  DashboardAPI.swift
//  personalized-medical-learning-ios
//

import Foundation

extension APIClient {
    func getStudentProfile() async throws -> StudentProfileResponse {
        try await get(path: "students/me/profile")
    }

    func getStreak() async throws -> StreakResponse {
        guard let token = SessionManager.token else {
            throw APIError.server("You must be signed in to view your streak.")
        }
        return try await get(path: "students/me/streak", token: token)
    }

    /// Spends RESTORE_STREAK_COST (10) energy to bridge a just-broken, exactly-one-day
    /// gap. Throws .server with the backend's message on 409 (gap too large, or balance
    /// too low) — callers should call getStreak first and only offer this when
    /// current_streak == 0 && previous_streak > 0.
    func restoreStreak() async throws -> RestoreStreakResponse {
        guard let token = SessionManager.token else {
            throw APIError.server("You must be signed in to restore your streak.")
        }
        let response: RestoreStreakResponse = try await post(path: "students/me/streak/restore", expectedStatus: 200, token: token)
        postEnergyAwarded(-EnergyCost.restoreStreak, balance: response.energyBalance)
        return response
    }

    /// Re-syncs the displayed balance (app open, another tab awarded energy, etc.) —
    /// awards themselves arrive inline from endSession/logReview via .energyAwarded.
    func getEnergy() async throws -> EnergyResponse {
        guard let token = SessionManager.token else {
            throw APIError.server("You must be signed in to view your energy.")
        }
        return try await get(path: "students/me/energy", token: token)
    }

    func getNudge() async throws -> NudgeResponse {
        guard let token = SessionManager.token else {
            throw APIError.server("You must be signed in to view your review nudge.")
        }
        return try await get(path: "students/me/nudge", token: token)
    }
}
