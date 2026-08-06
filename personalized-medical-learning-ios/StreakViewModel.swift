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

    private let client: APIClient

    init(client: APIClient = .shared) {
        self.client = client
    }

    func loadStreak() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let response = try await client.getStreak()
            currentStreak = response.currentStreak
            weekActivity = response.weekActivity
        } catch {
            currentStreak = 0
            weekActivity = [Bool](repeating: false, count: 7)
        }
    }
}
