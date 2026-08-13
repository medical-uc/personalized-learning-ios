//
//  MasteryEntry.swift
//  personalized-medical-learning-ios
//

import SwiftUI

struct MasteryEntry: Identifiable {
    let id: String
    let topicPath: String
    let pKnow: Double
    let updatedAt: Date

    var percent: Int { Int((pKnow * 100).rounded()) }

    var level: MasteryLevel { MasteryLevel(pKnow: pKnow) }

    var tint: Color { level.tint }

    var statusLabel: String { level.label }

    /// Deepest segment of topic_path (e.g. "ENDOCRINOLOGY > Thyroid hormone synthesis" -> "Thyroid hormone synthesis"),
    /// same leaf-vs-subject split the backend's topic_tag chain already encodes.
    var topicName: String {
        topicPath.components(separatedBy: " > ").last ?? topicPath
    }

    var subjectName: String {
        let parts = topicPath.components(separatedBy: " > ")
        return parts.count > 1 ? parts.first ?? topicPath : topicPath
    }

    /// Best-effort subject → icon/tint so Focus Areas doesn't show the same glyph for
    /// every row; falls back to a generic book for subjects outside the curated list.
    private static let subjectStyles: [(keyword: String, icon: String, tint: Color)] = [
        ("cardio", "heart.text.square.fill", .red),
        ("pharma", "pills.fill", .purple),
        ("physio", "brain.head.profile", .orange),
        ("anatom", "figure.stand", .blue),
        ("patho", "cross.case.fill", .pink),
        ("micro", "ant.fill", .teal),
        ("neuro", "brain", .indigo),
        ("endocrin", "drop.fill", .mint),
        ("respirat", "lungs.fill", .cyan),
        ("renal", "drop.triangle.fill", .brown)
    ]

    var subjectIcon: String {
        Self.subjectStyles.first { subjectName.localizedCaseInsensitiveContains($0.keyword) }?.icon ?? "book.closed.fill"
    }

    var subjectIconTint: Color {
        Self.subjectStyles.first { subjectName.localizedCaseInsensitiveContains($0.keyword) }?.tint ?? Theme.dark
    }
}

extension MasteryEntry {
    /// Builds the same entry the Subjects topic-detail sheet uses, from a Subjects-tab Topic —
    /// so tapping a topic row on the subject page opens the identical breakdown sheet
    /// (history, confidence rules, streak simulator) instead of a separate view.
    /// updatedAt is re-read from BKTStore since Topic doesn't carry it.
    init(from topic: Topic) {
        self.id = topic.id
        self.topicPath = topic.id
        self.pKnow = topic.progress
        self.updatedAt = BKTStore.updatedAt(for: topic.id) ?? Date()
    }
}
