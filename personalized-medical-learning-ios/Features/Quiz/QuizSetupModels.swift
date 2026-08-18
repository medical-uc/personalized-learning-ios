//
//  QuizSetupModels.swift
//  personalized-medical-learning-ios
//

import SwiftUI

struct QuizTopic: Identifiable, Equatable {
    var id: String { path }
    let path: String
    let subject: String
    let name: String
    let icon: String
    let tint: Color

    /// Server paths look like "Amino Acids & Peptides > BIOMEDICAL IMPORTANCE > ..." —
    /// the segment before " > " is the subject, the rest is the topic name.
    static func fromServerPath(_ path: String) -> QuizTopic {
        let parts = path.components(separatedBy: " > ")
        let subject = parts.first ?? path
        let name = parts.count > 1 ? parts.dropFirst().joined(separator: " > ") : path
        return QuizTopic(
            path: path,
            subject: subject,
            name: name,
            icon: "book.closed.fill",
            tint: Theme.dark
        )
    }
}

struct QuizSubjectGroup: Identifiable {
    var id: String { subject }
    let subject: String
    let topics: [QuizTopic]
}

enum QuizSetupStep: Int, SetupStep {
    case topics
    case start

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .topics: return "Choose Topics"
        case .start: return "Quiz Preview"
        }
    }

    var subtitle: String {
        switch self {
        case .topics: return "Select up to \(QuizSetupView.maxTopics) topics you want to be tested on."
        case .start: return "Review your quiz before starting."
        }
    }
}

struct QuizSettings {
    var isTimerEnabled: Bool = true
    var secondsPerQuestion: Int = 60
    var isReviewModeEnabled: Bool = true
    var questionCount: Int = 10
}
