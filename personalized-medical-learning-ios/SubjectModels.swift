//
//  SubjectModels.swift
//  personalized-medical-learning-ios
//

import SwiftUI

struct Topic: Identifiable {
    let id: String  // topic_path — stable across reloads, unlike a fresh UUID
    let number: Int
    let name: String
    let questionCount: Int
    let flashcardCount: Int
    let progress: Double  // BKTStore.pKnow(for: id), joined client-side — see MasteryEntry
    let isComplete: Bool
}

/// Named StudySubject, not Subject, to avoid colliding with Combine's Subject protocol
/// (@Published/ObservableObject bring Combine into scope everywhere this type is used).
struct StudySubject: Identifiable {
    let id: String  // subject name — stable across reloads
    let name: String
    let questionCount: Int
    let flashcardCount: Int
    let topics: [Topic]

    /// Mean of this subject's topics' BKT mastery — 0 for a subject with no topics
    /// (shouldn't happen from the backend, but keeps this total rather than partial).
    var progress: Double {
        guard !topics.isEmpty else { return 0 }
        return topics.reduce(0) { $0 + $1.progress } / Double(topics.count)
    }

    var masteredConcepts: Int {
        topics.filter { $0.isComplete }.count
    }

    /// Best-effort subject -> icon/tint, same keyword table MasteryEntry uses for the
    /// dashboard's Focus Areas card, so a subject reads the same color/glyph everywhere
    /// it appears. Falls back to a generic book for subjects outside the curated list.
    private static let subjectStyles: [(keyword: String, icon: String, tint: Color)] = [
        ("cardio", "heart.fill", .red),
        ("pharma", "pills.fill", .orange),
        ("physio", "brain.head.profile", .orange),
        ("anatom", "figure.stand", .teal),
        ("patho", "microscope", .blue),
        ("micro", "circle.grid.3x3.fill", .purple),
        ("neuro", "brain.head.profile", .pink),
        ("endocrin", "drop.fill", .mint),
        ("respirat", "lungs.fill", .cyan),
        ("pulmo", "lungs.fill", .cyan),
        ("renal", "drop.triangle.fill", .brown),
        ("digest", "figure.walk", .green),
        ("gi ", "figure.walk", .green),
        ("pelvi", "figure.stand", .indigo),
        ("abdomin", "figure.stand", .teal),
        ("histolog", "microscope", .blue),
        ("face", "person.fill", .teal),
        ("oral", "person.fill", .teal),
        ("neck", "person.fill", .teal)
    ]

    var icon: String {
        Self.subjectStyles.first { name.localizedCaseInsensitiveContains($0.keyword) }?.icon ?? "book.closed.fill"
    }

    var tint: Color {
        Self.subjectStyles.first { name.localizedCaseInsensitiveContains($0.keyword) }?.tint ?? Theme.dark
    }
}

enum SubjectTab: String, CaseIterable, Identifiable {
    case allSubjects = "All Subjects"
    case myProgress = "My Progress"

    var id: String { rawValue }
}

extension StudySubject {
    /// Builds a StudySubject from the backend catalog (GET /quiz/subjects), joining each
    /// topic's mastery from the on-device BKT store by topic_path — mirrors how
    /// MasteryEntry/BKTStore.allEntries() already join mastery onto topic_path elsewhere
    /// in the app, so this page's percentages always agree with Mastery/Dashboard.
    init(from out: SubjectOut) {
        self.id = out.name
        self.name = out.name
        self.questionCount = out.questionCount
        self.flashcardCount = out.flashcardCount
        self.topics = out.topics.enumerated().map { index, t in
            let pKnow = BKTStore.pKnow(for: t.path)
            return Topic(
                id: t.path,
                number: index + 1,
                name: t.name,
                questionCount: t.questionCount,
                flashcardCount: t.flashcardCount,
                progress: pKnow,
                isComplete: pKnow > 0.7
            )
        }
    }
}
