//
//  FlashcardSetupViewModel.swift
//  personalized-medical-learning-ios
//

import Foundation
import Combine

@MainActor
final class FlashcardSetupViewModel: ObservableObject {
    @Published private(set) var topics: [QuizTopic] = []
    @Published private(set) var isLoadingTopics = false
    @Published var topicsErrorMessage: String?

    @Published private(set) var preview: FlashcardSessionPreview?
    @Published private(set) var isLoadingPreview = false
    @Published var previewErrorMessage: String?

    private let client: any APIClientProtocol

    init(client: any APIClientProtocol = APIClient.shared) {
        self.client = client
    }

    func loadTopics() async {
        guard topics.isEmpty else { return }
        topicsErrorMessage = nil
        isLoadingTopics = true
        defer { isLoadingTopics = false }

        do {
            let paths = try await client.listTopics()
            topics = paths.map(QuizTopic.fromServerPath)
        } catch {
            topicsErrorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
        }
    }

    /// Loads preview stats for the given topic path, or across all cards when nil —
    /// mirrors FlashcardViewModel's due-cards-first ordering logic to keep the
    /// counts the learner sees here consistent with what the session actually plays.
    func loadPreview(topicPath: String?) async {
        previewErrorMessage = nil
        isLoadingPreview = true
        defer { isLoadingPreview = false }

        do {
            async let dueTask = client.getDueFlashcards()
            async let allTask = client.getAllCards()
            let (due, all) = try await (dueTask, allTask)

            let scopedCards = topicPath.map { path in all.filter { $0.topicPath == path } } ?? all
            let scopedUids = Set(scopedCards.map(\.uid))
            let scopedDue = due.filter { scopedUids.contains($0.questionUid) }

            let weakest = topicPath.map { path in BKTStore.allEntries().first { $0.topicPath == path } }
                ?? BKTStore.allEntries().first
            preview = FlashcardSessionPreview(dueCount: scopedDue.count, totalCount: scopedCards.count, weakestTopic: weakest)
        } catch {
            previewErrorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
        }
    }
}
