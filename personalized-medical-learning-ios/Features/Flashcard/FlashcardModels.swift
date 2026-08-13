//
//  FlashcardModels.swift
//  personalized-medical-learning-ios
//

import SwiftUI

struct Flashcard: Identifiable {
    let uid: String
    let front: String
    var back: String?
    var explanation: String?
    let topicTag: [String]
    let difficulty: Int
    var rating: FlashcardRating?

    var id: String { uid }

    /// Same " > "-joined shape as MasteryEntry.topicPath / QuizQuestion.topicPath,
    /// so BKTStore keys line up with zero translation.
    var topicPath: String {
        topicTag.isEmpty ? "General" : topicTag.joined(separator: " > ")
    }

    init(cardOut: FlashcardOut) {
        self.uid = cardOut.uid
        self.front = cardOut.front
        self.back = nil
        self.explanation = nil
        self.topicTag = cardOut.topicTag
        self.difficulty = cardOut.difficulty
        self.rating = nil
    }
}

struct TodayStatItem: Identifiable {
    let id = UUID()
    let icon: String
    let label: String
    let value: String
}

struct QuickActionItem: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
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

    /// Same " > "-joined shape as MasteryEntry.topicPath, so BKTStore keys line up
    /// with zero translation — lets session ordering sort by weakness before a
    /// Flashcard (which withholds back/explanation) is even constructed.
    var topicPath: String {
        topicTag.isEmpty ? "General" : topicTag.joined(separator: " > ")
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
    let sessionId: String
    let rating: FlashcardRating

    enum CodingKeys: String, CodingKey {
        case sessionId = "session_id"
        case rating
    }
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

enum FlashcardData {
    static let cardsStudied = 126
    static let cardsGoal = 200
    static let dayStreak = 12

    static let todayStats: [TodayStatItem] = [
        .init(icon: "doc.text", label: "New Cards", value: "24"),
        .init(icon: "checkmark.square", label: "Reviewed", value: "102"),
        .init(icon: "checkmark.circle", label: "Correct", value: "78%"),
        .init(icon: "clock", label: "Time Spent", value: "32m")
    ]

    static let deckName = "Cardiology Essentials"
    static let deckCardCount = 200
    static let deckProgress = 0.63

    static let quickActions: [QuickActionItem] = [
        .init(icon: "shuffle", title: "Shuffle Deck"),
        .init(icon: "square.grid.2x2", title: "Browse by Topic"),
        .init(icon: "doc.text", title: "View All Cards")
    ]
}
