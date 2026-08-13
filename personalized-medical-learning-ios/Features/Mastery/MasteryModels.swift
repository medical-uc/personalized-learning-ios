//
//  MasteryModels.swift
//  personalized-medical-learning-ios
//

import Foundation

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
