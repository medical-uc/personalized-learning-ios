//
//  HistoryViewModel.swift
//  personalized-medical-learning-ios
//

import Foundation
import Combine

@MainActor
final class HistoryViewModel: ObservableObject {
    @Published private(set) var sections: [HistorySection<HistoryEntry>] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    @Published private(set) var flashcardSections: [HistorySection<FlashcardHistoryEntry>] = []
    @Published private(set) var isLoadingFlashcards = false
    @Published var flashcardErrorMessage: String?

    private let client: APIClient

    init(client: APIClient = .shared) {
        self.client = client
    }

    func loadHistory() async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            let items = try await client.getHistory()
            sections = HistoryGrouping.sections(from: items)
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
        }
    }

    func loadFlashcardHistory() async {
        flashcardErrorMessage = nil
        isLoadingFlashcards = true
        defer { isLoadingFlashcards = false }

        do {
            let items = try await client.getFlashcardHistory()
            let mostRecent = items.sorted { $0.ts > $1.ts }.prefix(100)
            flashcardSections = HistoryGrouping.sections(from: Array(mostRecent))
        } catch {
            flashcardErrorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
        }
    }
}
