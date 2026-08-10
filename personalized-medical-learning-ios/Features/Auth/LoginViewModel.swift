//
//  LoginViewModel.swift
//  personalized-medical-learning-ios
//

import Foundation
import Combine

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var isSubmitting = false
    @Published var errorMessage: String?
    @Published var didLogIn = false

    private let client: any APIClientProtocol

    init(client: any APIClientProtocol = APIClient.shared) {
        self.client = client
    }

    func logIn(studentNumber: String) async {
        errorMessage = nil
        isSubmitting = true
        defer { isSubmitting = false }

        do {
            let response = try await client.loginStudent(studentNumber: studentNumber)
            SessionManager.start(studentId: response.studentId, token: response.token, expiresAt: response.expiresAt)
            didLogIn = true
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
        }
    }
}
