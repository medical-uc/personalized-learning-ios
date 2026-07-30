//
//  SubjectModels.swift
//  personalized-medical-learning-ios
//

import SwiftUI

struct Subject: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let tint: Color
    let progress: Double
    let concepts: Int
    let questions: Int
    let flashcards: Int
}

enum SubjectTab: String, CaseIterable, Identifiable {
    case allSubjects = "All Subjects"
    case myProgress = "My Progress"

    var id: String { rawValue }
}

enum SubjectData {
    static let subjects: [Subject] = [
        .init(name: "Cardiology", icon: "heart.fill", tint: .red, progress: 0.82, concepts: 142, questions: 420, flashcards: 1220),
        .init(name: "Anatomy", icon: "figure.stand", tint: .teal, progress: 0.63, concepts: 218, questions: 560, flashcards: 1842),
        .init(name: "Pharmacology", icon: "pills.fill", tint: .orange, progress: 0.54, concepts: 310, questions: 680, flashcards: 2105),
        .init(name: "Pathology", icon: "microscope", tint: .blue, progress: 0.71, concepts: 180, questions: 410, flashcards: 1150),
        .init(name: "Microbiology", icon: "circle.grid.3x3.fill", tint: .purple, progress: 0.43, concepts: 126, questions: 300, flashcards: 980),
        .init(name: "Neurology", icon: "brain.head.profile", tint: .pink, progress: 0.22, concepts: 84, questions: 210, flashcards: 620),
        .init(name: "Pulmonology", icon: "lungs.fill", tint: .cyan, progress: 0.58, concepts: 96, questions: 250, flashcards: 720)
    ]
}
