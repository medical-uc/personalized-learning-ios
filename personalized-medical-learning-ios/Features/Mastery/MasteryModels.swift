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

struct DueReviewItem: Decodable {
    let questionUid: String
    let streak: Int
    let intervalDays: Int
    let lastReviewedAt: Date
    let nextReviewAt: Date

    enum CodingKeys: String, CodingKey {
        case questionUid = "question_uid"
        case streak
        case intervalDays = "interval_days"
        case lastReviewedAt = "last_reviewed_at"
        case nextReviewAt = "next_review_at"
    }
}

struct DueReviewResponse: Decodable {
    let items: [DueReviewItem]
}

struct MasteryItem: Decodable {
    let topicPath: String
    let pKnow: Double
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case topicPath = "topic_path"
        case pKnow = "p_know"
        case updatedAt = "updated_at"
    }
}

struct MasteryResponse: Decodable {
    let items: [MasteryItem]
}

/// One topic_path/p_know pair pushed to PUT /quiz/mastery — mirrors the backend's
/// MasteryUpdateItem (no updated_at; the server stamps that on write).
struct MasteryUpdateItem: Encodable {
    let topicPath: String
    let pKnow: Double

    enum CodingKeys: String, CodingKey {
        case topicPath = "topic_path"
        case pKnow = "p_know"
    }
}

struct UpdateMasteryRequest: Encodable {
    let items: [MasteryUpdateItem]
}

struct UpdateMasteryResponse: Decodable {
    let updatedCount: Int

    enum CodingKeys: String, CodingKey {
        case updatedCount = "updated_count"
    }
}
