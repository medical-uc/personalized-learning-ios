//
//  APIError.swift
//  personalized-medical-learning-ios
//

import Foundation

enum APIError: LocalizedError {
    /// Server responded with the standard {error:{code,message,details}} envelope.
    case server(code: String, message: String, details: [String]?)
    case decoding
    case network(Error)
    /// Device has no route to the backend — checked before firing the request.
    case offline
    /// Backend took too long to respond.
    case timeout
    case unauthorized
    /// 429 with an optional Retry-After (seconds) from the response header.
    case rateLimited(retryAfterSeconds: Int?)

    var errorDescription: String? {
        switch self {
        case .server(_, let message, _):
            return message
        case .decoding:
            return "Received an unexpected response from the server."
        case .network:
            return "Couldn't reach the server. Check your connection and try again."
        case .offline:
            return "You're offline. Check your connection and try again."
        case .timeout:
            return "The request timed out. Try again."
        case .unauthorized:
            return "Your session has expired. Please sign in again."
        case .rateLimited(let retryAfterSeconds):
            if let retryAfterSeconds {
                return "Too many attempts. Try again in \(retryAfterSeconds)s."
            }
            return "Too many attempts. Try again shortly."
        }
    }

    /// Stable machine-readable code for branching, when the server supplied one.
    var code: String? {
        if case .server(let code, _, _) = self { return code }
        return nil
    }

    /// True for transient failures worth retrying (network blips, timeouts, 5xx).
    var isRetryable: Bool {
        switch self {
        case .network, .timeout:
            return true
        case .server(let code, _, _):
            return code == "INTERNAL_ERROR" || code == "SERVICE_UNAVAILABLE"
        default:
            return false
        }
    }

    /// Client-side guard failures (e.g. "not signed in") that never reached the server —
    /// no server code applies, so this is tagged CLIENT_ERROR rather than left ambiguous.
    static func server(_ message: String) -> APIError {
        .server(code: "CLIENT_ERROR", message: message, details: nil)
    }
}

/// Matches the backend's shared error envelope: {"error": {"code", "message", "details"?}}.
struct ErrorEnvelope: Decodable {
    struct Body: Decodable {
        let code: String
        let message: String
        let details: [String]?

        enum CodingKeys: String, CodingKey {
            case code, message, details
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            code = try container.decode(String.self, forKey: .code)
            message = try container.decode(String.self, forKey: .message)
            // details entries are free-form objects (validation error dicts) — flatten
            // to a display string per entry instead of modeling their shape.
            if let raw = try? container.decode([JSONValue].self, forKey: .details) {
                details = raw.map { $0.displayString }
            } else {
                details = nil
            }
        }
    }
    let error: Body
}

/// Minimal untyped JSON box, used only to render `details` entries as text.
enum JSONValue: Decodable {
    case string(String)
    case object([String: JSONValue])
    case other

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let string = try? container.decode(String.self) {
            self = .string(string)
        } else if let object = try? decoder.container(keyedBy: DynamicKey.self) {
            var dict: [String: JSONValue] = [:]
            for key in object.allKeys {
                dict[key.stringValue] = try? object.decode(JSONValue.self, forKey: key)
            }
            self = .object(dict)
        } else {
            self = .other
        }
    }

    var displayString: String {
        switch self {
        case .string(let value):
            return value
        case .object(let dict):
            if case .string(let msg)? = dict["msg"] {
                return msg
            }
            return dict.values.compactMap {
                if case .string(let value) = $0 { return value }
                return nil
            }.joined(separator: " ")
        case .other:
            return ""
        }
    }

    private struct DynamicKey: CodingKey {
        var stringValue: String
        init?(stringValue: String) { self.stringValue = stringValue }
        var intValue: Int? { nil }
        init?(intValue: Int) { nil }
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
