//
//  SubjectsViewModel.swift
//  personalized-medical-learning-ios
//

import Foundation
import Combine

@MainActor
final class SubjectsViewModel: ObservableObject {
    @Published private(set) var subjects: [StudySubject] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    private let client: any APIClientProtocol

    init(client: any APIClientProtocol = APIClient.shared) {
        self.client = client
    }

    func loadSubjects() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let response = try await client.listSubjects()
            subjects = response.map(StudySubject.init(from:))
        } catch {
            subjects = []
            errorMessage = (error as? APIError)?.errorDescription ?? "Couldn't load subjects."
        }
    }
}
