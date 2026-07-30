//
//  RegisterViewModel.swift
//  personalized-medical-learning-ios
//

import Foundation
import Combine

@MainActor
final class RegisterViewModel: ObservableObject {
    @Published var isSubmitting = false
    @Published var errorMessage: String?
    @Published var studentId: String?

    private let client: APIClient

    init(client: APIClient = APIClient()) {
        self.client = client
    }

    func register(name: String, academicYear: Int) async {
        errorMessage = nil
        isSubmitting = true
        defer { isSubmitting = false }

        do {
            let response = try await client.registerStudent(name: name, academicYear: academicYear)
            studentId = response.studentId
            UserDefaults.standard.set(response.studentId, forKey: "studentId")
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
        }
    }
}
