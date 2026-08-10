//
//  StreakViewModel.swift
//  personalized-medical-learning-ios
//

import Foundation
import Combine

@MainActor
final class StreakViewModel: ObservableObject {
    @Published private(set) var currentStreak = 0
    @Published private(set) var weekActivity = [Bool](repeating: false, count: 7)
    @Published private(set) var isLoading = false

    /// Set when the fetched streak is 0 and the server's previous_streak > 0.
    /// DashboardView turns this into a modal; nil once dismissed.
    @Published var brokenStreakLength: Int?

    private let client: APIClient

    init(client: APIClient = .shared) {
        self.client = client
    }

    func loadStreak() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let response = try await client.getStreak()
            if response.currentStreak == 0 && response.previousStreak > 0 {
                brokenStreakLength = response.previousStreak
            }
            currentStreak = response.currentStreak
            weekActivity = response.weekActivity
        } catch {
            currentStreak = 0
            weekActivity = [Bool](repeating: false, count: 7)
        }
    }
}
