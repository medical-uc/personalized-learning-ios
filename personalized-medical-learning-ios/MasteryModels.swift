//
//  MasteryModels.swift
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
