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
    /// Keyed to the live biochem question bank's subject names (see
    /// src/domain_kg/data/docs/*/questions.json chapters) — not the old
    /// anatomy/endocrine/physio subject set this repo shipped before that swap.
    private static let subjectStyles: [(keyword: String, icon: String, tint: Color)] = [
        ("amino acid", "link", .red),
        ("protein", "puzzlepiece.fill", .red),
        ("metabolism", "bolt.fill", .orange),
        ("gluconeogenesis", "bolt.fill", .orange),
        ("glycogen", "bolt.fill", .orange),
        ("lipid", "drop.fill", .yellow),
        ("fatty acid", "drop.fill", .yellow),
        ("acylglycerol", "drop.fill", .yellow),
        ("enzyme", "arrow.triangle.branch", .blue),
        ("signal transduction", "arrow.triangle.branch", .blue),
        ("hormone", "waveform.path.ecg", .pink),
        ("endocrine", "waveform.path.ecg", .pink),
        ("nucleotide", "atom", .purple),
        ("gene expression", "atom", .purple),
        ("genetic code", "atom", .purple),
        ("porphyrin", "circle.hexagongrid.fill", .indigo),
        ("transition metal", "circle.hexagongrid.fill", .indigo),
        ("vitamin", "leaf.fill", .green),
        ("micronutrient", "leaf.fill", .green),
        ("antioxidant", "leaf.fill", .green),
        ("respiratory chain", "lungs.fill", .cyan),
        ("oxidative phosphorylation", "lungs.fill", .cyan),
        ("glycoprotein", "hexagon.fill", .teal),
        ("pentose phosphate", "hexagon.fill", .teal),
        ("water", "drop.triangle.fill", .brown)
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
