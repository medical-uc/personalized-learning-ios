//
//  MasteryViewModel.swift
//  personalized-medical-learning-ios
//

import Foundation
import Combine

/// Mastery is computed entirely on-device now (see BKTStore) — there is no backend
/// /quiz/mastery round-trip. loadMastery() stays async so MasteryView's `.task { await
/// viewModel.loadMastery() }` call site didn't need to change, but it's just a local
/// UserDefaults read, always instant, and cannot fail.
@MainActor
final class MasteryViewModel: ObservableObject {
    @Published private(set) var entries: [MasteryEntry] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    func loadMastery() async {
        isLoading = true
        entries = BKTStore.allEntries()
        isLoading = false
    }
}
