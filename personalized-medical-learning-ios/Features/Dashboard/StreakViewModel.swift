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
    /// Every day (start-of-day, local calendar) the student had activity, from the
    /// backend's activity_dates — full history, not just the 7-day week_activity window.
    /// Backs the streak calendar's month grid.
    @Published private(set) var activityDates: Set<Date> = []
    @Published private(set) var isLoading = false

    /// Set when the fetched streak is 0 and the server's previous_streak > 0.
    /// DashboardView turns this into a modal; nil once dismissed.
    @Published var brokenStreakLength: Int?

    @Published private(set) var isRestoring = false
    @Published var restoreErrorMessage: String?

    private let client: any APIClientProtocol

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    init(client: any APIClientProtocol = APIClient.shared) {
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
            let calendar = Calendar.current
            activityDates = Set(response.activityDates.compactMap { raw in
                Self.dateFormatter.date(from: raw).map { calendar.startOfDay(for: $0) }
            })
        } catch {
            currentStreak = 0
            weekActivity = [Bool](repeating: false, count: 7)
            activityDates = []
        }
    }

    /// Spends energy to bridge a just-broken, exactly-one-day gap. On success, reloads
    /// the streak so currentStreak/brokenStreakLength reflect the restored state.
    func restoreStreak() async {
        isRestoring = true
        restoreErrorMessage = nil
        defer { isRestoring = false }

        do {
            _ = try await client.restoreStreak()
            await loadStreak()
            brokenStreakLength = nil
        } catch {
            restoreErrorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
        }
    }
}
