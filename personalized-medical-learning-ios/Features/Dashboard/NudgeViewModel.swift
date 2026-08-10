//
//  NudgeViewModel.swift
//  personalized-medical-learning-ios
//

import Foundation
import Combine

@MainActor
final class NudgeViewModel: ObservableObject {
    @Published private(set) var quizDueCount = 0
    @Published private(set) var flashcardDueCount = 0
    @Published private(set) var totalDueCount = 0
    @Published private(set) var soonestDue: NudgePreviewItem?
    @Published private(set) var isLoading = false

    private let client: any APIClientProtocol

    init(client: any APIClientProtocol = APIClient.shared) {
        self.client = client
    }

    func loadNudge() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let response = try await client.getNudge()
            quizDueCount = response.quizDueCount
            flashcardDueCount = response.flashcardDueCount
            totalDueCount = response.totalDueCount
            soonestDue = response.soonestDue
        } catch {
            quizDueCount = 0
            flashcardDueCount = 0
            totalDueCount = 0
            soonestDue = nil
        }
    }
}
