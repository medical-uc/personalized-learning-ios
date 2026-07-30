//
//  APIClient.swift
//  personalized-medical-learning-ios
//

import Foundation

struct StudentRegisterRequest: Encodable {
    let name: String
    let academicYear: Int

    enum CodingKeys: String, CodingKey {
        case name
        case academicYear = "academic_year"
    }
}

struct StudentRegisterResponse: Decodable {
    let studentId: String
    let eventId: String

    enum CodingKeys: String, CodingKey {
        case studentId = "student_id"
        case eventId = "event_id"
    }
}

struct APIValidationError: Decodable {
    struct Detail: Decodable {
        let msg: String
    }
    let detail: [Detail]
}

enum APIError: LocalizedError {
    case server(String)
    case decoding
    case network(Error)

    var errorDescription: String? {
        switch self {
        case .server(let message): return message
        case .decoding: return "Received an unexpected response from the server."
        case .network(let error): return error.localizedDescription
        }
    }
}

enum APIConfig {
    static let baseURL = URL(string: "http://10.67.52.231:8000")!
}

final class APIClient {
    static let shared = APIClient()

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func registerStudent(name: String, academicYear: Int) async throws -> StudentRegisterResponse {
        let url = APIConfig.baseURL.appendingPathComponent("students/register")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(
            StudentRegisterRequest(name: name, academicYear: academicYear)
        )

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw APIError.network(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.decoding
        }

        guard httpResponse.statusCode == 201 else {
            if let validationError = try? JSONDecoder().decode(APIValidationError.self, from: data),
               let firstMessage = validationError.detail.first?.msg {
                throw APIError.server(firstMessage)
            }
            throw APIError.server("Registration failed (status \(httpResponse.statusCode)).")
        }

        do {
            return try JSONDecoder().decode(StudentRegisterResponse.self, from: data)
        } catch {
            throw APIError.decoding
        }
    }
}
