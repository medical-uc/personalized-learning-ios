//
//  AuthAPI.swift
//  personalized-medical-learning-ios
//

import Foundation

extension APIClient {
    func registerStudent(fullName: String, studentNumber: String, academicYear: Int) async throws -> StudentRegisterResponse {
        try await send(
            path: "students/register",
            body: StudentRegisterRequest(fullName: fullName, studentNumber: studentNumber, academicYear: academicYear),
            expectedStatus: 201
        )
    }

    func loginStudent(studentNumber: String) async throws -> SessionResponse {
        try await send(
            path: "students/login",
            body: StudentLoginRequest(studentNumber: studentNumber),
            expectedStatus: 200
        )
    }

    func logoutStudent(token: String) async throws {
        let url = APIConfig.baseURL.appendingPathComponent("students/logout")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await rawData(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.decoding
        }

        guard httpResponse.statusCode == 204 else {
            throw try makeServerError(data: data, statusCode: httpResponse.statusCode, action: "Logout")
        }
    }

    /// Validates the stored token against the server. Returns nil for a missing/invalid/expired token
    /// rather than throwing, since 401 is an expected outcome here, not an error condition.
    func checkSession() async -> SessionCheckResponse? {
        guard let token = SessionManager.token else { return nil }

        let url = APIConfig.baseURL.appendingPathComponent("students/me")
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        guard let (data, response) = try? await rawData(for: request),
              let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            return nil
        }

        return decodeIfPresent(SessionCheckResponse.self, from: data)
    }
}
