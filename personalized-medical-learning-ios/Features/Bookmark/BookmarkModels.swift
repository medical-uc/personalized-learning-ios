//
//  BookmarkModels.swift
//  personalized-medical-learning-ios
//

import SwiftUI

enum BookmarkKind: String, CaseIterable, Identifiable {
    case all = "All"
    case question = "Questions"
    case flashcard = "Flashcards"
    case subject = "Subjects"

    var id: String { rawValue }
}

struct BookmarkItem: Identifiable {
    let id = UUID()
    let kind: BookmarkKind
    let title: String
    let subtitle: String
    let icon: String
    let tint: Color
    let savedAgo: String
}

enum BookmarkData {
    static let items: [BookmarkItem] = [
        .init(kind: .question, title: "Which enzyme catalyzes the committed step of glycolysis?", subtitle: "Metabolism & Bioenergetics · Quiz Question", icon: "questionmark.circle", tint: .orange, savedAgo: "2d ago"),
        .init(kind: .flashcard, title: "Urea Cycle", subtitle: "Amino Acids & Peptides · Flashcard", icon: "rectangle.stack", tint: .red, savedAgo: "3d ago"),
        .init(kind: .subject, title: "Amino Acids & Peptides", subtitle: "Subject · 142 concepts", icon: "link", tint: .red, savedAgo: "5d ago"),
        .init(kind: .question, title: "Which lipoprotein is responsible for reverse cholesterol transport?", subtitle: "Lipids & Fatty Acids · Quiz Question", icon: "questionmark.circle", tint: .yellow, savedAgo: "1w ago"),
        .init(kind: .flashcard, title: "Electron Transport Chain", subtitle: "Metabolism & Bioenergetics · Flashcard", icon: "rectangle.stack", tint: .cyan, savedAgo: "1w ago"),
        .init(kind: .subject, title: "Endocrine Biochemistry", subtitle: "Subject · 310 concepts", icon: "waveform.path.ecg", tint: .pink, savedAgo: "2w ago")
    ]
}
