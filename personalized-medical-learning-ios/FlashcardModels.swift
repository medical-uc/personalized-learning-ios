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
