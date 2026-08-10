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

    /// Set when a fetch shows the streak reset to 0 after a previous session saw it > 0.
    /// DashboardView turns this into a modal; nil once dismissed.
    @Published var brokenStreakLength: Int?

    private let client: APIClient
    private static let lastSeenStreakKey = "streak.lastSeenCount"

    /// Last streak count observed on a prior launch, so a reset to 0 can be told
    /// apart from "never had a streak" — read/write UserDefaults directly like
    /// BKTStore.pKnow, no separate persistence layer for one Int.
    private var lastSeenStreak: Int {
        get { UserDefaults.standard.integer(forKey: Self.lastSeenStreakKey) }
        set { UserDefaults.standard.set(newValue, forKey: Self.lastSeenStreakKey) }
    }

    init(client: APIClient = .shared) {
        self.client = client
    }

    func loadStreak() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let response = try await client.getStreak()
            applyFetchedStreak(response.currentStreak)
            weekActivity = response.weekActivity
        } catch {
            currentStreak = 0
            weekActivity = [Bool](repeating: false, count: 7)
        }
    }

    private func applyFetchedStreak(_ fetched: Int) {
        if fetched == 0 && lastSeenStreak > 0 {
            brokenStreakLength = lastSeenStreak
        }
        currentStreak = fetched
        lastSeenStreak = fetched
    }
}
