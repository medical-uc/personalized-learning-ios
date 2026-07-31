//
//  APIClient.swift
//  personalized-medical-learning-ios
//

import Foundation

struct StudentRegisterRequest: Encodable {
    let fullName: String
    let studentNumber: String
    let academicYear: Int

    enum CodingKeys: String, CodingKey {
        case fullName = "full_name"
        case studentNumber = "student_number"
        case academicYear = "academic_year"
    }
}

struct StudentRegisterResponse: Decodable {
    let studentId: String
    let eventId: String
    let token: String
    let expiresAt: Date

    enum CodingKeys: String, CodingKey {
        case studentId = "student_id"
        case eventId = "event_id"
        case token
        case expiresAt = "expires_at"
    }
}

struct StudentLoginRequest: Encodable {
    let studentNumber: String

    enum CodingKeys: String, CodingKey {
        case studentNumber = "student_number"
    }
}

struct SessionResponse: Decodable {
    let studentId: String
    let token: String
    let expiresAt: Date

    enum CodingKeys: String, CodingKey {
        case studentId = "student_id"
        case token
        case expiresAt = "expires_at"
    }
}

struct APIValidationError: Decodable {
    struct Detail: Decodable {
        let msg: String
    }
    let detail: [Detail]
}

struct TopicListResponse: Decodable {
    let topics: [String]
}

struct OptionOut: Decodable {
    let index: Int
    let text: String
}

struct QuestionOut: Decodable {
    let uid: String
    let stem: String
    let options: [OptionOut]
    let topicTag: [String]
    let difficulty: Int

    enum CodingKeys: String, CodingKey {
        case uid, stem, options
        case topicTag = "topic_tag"
        case difficulty
    }
}

struct CheckAnswerRequest: Encodable {
    let selectedIndex: Int

    enum CodingKeys: String, CodingKey {
        case selectedIndex = "selected_index"
    }
}

struct CheckAnswerResponse: Decodable {
    let correct: Bool
    let correctIndex: Int

    enum CodingKeys: String, CodingKey {
        case correct
        case correctIndex = "correct_index"
    }
}

struct LogAttemptRequest: Encodable {
    let sessionId: String
    let selectedIndex: Int
    let confidence: String
    let timeTakenSeconds: Double

    enum CodingKeys: String, CodingKey {
        case sessionId = "session_id"
        case selectedIndex = "selected_index"
        case confidence
        case timeTakenSeconds = "time_taken_seconds"
    }
}

struct LogAttemptResponse: Decodable {
    let eventId: String
    let correct: Bool

    enum CodingKeys: String, CodingKey {
        case eventId = "event_id"
        case correct
    }
}

struct StartSessionResponse: Decodable {
    let sessionId: String

    enum CodingKeys: String, CodingKey {
        case sessionId = "session_id"
    }
}

struct EndSessionResponse: Decodable {
    let sessionId: String
    let questionCount: Int
    let correctCount: Int
    let durationSeconds: Int

    enum CodingKeys: String, CodingKey {
        case sessionId = "session_id"
        case questionCount = "question_count"
        case correctCount = "correct_count"
        case durationSeconds = "duration_seconds"
    }
}

struct HistoryItem: Decodable {
    let sessionId: String
    let topicPath: String
    let questionCount: Int
    let correctCount: Int
    let scorePercent: Int
    let durationSeconds: Int
    let startedAt: Date
    let endedAt: Date

    enum CodingKeys: String, CodingKey {
        case sessionId = "session_id"
        case topicPath = "topic_path"
        case questionCount = "question_count"
        case correctCount = "correct_count"
        case scorePercent = "score_percent"
        case durationSeconds = "duration_seconds"
        case startedAt = "started_at"
        case endedAt = "ended_at"
    }
}

struct HistoryListResponse: Decodable {
    let items: [HistoryItem]
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
    private let decoder: JSONDecoder

