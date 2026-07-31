//
//  QuizSetupModels.swift
//  personalized-medical-learning-ios
//

import SwiftUI

struct QuizTopic: Identifiable, Equatable {
    var id: String { path }
    let path: String
    let name: String
    let icon: String
    let tint: Color

    static func fromServerPath(_ path: String) -> QuizTopic {
        let display = path
            .replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(of: "-", with: " ")
            .split(separator: "/")
            .last
            .map(String.init) ?? path
        return QuizTopic(
            path: path,
            name: display.capitalized,
            icon: "book.closed.fill",
            tint: Theme.dark
        )
    }
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
}

enum QuizSetupOptions {
    static let timerOptions = [15, 30, 45, 60, 90, 120]
}
