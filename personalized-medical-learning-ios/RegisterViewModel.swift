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

    func register(fullName: String, studentNumber: String, academicYear: Int) async {
        errorMessage = nil
        isSubmitting = true
        defer { isSubmitting = false }

        do {
            let response = try await client.registerStudent(fullName: fullName, studentNumber: studentNumber, academicYear: academicYear)
            self.studentId = response.studentId
            UserDefaults.standard.set(response.studentId, forKey: "studentId")
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
        }
    }
}
