//
//  FlashcardModels.swift
//  personalized-medical-learning-ios
//

import SwiftUI

struct Flashcard: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
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
    static let cards: [Flashcard] = [
        .init(
            question: "What is the most common cause of acute myocardial infarction?",
            answer: "Rupture of an atherosclerotic plaque leading to coronary artery thrombosis."
        )
    ]

    static let currentIndex = 12
    static let totalCards = 150

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
