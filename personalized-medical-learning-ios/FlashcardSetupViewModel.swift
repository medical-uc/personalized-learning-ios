//
//  FlashcardSetupViewModel.swift
//  personalized-medical-learning-ios
//

import Foundation
import Combine

@MainActor
final class FlashcardSetupViewModel: ObservableObject {
    @Published private(set) var preview: FlashcardSessionPreview?
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    private let client: APIClient

    init(client: APIClient = .shared) {
        self.client = client
    }

    func loadPreview() async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            async let dueTask = client.getDueFlashcards()
            async let allTask = client.getAllCards()
            let (due, all) = try await (dueTask, allTask)
            let weakest = BKTStore.allEntries().first
            preview = FlashcardSessionPreview(dueCount: due.count, totalCount: all.count, weakestTopic: weakest)
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
        }
    }
}