    init(session: URLSession = .shared) {
        self.session = session

        let fractional = ISO8601DateFormatter()
        fractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let whole = ISO8601DateFormatter()
        whole.formatOptions = [.withInternetDateTime]

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let raw = try container.decode(String.self)
            if let date = fractional.date(from: raw) ?? whole.date(from: raw) {
                return date
            }
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date: \(raw)")
        }
        self.decoder = decoder
    }

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

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw APIError.network(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.decoding
        }

        guard httpResponse.statusCode == 204 else {
            throw try makeServerError(data: data, statusCode: httpResponse.statusCode, action: "Logout")
        }
    }

    func listTopics() async throws -> [String] {
        let response: TopicListResponse = try await get(path: "quiz/topics")
        return response.topics
    }

    func getQuestions(topicPath: String) async throws -> [QuestionOut] {
        try await get(path: "quiz/topics/\(topicPath)/questions")
    }

    func checkAnswer(uid: String, selectedIndex: Int) async throws -> CheckAnswerResponse {
        try await send(
            path: "quiz/questions/\(uid)/check",
            body: CheckAnswerRequest(selectedIndex: selectedIndex),
            expectedStatus: 200
        )
    }

    func logAttempt(uid: String, sessionId: String, selectedIndex: Int, confidence: String, timeTakenSeconds: Double) async throws -> LogAttemptResponse {
        guard let token = SessionManager.token else {
            throw APIError.server("You must be signed in to submit an answer.")
        }
        return try await send(
            path: "quiz/questions/\(uid)/log",
            body: LogAttemptRequest(sessionId: sessionId, selectedIndex: selectedIndex, confidence: confidence, timeTakenSeconds: timeTakenSeconds),
            expectedStatus: 200,
            token: token
        )
    }

    func startSession(topicPath: String) async throws -> StartSessionResponse {
        guard let token = SessionManager.token else {
            throw APIError.server("You must be signed in to start a quiz.")
        }
        return try await post(path: "quiz/topics/\(topicPath)/sessions", expectedStatus: 200, token: token)
    }

    func endSession(sessionId: String) async throws -> EndSessionResponse {
        guard let token = SessionManager.token else {
            throw APIError.server("You must be signed in to end a quiz.")
        }
        return try await post(path: "quiz/sessions/\(sessionId)/end", expectedStatus: 200, token: token)
    }

    func getHistory() async throws -> [HistoryItem] {
        guard let token = SessionManager.token else {
            throw APIError.server("You must be signed in to view history.")
        }
        let response: HistoryListResponse = try await get(path: "quiz/history", token: token)
        return response.items
    }

    private func get<Response: Decodable>(path: String, token: String? = nil) async throws -> Response {
        let url = APIConfig.baseURL.appendingPathComponent(path)

        var request = URLRequest(url: url)
        if let token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw APIError.network(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.decoding
        }

        guard httpResponse.statusCode == 200 else {
            throw try makeServerError(data: data, statusCode: httpResponse.statusCode, action: "Request")
        }

        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw APIError.decoding
        }
    }

    private func post<Response: Decodable>(path: String, expectedStatus: Int, token: String? = nil) async throws -> Response {
        let url = APIConfig.baseURL.appendingPathComponent(path)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        if let token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw APIError.network(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.decoding
        }

        guard httpResponse.statusCode == expectedStatus else {
            throw try makeServerError(data: data, statusCode: httpResponse.statusCode, action: "Request")
        }

        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw APIError.decoding
        }
    }

    private func send<Body: Encodable, Response: Decodable>(
        path: String,
        body: Body,
        expectedStatus: Int,
        token: String? = nil
    ) async throws -> Response {
        let url = APIConfig.baseURL.appendingPathComponent(path)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw APIError.network(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.decoding
        }

        guard httpResponse.statusCode == expectedStatus else {
            throw try makeServerError(data: data, statusCode: httpResponse.statusCode, action: "Request")
        }

        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw APIError.decoding
        }
    }

    private func makeServerError(data: Data, statusCode: Int, action: String) throws -> APIError {
        if let validationError = try? JSONDecoder().decode(APIValidationError.self, from: data),
           let firstMessage = validationError.detail.first?.msg {
            return .server(firstMessage)
        }
        return .server("\(action) failed (status \(statusCode)).")
    }
}
