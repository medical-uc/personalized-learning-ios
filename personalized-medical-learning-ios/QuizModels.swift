//
//  QuizModels.swift
//  personalized-medical-learning-ios
//

import Foundation

enum Difficulty: String {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"

    var bars: Int {
        switch self {
        case .easy: return 1
        case .medium: return 2
        case .hard: return 3
        }
    }
}

struct QuizOption: Identifiable {
    let id = UUID()
    let letter: String
    let text: String
}

enum QuestionState {
    case correct
    case incorrect
    case unanswered
}

struct QuizQuestion: Identifiable {
    let id = UUID()
    let index: Int
    let subject: String
    let difficulty: Difficulty
    let xp: Int
    let prompt: String
    let options: [QuizOption]
    let correctLetter: String
    let selectedLetter: String?
    let explanationTitle: String
    let explanationBody: String
    let reference: String
    let state: QuestionState
    let isBookmarked: Bool
}

enum QuizData {
    static let totalQuestions = 10

    static let sampleQuestion = QuizQuestion(
        index: 3,
        subject: "Pharmacology",
        difficulty: .medium,
        xp: 10,
        prompt: "Which of the following mechanisms is the primary reason for the therapeutic effect of beta-blockers in patients with hypertension?",
        options: [
            .init(letter: "A", text: "Decreased heart rate and cardiac output"),
            .init(letter: "B", text: "Inhibition of sodium reabsorption in the kidneys"),
            .init(letter: "C", text: "Vasodilation of peripheral arterioles"),
            .init(letter: "D", text: "Increased renin release from the juxtaglomerular cells")
        ],
        correctLetter: "A",
        selectedLetter: "A",
        explanationTitle: "Explanation",
        explanationBody: "Beta-blockers reduce heart rate and cardiac output by blocking β1-adrenergic receptors in the heart. This decreases the force and rate of contraction, leading to lower blood pressure.",
        reference: "Katzung & Trevor's Pharmacology, 15th Edition",
        state: .correct,
        isBookmarked: false
    )

    static let navigatorStates: [QuestionState] = [
        .correct, .correct, .correct, .unanswered, .unanswered,
        .unanswered, .unanswered, .unanswered, .unanswered, .unanswered
    ]

    static let correctCount = 2
    static let incorrectCount = 0
    static let unansweredCount = 1
    static let avgTime = "00:12"
}
