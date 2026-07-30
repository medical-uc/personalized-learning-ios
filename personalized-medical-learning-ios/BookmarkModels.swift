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
        .init(kind: .question, title: "What is the most common cause of acute myocardial infarction?", subtitle: "Cardiology · Quiz Question", icon: "questionmark.circle", tint: .red, savedAgo: "2d ago"),
        .init(kind: .flashcard, title: "SA Node", subtitle: "Cardiology · Flashcard", icon: "rectangle.stack", tint: .teal, savedAgo: "3d ago"),
        .init(kind: .subject, title: "Cardiology", subtitle: "Subject · 142 concepts", icon: "heart.fill", tint: .red, savedAgo: "5d ago"),
        .init(kind: .question, title: "Which cranial nerve controls the muscles of facial expression?", subtitle: "Neurology · Quiz Question", icon: "questionmark.circle", tint: .pink, savedAgo: "1w ago"),
        .init(kind: .flashcard, title: "Bundle of His", subtitle: "Cardiology · Flashcard", icon: "rectangle.stack", tint: .teal, savedAgo: "1w ago"),
        .init(kind: .subject, title: "Pharmacology", subtitle: "Subject · 310 concepts", icon: "pills.fill", tint: .orange, savedAgo: "2w ago")
    ]
}
