//
//  ReviewDueViewModel.swift
//  personalized-medical-learning-ios
//

import Foundation
import Combine

@MainActor
final class ReviewDueViewModel: ObservableObject {
    @Published private(set) var dueCount = 0
    @Published private(set) var isLoading = false

    private let client: APIClient

    init(client: APIClient = .shared) {
        self.client = client
    }

    func loadDueCount() async {
        isLoading = true
        defer { isLoading = false }

        do {
            dueCount = try await client.getDueForReview().count
        } catch {
            dueCount = 0
        }
    }
}
