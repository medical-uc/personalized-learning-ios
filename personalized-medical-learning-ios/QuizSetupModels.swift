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

    /// Server paths look like "Anatomy of Endocrine Glands > Thyroid gland anatomy" —
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

enum QuizSetupStep: Int, CaseIterable, Identifiable {
    case topics
    case settings
    case start

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .topics: return "Choose Topic"
        case .settings: return "Quiz Settings"
        case .start: return "Quiz Preview"
        }
    }

    var subtitle: String {
        switch self {
        case .topics: return "Select the topic you want to be tested on."
        case .settings: return "Set the preferences for your quiz."
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

enum QuizSetupOptions {
    static let timerOptions = [15, 30, 45, 60, 90, 120]
    static let questionCountOptions = [5, 10, 15, 20, 25]
}
