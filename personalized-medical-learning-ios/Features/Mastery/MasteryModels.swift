//
//  MasteryModels.swift
//  personalized-medical-learning-ios
//

import Foundation

struct DueReviewItem: Decodable {
    let questionUid: String
    let topicPath: String
    let streak: Int
    let intervalDays: Int
    let lastReviewedAt: Date
    let nextReviewAt: Date

    enum CodingKeys: String, CodingKey {
        case questionUid = "question_uid"
        case topicPath = "topic_path"
        case streak
        case intervalDays = "interval_days"
        case lastReviewedAt = "last_reviewed_at"
        case nextReviewAt = "next_review_at"
    }
}

struct DueReviewResponse: Decodable {
    let items: [DueReviewItem]
}

/// One topic_path/p_know pair pushed to PUT /quiz/mastery — mirrors the backend's
/// MasteryUpdateItem (no updated_at; the server stamps that on write).
struct MasteryUpdateItem: Encodable {
    let topicPath: String
    let pKnow: Double

    enum CodingKeys: String, CodingKey {
        case topicPath = "topic_path"
        case pKnow = "p_know"
    }
}

struct UpdateMasteryRequest: Encodable {
    let items: [MasteryUpdateItem]
}

struct UpdateMasteryResponse: Decodable {
    let updatedCount: Int

    enum CodingKeys: String, CodingKey {
        case updatedCount = "updated_count"
    }
}

/// GET /quiz/mastery/params response — the global BKT emission/transition parameters,
/// EM-fit server-side from every student's pooled QUIZ_ANSWER history (see the backend's
/// src/quiz/bkt_fit.py). BKTStore fetches and caches this, replacing its own hard-coded
/// defaults, so the shared "how noisy is a confident vs. guessing answer" model stays
/// current as real interaction volume grows — p_know itself stays entirely
/// client-computed, this only affects the emission/transition parameters that computation
/// uses.
struct BKTConfidenceParams: Codable {
    let confident: Double
    let unsure: Double
    let guessing: Double

    subscript(_ level: ConfidenceLevel) -> Double {
        switch level {
        case .confident: return confident
        case .unsure: return unsure
        case .guessing: return guessing
        }
    }
}

struct BKTParamsResponse: Codable {
    let pInit: Double
    let pTransit: Double
    let pSlip: BKTConfidenceParams
    let pGuess: BKTConfidenceParams
    let nAttempts: Int
    let nSequences: Int
    let fittedFromDefaults: Bool

    enum CodingKeys: String, CodingKey {
        case pInit = "p_init"
        case pTransit = "p_transit"
        case pSlip = "p_slip"
        case pGuess = "p_guess"
        case nAttempts = "n_attempts"
        case nSequences = "n_sequences"
        case fittedFromDefaults = "fitted_from_defaults"
    }
}
