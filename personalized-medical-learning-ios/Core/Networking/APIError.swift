//
//  APIError.swift
//  personalized-medical-learning-ios
//

import Foundation

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
