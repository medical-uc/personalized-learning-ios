//
//  QuizSetupViewModel.swift
//  personalized-medical-learning-ios
//

import Foundation
import Combine

@MainActor
final class QuizSetupViewModel: ObservableObject {
    @Published private(set) var topics: [QuizTopic] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    @Published private(set) var dueCount: Int?
    @Published private(set) var isLoadingDueCount = false
    @Published var dueCountErrorMessage: String?

    private let client: any APIClientProtocol

    init(client: any APIClientProtocol = APIClient.shared) {
        self.client = client
    }

    func loadTopics() async {
        guard topics.isEmpty else { return }
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            let paths = try await client.listTopics()
            topics = paths.map(QuizTopic.fromServerPath)
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
        }
    }

    func loadDueCount() async {
        dueCountErrorMessage = nil
        isLoadingDueCount = true
        defer { isLoadingDueCount = false }

        do {
            dueCount = try await client.getDueForReview().count
        } catch {
            dueCountErrorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
        }
    }
}
