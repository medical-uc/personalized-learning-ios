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
    let topicTag: [String]
    let difficulty: Difficulty
    let prompt: String
    let options: [QuizOption]
    var correctIndex: Int?
    var selectedIndex: Int?
    var isLogged = false
    var nextReviewAt: Date? = nil
    let explanationTitle: String
    var explanationBody: String
    let reference: String

    /// Leaf topic_path for this question's BKT entry — same " > "-joined shape
    /// MasteryEntry.topicPath already uses, so BKTStore keys line up with zero
    /// translation. Falls back to `subject` alone if topicTag is somehow empty.
    var topicPath: String {
        topicTag.isEmpty ? subject : topicTag.joined(separator: " > ")
    }

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
        self.topicTag = questionOut.topicTag
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
    var reviewQuestions: [QuizQuestion] = []

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

struct OptionOut: Decodable {
    let index: Int
    let text: String
}

struct QuestionOut: Decodable {
    let uid: String
    let stem: String
    let options: [OptionOut]
    let topicTag: [String]
    let difficulty: Int

    enum CodingKeys: String, CodingKey {
        case uid, stem, options
        case topicTag = "topic_tag"
        case difficulty
    }
}

struct CheckAnswerRequest: Encodable {
    let selectedIndex: Int

    enum CodingKeys: String, CodingKey {
        case selectedIndex = "selected_index"
    }
}

struct CheckAnswerResponse: Decodable {
    let correct: Bool
    let correctIndex: Int
    let explanation: String

    enum CodingKeys: String, CodingKey {
        case correct
        case correctIndex = "correct_index"
        case explanation
    }
}

struct LogAttemptRequest: Encodable {
    let sessionId: String
    let selectedIndex: Int
    let confidence: String
    let timeTakenSeconds: Double
    let nextReviewDays: Int?

    enum CodingKeys: String, CodingKey {
        case sessionId = "session_id"
        case selectedIndex = "selected_index"
        case confidence
        case timeTakenSeconds = "time_taken_seconds"
        case nextReviewDays = "next_review_days"
    }
}

struct LogAttemptResponse: Decodable {
    let eventId: String
    let correct: Bool
    let nextReviewAt: Date

    enum CodingKeys: String, CodingKey {
        case eventId = "event_id"
        case correct
        case nextReviewAt = "next_review_at"
    }
}

struct StartSessionResponse: Decodable {
    let sessionId: String

    enum CodingKeys: String, CodingKey {
        case sessionId = "session_id"
    }
}

/// Response for the cross-topic batch session (POST /quiz/sessions): unlike a
/// topic-scoped session, question_uids is the fixed due-first batch pinned server-side
/// at start time — pair with getAllQuestions() to resolve uids to content, same as
/// FlashcardViewModel does with card_uids.
struct StartBatchSessionResponse: Decodable {
    let sessionId: String
    let questionUids: [String]

    enum CodingKeys: String, CodingKey {
        case sessionId = "session_id"
        case questionUids = "question_uids"
    }
}

struct StartBatchSessionRequest: Encodable {
    let size: Int?
}

struct EndSessionResponse: Decodable {
    let sessionId: String
    let questionCount: Int
    let correctCount: Int
    let durationSeconds: Int
    let energyAwarded: Int
    let energyBalance: Int

    enum CodingKeys: String, CodingKey {
        case sessionId = "session_id"
        case questionCount = "question_count"
        case correctCount = "correct_count"
        case durationSeconds = "duration_seconds"
        case energyAwarded = "energy_awarded"
        case energyBalance = "energy_balance"
    }
}

struct CancelSessionResponse: Decodable {
    let sessionId: String
    let questionCount: Int
    let correctCount: Int
    let durationSeconds: Int

    enum CodingKeys: String, CodingKey {
        case sessionId = "session_id"
        case questionCount = "question_count"
        case correctCount = "correct_count"
        case durationSeconds = "duration_seconds"
    }
}

enum QuizData {
    static let sampleQuestion = QuizQuestion(
        id: "sample",
        index: 3,
        subject: "Pharmacology",
        topicTag: ["Pharmacology", "Beta-blockers"],
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
        reference: "Katzung & Trevor's Pharmacology, 15th Edition"
    )
}
