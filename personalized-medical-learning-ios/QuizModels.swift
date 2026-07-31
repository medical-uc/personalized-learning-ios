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
    let id: Int
    let letter: String
    let text: String
}

enum QuestionState {
    case correct
    case incorrect
    case unanswered
}

struct QuizQuestion: Identifiable {
    let id: String
    let index: Int
    let subject: String
    let difficulty: Difficulty
    let prompt: String
    let options: [QuizOption]
    var correctIndex: Int?
    var selectedIndex: Int?
    var isLogged = false
    let explanationTitle: String
    var explanationBody: String
    let reference: String
    var isBookmarked: Bool

    var state: QuestionState {
        guard let correctIndex, selectedIndex != nil else { return .unanswered }
        return selectedIndex == correctIndex ? .correct : .incorrect
    }

    var selectedLetter: String? {
        options.first { $0.id == selectedIndex }?.letter
    }

    var correctLetter: String? {
        options.first { $0.id == correctIndex }?.letter
    }
}

extension QuizQuestion {
    private static let letters = ["A", "B", "C", "D", "E", "F"]

    init(index: Int, questionOut: QuestionOut) {
        self.id = questionOut.uid
        self.index = index
        self.subject = questionOut.topicTag.first ?? "General"
        self.difficulty = Difficulty(serverLevel: questionOut.difficulty)
        self.prompt = questionOut.stem
        self.options = questionOut.options.map { option in
            QuizOption(
                id: option.index,
                letter: Self.letters[safe: option.index] ?? "\(option.index + 1)",
                text: option.text
            )
        }
        self.correctIndex = nil
        self.selectedIndex = nil
        self.explanationTitle = "Explanation"
        self.explanationBody = ""
        self.reference = questionOut.topicTag.joined(separator: " / ")
        self.isBookmarked = false
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

extension Difficulty {
    init(serverLevel: Int) {
        switch serverLevel {
        case ..<2: self = .easy
        case 2: self = .medium
        default: self = .hard
        }
    }
}

struct QuizResultSummary {
    let topicPath: String
    let totalQuestions: Int
    let correctCount: Int
    let incorrectCount: Int
    let unansweredCount: Int
    let elapsedSeconds: Int

    var scorePercent: Int {
        guard totalQuestions > 0 else { return 0 }
        return Int((Double(correctCount) / Double(totalQuestions) * 100).rounded())
    }

    var elapsedTimeText: String {
        let minutes = elapsedSeconds / 60
        let seconds = elapsedSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

enum QuizData {
    static let sampleQuestion = QuizQuestion(
        id: "sample",
        index: 3,
        subject: "Pharmacology",
        difficulty: .medium,
        prompt: "Which of the following mechanisms is the primary reason for the therapeutic effect of beta-blockers in patients with hypertension?",
        options: [
            .init(id: 0, letter: "A", text: "Decreased heart rate and cardiac output"),
            .init(id: 1, letter: "B", text: "Inhibition of sodium reabsorption in the kidneys"),
            .init(id: 2, letter: "C", text: "Vasodilation of peripheral arterioles"),
            .init(id: 3, letter: "D", text: "Increased renin release from the juxtaglomerular cells")
        ],
        correctIndex: 0,
        selectedIndex: 0,
        explanationTitle: "Explanation",
        explanationBody: "Beta-blockers reduce heart rate and cardiac output by blocking β1-adrenergic receptors in the heart. This decreases the force and rate of contraction, leading to lower blood pressure.",
        reference: "Katzung & Trevor's Pharmacology, 15th Edition",
        isBookmarked: false
    )
}
