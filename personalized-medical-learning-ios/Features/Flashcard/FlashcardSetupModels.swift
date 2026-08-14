//
//  FlashcardSetupModels.swift
//  personalized-medical-learning-ios
//

import Foundation

enum FlashcardSetupStep: Int, SetupStep {
    case topics
    case start

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .topics: return "Choose Topic"
        case .start: return "Session Preview"
        }
    }

    var subtitle: String {
        switch self {
        case .topics: return "Select the topic you want to review, or study everything due."
        case .start: return "Review your session before starting."
        }
    }
}

struct FlashcardSessionPreview {
    let dueCount: Int
    let totalCount: Int
    let weakestTopic: MasteryEntry?
}
