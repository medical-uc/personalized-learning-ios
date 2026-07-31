//
//  HistoryViewModel.swift
//  personalized-medical-learning-ios
//

import Foundation
import Combine

@MainActor
final class HistoryViewModel: ObservableObject {
    @Published private(set) var sections: [HistorySection] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

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
}
