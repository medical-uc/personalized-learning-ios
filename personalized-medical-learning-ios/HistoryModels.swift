//
//  HistoryModels.swift
//  personalized-medical-learning-ios
//

import SwiftUI

enum HistoryActivityType {
    case quiz
    case flashcard

    var icon: String {
        switch self {
        case .quiz: return "questionmark.circle"
        case .flashcard: return "rectangle.stack"
        }
    }

    var label: String {
        switch self {
        case .quiz: return "Quiz"
        case .flashcard: return "Flashcards"
        }
    }
}

struct HistoryEntry: Identifiable {
    let id = UUID()
    let type: HistoryActivityType
    let subject: String
    let tint: Color
    let questionCount: Int
    let accuracy: Int
    let duration: String
    let timeLabel: String
}

struct HistorySection: Identifiable {
    let id = UUID()
    let title: String
    let entries: [HistoryEntry]
}

enum HistoryData {
    static let sections: [HistorySection] = [
        .init(title: "Today", entries: [
            .init(type: .quiz, subject: "Cardiology", tint: .red, questionCount: 10, accuracy: 80, duration: "12m", timeLabel: "9:20 AM"),
            .init(type: .flashcard, subject: "Cardiology", tint: .red, questionCount: 24, accuracy: 92, duration: "8m", timeLabel: "7:45 AM")
        ]),
        .init(title: "Yesterday", entries: [
            .init(type: .quiz, subject: "Pharmacology", tint: .orange, questionCount: 15, accuracy: 67, duration: "18m", timeLabel: "6:10 PM"),
            .init(type: .quiz, subject: "Neurology", tint: .pink, questionCount: 8, accuracy: 50, duration: "9m", timeLabel: "2:30 PM")
        ]),
        .init(title: "This Week", entries: [
            .init(type: .flashcard, subject: "Pathology", tint: .blue, questionCount: 40, accuracy: 88, duration: "15m", timeLabel: "Mon, 4:15 PM"),
            .init(type: .quiz, subject: "Anatomy", tint: .teal, questionCount: 20, accuracy: 75, duration: "22m", timeLabel: "Mon, 11:00 AM"),
            .init(type: .quiz, subject: "Microbiology", tint: .purple, questionCount: 12, accuracy: 58, duration: "14m", timeLabel: "Sun, 8:30 PM")
        ])
    ]
}
