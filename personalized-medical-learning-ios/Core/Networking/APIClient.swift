//
//  APIClient.swift
//  personalized-medical-learning-ios
//

import Foundation

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

    /// Raw session access for endpoints that need custom request/response handling
    /// outside the get/post/send helpers below (e.g. 204 No Content, or decoding
    /// with try? instead of throwing on failure).
    func rawData(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await executeWithRetry(request)
    }

    func decode<Response: Decodable>(_ type: Response.Type, from data: Data) throws -> Response {
        try decoder.decode(type, from: data)
    }

    func decodeIfPresent<Response: Decodable>(_ type: Response.Type, from data: Data) -> Response? {
        try? decoder.decode(type, from: data)
    }

    func get<Response: Decodable>(path: String, token: String? = SessionManager.token) async throws -> Response {
        let url = APIConfig.baseURL.appendingPathComponent(path)

        var request = URLRequest(url: url)
        if let token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await executeWithRetry(request)
        return try await handle(data: data, response: response, expectedStatus: 200)
    }

    func post<Response: Decodable>(path: String, expectedStatus: Int, token: String? = SessionManager.token) async throws -> Response {
        let url = APIConfig.baseURL.appendingPathComponent(path)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        if let token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await executeWithRetry(request)
        return try await handle(data: data, response: response, expectedStatus: expectedStatus)
    }

    func send<Body: Encodable, Response: Decodable>(
        path: String,
        body: Body,
        expectedStatus: Int,
        method: String = "POST",
        token: String? = SessionManager.token
    ) async throws -> Response {
        let url = APIConfig.baseURL.appendingPathComponent(path)

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = try JSONEncoder().encode(body)

        // POST/PUT bodies aren't safe to blindly retry server-side-effect-wise, but
        // every call site here is either idempotent (session start/end, mastery put)
        // or safe to retry only on connection-level failure (never got a response) —
        // executeWithRetry only retries those, never on a request that got a reply.
        let (data, response) = try await executeWithRetry(request)
        return try await handle(data: data, response: response, expectedStatus: expectedStatus)
    }

    private func handle<Response: Decodable>(data: Data, response: URLResponse, expectedStatus: Int) async throws -> Response {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.decoding
        }

        guard httpResponse.statusCode == expectedStatus else {
            throw try makeServerError(data: data, statusCode: httpResponse.statusCode, headers: httpResponse)
        }

        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw APIError.decoding
        }
    }

    /// Retries up to 2 extra times, with short backoff, on transient connection-level
    /// failures only (timeout, dropped connection, host unreachable) — never after a
    /// response was actually received, so a request whose side effect already landed
    /// on the server is never re-sent.
    private func executeWithRetry(_ request: URLRequest, attempt: Int = 0) async throws -> (Data, URLResponse) {
        guard await Reachability.shared.isOnline else {
            throw APIError.offline
        }

        do {
            return try await session.data(for: request)
        } catch {
            let urlError = error as? URLError
            let isTimeout = urlError?.code == .timedOut
            let isRetryableTransport: Bool = {
                guard let code = urlError?.code else { return false }
                return [.networkConnectionLost, .cannotConnectToHost, .cannotFindHost, .dnsLookupFailed].contains(code)
            }()

            guard attempt < 2, (isTimeout || isRetryableTransport) else {
                throw isTimeout ? APIError.timeout : APIError.network(error)
            }

            let backoffNanoseconds = UInt64(pow(2.0, Double(attempt)) * 500_000_000)
            try? await Task.sleep(nanoseconds: backoffNanoseconds)
            return try await executeWithRetry(request, attempt: attempt + 1)
        }
    }

    func postEnergyAwarded(_ amount: Int, balance: Int) {
        guard amount != 0 else { return }
        NotificationCenter.default.post(
            name: .energyAwarded,
            object: nil,
            userInfo: [EnergyAwardedKey.amount: amount, EnergyAwardedKey.balance: balance]
        )
    }

    func makeServerError(data: Data, statusCode: Int, headers: HTTPURLResponse? = nil) throws -> APIError {
        if statusCode == 401 {
            SessionManager.end()
            NotificationCenter.default.post(name: .sessionExpired, object: nil)
            return .unauthorized
        }
        if statusCode == 429 {
            let retryAfter = headers?.value(forHTTPHeaderField: "Retry-After").flatMap(Int.init)
            return .rateLimited(retryAfterSeconds: retryAfter)
        }
        if let envelope = try? JSONDecoder().decode(ErrorEnvelope.self, from: data) {
            return .server(code: envelope.error.code, message: envelope.error.message, details: envelope.error.details)
        }
        return .server(code: "UNKNOWN", message: "Request failed (status \(statusCode)).", details: nil)
    }
}
