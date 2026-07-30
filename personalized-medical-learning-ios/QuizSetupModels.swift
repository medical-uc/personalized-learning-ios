//
//  QuizSetupModels.swift
//  personalized-medical-learning-ios
//

import SwiftUI

struct QuizTopic: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let icon: String
    let tint: Color
    let mastery: Int
    var isCustom: Bool = false

    var masteryColor: Color {
        switch mastery {
        case ..<40: return .orange
        default: return Theme.dark
        }
    }
}

enum QuizSetupStep: Int, CaseIterable, Identifiable {
    case topics
    case settings
    case start

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .topics: return "Choose Topics"
        case .settings: return "Quiz Settings"
        case .start: return "Quiz Preview"
        }
    }

    var subtitle: String {
        switch self {
        case .topics: return "Select the topics you want to be tested on."
        case .settings: return "Set the preferences for your quiz."
        case .start: return "Review your quiz before starting."
        }
    }
}

enum QuestionType: String, CaseIterable, Identifiable {
    case caseBased = "Case Based"
    case imageBased = "Image Based"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .caseBased: return "cross.case"
        case .imageBased: return "photo"
        }
    }
}

struct QuizSettings {
    var questionCount: Int = 20
    var selectedQuestionTypes: Set<QuestionType> = Set(QuestionType.allCases)
    var isTimerEnabled: Bool = true
    var secondsPerQuestion: Int = 60
    var isReviewModeEnabled: Bool = true
}

enum QuizSetupOptions {
    static let questionCounts = [10, 15, 20, 25, 30, 50]
    static let timerOptions = [15, 30, 45, 60, 90, 120]
}

enum QuizSetupData {
    static let topics: [QuizTopic] = [
        .init(name: "Cardiology", icon: "heart.fill", tint: .red, mastery: 82),
        .init(name: "Physiology", icon: "waveform.path.ecg", tint: .teal, mastery: 68),
        .init(name: "Pharmacology", icon: "pills.fill", tint: .purple, mastery: 61),
        .init(name: "Anatomy", icon: "figure.stand", tint: .green, mastery: 45),
        .init(name: "Pathology", icon: "microscope.fill", tint: .indigo, mastery: 38),
        .init(name: "Microbiology", icon: "ant.fill", tint: .yellow, mastery: 30),
        .init(name: "Biochemistry", icon: "atom", tint: .blue, mastery: 25)
    ]

    static let recommendedTopicNames: Set<String> = ["Cardiology", "Physiology", "Pharmacology", "Anatomy"]
}
