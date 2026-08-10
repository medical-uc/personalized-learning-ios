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
    let token: String
    let expiresAt: Date

    enum CodingKeys: String, CodingKey {
        case studentId = "student_id"
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

struct SessionCheckResponse: Decodable {
    let authenticated: Bool
    let studentId: String

    enum CodingKeys: String, CodingKey {
        case authenticated
        case studentId = "student_id"
    }
}

struct StudentProfileResponse: Decodable {
    let studentId: String
    let fullName: String
    let studentNumber: String
    let academicYear: Int
    let enrolledAt: Date

    enum CodingKeys: String, CodingKey {
        case studentId = "student_id"
        case fullName = "full_name"
        case studentNumber = "student_number"
        case academicYear = "academic_year"
        case enrolledAt = "enrolled_at"
    }
}

struct StreakResponse: Decodable {
    let currentStreak: Int
    let previousStreak: Int
    let weekActivity: [Bool]

    enum CodingKeys: String, CodingKey {
        case currentStreak = "current_streak"
        case previousStreak = "previous_streak"
        case weekActivity = "week_activity"
    }
}

struct EnergyResponse: Decodable {
    let energy: Int
}

struct RestoreStreakResponse: Decodable {
    let restoredDate: String
    let energyBalance: Int

    enum CodingKeys: String, CodingKey {
        case restoredDate = "restored_date"
        case energyBalance = "energy_balance"
    }
}

enum NudgeSource: String, Decodable {
    case quiz, flashcard
}

struct NudgePreviewItem: Decodable {
    let source: NudgeSource
    let questionUid: String
    let nextReviewAt: Date

    enum CodingKeys: String, CodingKey {
        case source
        case questionUid = "question_uid"
        case nextReviewAt = "next_review_at"
    }
}

struct NudgeResponse: Decodable {
    let quizDueCount: Int
    let flashcardDueCount: Int
    let totalDueCount: Int
    let soonestDue: NudgePreviewItem?

    enum CodingKeys: String, CodingKey {
        case quizDueCount = "quiz_due_count"
        case flashcardDueCount = "flashcard_due_count"
        case totalDueCount = "total_due_count"
        case soonestDue = "soonest_due"
    }
}

struct APIValidationError: Decodable {
    struct Detail: Decodable {
        let msg: String
    }
    let detail: [Detail]
}

/// FastAPI's plain HTTPException(detail="...") shape — used by 409s like streak
/// restore's eligibility failures, distinct from the 422 validation-error array shape.
struct PlainDetailError: Decodable {
    let detail: String
}

struct TopicListResponse: Decodable {
    let topics: [String]
}

struct SubjectTopicOut: Decodable {
    let path: String
    let name: String
    let questionCount: Int
    let flashcardCount: Int

    enum CodingKeys: String, CodingKey {
        case path, name
        case questionCount = "question_count"
        case flashcardCount = "flashcard_count"
    }
}

struct SubjectOut: Decodable {
    let name: String
    let questionCount: Int
    let flashcardCount: Int
    let topics: [SubjectTopicOut]

    enum CodingKeys: String, CodingKey {
        case name, topics
        case questionCount = "question_count"
        case flashcardCount = "flashcard_count"
    }
}

struct SubjectListResponse: Decodable {
    let subjects: [SubjectOut]
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
    let explanation: String

    enum CodingKeys: String, CodingKey {
        case correct
        case correctIndex = "correct_index"
        case explanation
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
    let energyAwarded: Int
    let energyBalance: Int

    enum CodingKeys: String, CodingKey {
        case sessionId = "session_id"
        case questionCount = "question_count"
        case correctCount = "correct_count"
        case durationSeconds = "duration_seconds"
        case energyAwarded = "energy_awarded"
        case energyBalance = "energy_balance"
    }
}

struct CancelSessionResponse: Decodable {
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

struct DueReviewItem: Decodable {
    let questionUid: String
    let streak: Int
    let intervalDays: Int
    let lastReviewedAt: Date
    let nextReviewAt: Date

    enum CodingKeys: String, CodingKey {
        case questionUid = "question_uid"
        case streak
        case intervalDays = "interval_days"
        case lastReviewedAt = "last_reviewed_at"
        case nextReviewAt = "next_review_at"
    }
}

struct DueReviewResponse: Decodable {
    let items: [DueReviewItem]
}

struct FlashcardOut: Decodable {
    let uid: String
    let front: String
    let topicTag: [String]
    let difficulty: Int

    enum CodingKeys: String, CodingKey {
        case uid, front
        case topicTag = "topic_tag"
        case difficulty
    }
}

struct FlashcardRevealResponse: Decodable {
    let uid: String
    let back: String
    let explanation: String
}

enum FlashcardRating: String, Codable {
    case again, hard, good, easy
}

struct LogFlashcardReviewRequest: Encodable {
    let rating: FlashcardRating
}

struct LogFlashcardReviewResponse: Decodable {
    let eventId: String
    let streak: Int
    let intervalDays: Int
    let nextReviewAt: Date
    let energyAwarded: Int
    let energyBalance: Int

    enum CodingKeys: String, CodingKey {
        case eventId = "event_id"
        case streak
        case intervalDays = "interval_days"
        case nextReviewAt = "next_review_at"
        case energyAwarded = "energy_awarded"
        case energyBalance = "energy_balance"
    }
}

struct DueFlashcardItem: Decodable {
    let questionUid: String
    let streak: Int
    let intervalDays: Int
    let lastReviewedAt: Date
    let nextReviewAt: Date

    enum CodingKeys: String, CodingKey {
        case questionUid = "question_uid"
        case streak
        case intervalDays = "interval_days"
        case lastReviewedAt = "last_reviewed_at"
        case nextReviewAt = "next_review_at"
    }
}

struct DueFlashcardResponse: Decodable {
    let items: [DueFlashcardItem]
}

struct FlashcardHistoryItem: Decodable {
    let eventId: String
    let questionUid: String
    let front: String
    let topicPath: String
    let rating: FlashcardRating
    let ts: Date

    enum CodingKeys: String, CodingKey {
        case eventId = "event_id"
        case questionUid = "question_uid"
        case front
        case topicPath = "topic_path"
        case rating
        case ts
    }
}

struct FlashcardHistoryResponse: Decodable {
    let items: [FlashcardHistoryItem]
}

struct StartFlashcardSessionRequest: Encodable {
    let size: Int?
}

struct StartFlashcardSessionResponse: Decodable {
    let sessionId: String
    let cardUids: [String]

    enum CodingKeys: String, CodingKey {
        case sessionId = "session_id"
        case cardUids = "card_uids"
    }
}

struct EndFlashcardSessionResponse: Decodable {
    let sessionId: String
    let cardCount: Int
    let reviewedCount: Int
    let durationSeconds: Int

    enum CodingKeys: String, CodingKey {
        case sessionId = "session_id"
        case cardCount = "card_count"
        case reviewedCount = "reviewed_count"
        case durationSeconds = "duration_seconds"
    }
}

struct FlashcardSessionHistoryItem: Decodable {
    let sessionId: String
    let topicPath: String?
    let status: String
    let cardCount: Int
    let reviewedCount: Int
    let durationSeconds: Int
    let startedAt: Date
    let endedAt: Date

    enum CodingKeys: String, CodingKey {
        case sessionId = "session_id"
        case topicPath = "topic_path"
        case status
        case cardCount = "card_count"
        case reviewedCount = "reviewed_count"
        case durationSeconds = "duration_seconds"
        case startedAt = "started_at"
        case endedAt = "ended_at"
    }
}

struct FlashcardSessionHistoryResponse: Decodable {
    let items: [FlashcardSessionHistoryItem]
}

enum APIError: LocalizedError {
    case server(String)
    case decoding
    case network(Error)
    case unauthorized

    var errorDescription: String? {
        switch self {
        case .server(let message): return message
        case .decoding: return "Received an unexpected response from the server."
        case .network(let error): return error.localizedDescription
        case .unauthorized: return "Your session has expired. Please sign in again."
        }
    }
}

extension Notification.Name {
    static let sessionExpired = Notification.Name("sessionExpired")
    static let energyAwarded = Notification.Name("energyAwarded")
}

/// userInfo payload posted alongside .energyAwarded — amount is positive for quiz/
/// flashcard awards, negative for spends (e.g. streak restore). Never posted for a
/// zero delta (cancelled sessions have no energy fields, so never trigger this).
enum EnergyAwardedKey {
    static let amount = "amount"
    static let balance = "balance"
}

/// Costs for spending energy — mirrors backend src/student_kg/streak.py constants.
enum EnergyCost {
    static let restoreStreak = 10
}

enum APIConfig {
    /// Bonjour hostname instead of a raw LAN IP — survives DHCP reassigning the
    /// backend Mac's address (e.g. after wifi reconnect), no source edit needed.
    static let baseURL = URL(string: "http://Mikel-MacBook-Pro.local:8000")!
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
        let noTimeZone = DateFormatter()
        noTimeZone.calendar = Calendar(identifier: .iso8601)
        noTimeZone.timeZone = TimeZone(identifier: "UTC")
        noTimeZone.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let raw = try container.decode(String.self)
            if let date = fractional.date(from: raw) ?? whole.date(from: raw) ?? noTimeZone.date(from: raw) {
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

    func listSubjects() async throws -> [SubjectOut] {
        guard let token = SessionManager.token else {
            throw APIError.server("You must be signed in to view subjects.")
        }
        let response: SubjectListResponse = try await get(path: "quiz/subjects", token: token)
        return response.subjects
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
        let response: EndSessionResponse = try await post(path: "quiz/sessions/\(sessionId)/end", expectedStatus: 200, token: token)
        postEnergyAwarded(response.energyAwarded, balance: response.energyBalance)
        return response
    }

    func cancelSession(sessionId: String) async throws -> CancelSessionResponse {
        guard let token = SessionManager.token else {
            throw APIError.server("You must be signed in to cancel a quiz.")
        }
        return try await post(path: "quiz/sessions/\(sessionId)/cancel", expectedStatus: 200, token: token)
    }

    func getHistory() async throws -> [HistoryItem] {
        guard let token = SessionManager.token else {
            throw APIError.server("You must be signed in to view history.")
        }
        let response: HistoryListResponse = try await get(path: "quiz/history", token: token)
        return response.items
    }

    func getDueForReview() async throws -> [DueReviewItem] {
        guard let token = SessionManager.token else {
            throw APIError.server("You must be signed in to view review items.")
        }
        let response: DueReviewResponse = try await get(path: "quiz/review/due", token: token)
        return response.items
    }

    func getAllCards() async throws -> [FlashcardOut] {
        try await get(path: "flashcards/cards")
    }

    func startFlashcardSession(topicPath: String? = nil, size: Int? = nil) async throws -> StartFlashcardSessionResponse {
        guard let token = SessionManager.token else {
            throw APIError.server("You must be signed in to start a flashcard session.")
        }
        let path = topicPath.map { "flashcards/topics/\($0)/sessions" } ?? "flashcards/sessions"
        return try await send(
            path: path,
            body: StartFlashcardSessionRequest(size: size),
            expectedStatus: 200,
            token: token
        )
    }

    func endFlashcardSession(sessionId: String) async throws -> EndFlashcardSessionResponse {
        guard let token = SessionManager.token else {
            throw APIError.server("You must be signed in to end a flashcard session.")
        }
        return try await post(path: "flashcards/sessions/\(sessionId)/end", expectedStatus: 200, token: token)
    }

    func cancelFlashcardSession(sessionId: String) async throws -> EndFlashcardSessionResponse {
        guard let token = SessionManager.token else {
            throw APIError.server("You must be signed in to cancel a flashcard session.")
        }
        return try await post(path: "flashcards/sessions/\(sessionId)/cancel", expectedStatus: 200, token: token)
    }

    func getFlashcardSessionHistory() async throws -> [FlashcardSessionHistoryItem] {
        guard let token = SessionManager.token else {
            throw APIError.server("You must be signed in to view flashcard session history.")
        }
        let response: FlashcardSessionHistoryResponse = try await get(path: "flashcards/sessions/history", token: token)
        return response.items
    }

    func revealCard(uid: String) async throws -> FlashcardRevealResponse {
        try await post(path: "flashcards/cards/\(uid)/reveal", expectedStatus: 200)
    }

    func logReview(uid: String, rating: FlashcardRating) async throws -> LogFlashcardReviewResponse {
        guard let token = SessionManager.token else {
            throw APIError.server("You must be signed in to log a review.")
        }
        let response: LogFlashcardReviewResponse = try await send(
            path: "flashcards/cards/\(uid)/log",
            body: LogFlashcardReviewRequest(rating: rating),
            expectedStatus: 200,
            token: token
        )
        postEnergyAwarded(response.energyAwarded, balance: response.energyBalance)
        return response
    }

    func getDueFlashcards() async throws -> [DueFlashcardItem] {
        guard let token = SessionManager.token else {
            throw APIError.server("You must be signed in to view review items.")
        }
        let response: DueFlashcardResponse = try await get(path: "flashcards/review/due", token: token)
        return response.items
    }

    func getFlashcardHistory() async throws -> [FlashcardHistoryItem] {
        guard let token = SessionManager.token else {
            throw APIError.server("You must be signed in to view flashcard history.")
        }
        let response: FlashcardHistoryResponse = try await get(path: "flashcards/history", token: token)
        return response.items
    }

    func getStudentProfile() async throws -> StudentProfileResponse {
        try await get(path: "students/me/profile")
    }

    func getStreak() async throws -> StreakResponse {
        guard let token = SessionManager.token else {
            throw APIError.server("You must be signed in to view your streak.")
        }
        return try await get(path: "students/me/streak", token: token)
    }

    /// Spends RESTORE_STREAK_COST (10) energy to bridge a just-broken, exactly-one-day
    /// gap. Throws .server with the backend's message on 409 (gap too large, or balance
    /// too low) — callers should call getStreak first and only offer this when
    /// current_streak == 0 && previous_streak > 0.
    func restoreStreak() async throws -> RestoreStreakResponse {
        guard let token = SessionManager.token else {
            throw APIError.server("You must be signed in to restore your streak.")
        }
        let response: RestoreStreakResponse = try await post(path: "students/me/streak/restore", expectedStatus: 200, token: token)
        postEnergyAwarded(-EnergyCost.restoreStreak, balance: response.energyBalance)
        return response
    }

    /// Re-syncs the displayed balance (app open, another tab awarded energy, etc.) —
    /// awards themselves arrive inline from endSession/logReview via .energyAwarded.
    func getEnergy() async throws -> EnergyResponse {
        guard let token = SessionManager.token else {
            throw APIError.server("You must be signed in to view your energy.")
        }
        return try await get(path: "students/me/energy", token: token)
    }

    private func postEnergyAwarded(_ amount: Int, balance: Int) {
        guard amount != 0 else { return }
        NotificationCenter.default.post(
            name: .energyAwarded,
            object: nil,
            userInfo: [EnergyAwardedKey.amount: amount, EnergyAwardedKey.balance: balance]
        )
    }

    func getNudge() async throws -> NudgeResponse {
        guard let token = SessionManager.token else {
            throw APIError.server("You must be signed in to view your review nudge.")
        }
        return try await get(path: "students/me/nudge", token: token)
    }

    /// Validates the stored token against the server. Returns nil for a missing/invalid/expired token
    /// rather than throwing, since 401 is an expected outcome here, not an error condition.
    func checkSession() async -> SessionCheckResponse? {
        guard let token = SessionManager.token else { return nil }

        let url = APIConfig.baseURL.appendingPathComponent("students/me")
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        guard let (data, response) = try? await session.data(for: request),
              let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            return nil
        }

        return try? decoder.decode(SessionCheckResponse.self, from: data)
    }

    private func get<Response: Decodable>(path: String, token: String? = SessionManager.token) async throws -> Response {
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

    private func post<Response: Decodable>(path: String, expectedStatus: Int, token: String? = SessionManager.token) async throws -> Response {
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
        token: String? = SessionManager.token
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
        if statusCode == 401 {
            SessionManager.end()
            NotificationCenter.default.post(name: .sessionExpired, object: nil)
            return .unauthorized
        }
        if let validationError = try? JSONDecoder().decode(APIValidationError.self, from: data),
           let firstMessage = validationError.detail.first?.msg {
            return .server(firstMessage)
        }
        if let plainDetail = try? JSONDecoder().decode(PlainDetailError.self, from: data) {
            return .server(plainDetail.detail)
        }
        return .server("\(action) failed (status \(statusCode)).")
    }
}
