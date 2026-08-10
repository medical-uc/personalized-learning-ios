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
        do {
            return try await session.data(for: request)
        } catch {
            throw APIError.network(error)
        }
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

    func post<Response: Decodable>(path: String, expectedStatus: Int, token: String? = SessionManager.token) async throws -> Response {
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

    func postEnergyAwarded(_ amount: Int, balance: Int) {
        guard amount != 0 else { return }
        NotificationCenter.default.post(
            name: .energyAwarded,
            object: nil,
            userInfo: [EnergyAwardedKey.amount: amount, EnergyAwardedKey.balance: balance]
        )
    }

    func makeServerError(data: Data, statusCode: Int, action: String) throws -> APIError {
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
