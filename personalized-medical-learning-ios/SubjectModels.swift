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
    let description: String
    let masteredConcepts: Int
    let timeStudied: String
    let topics: [Topic]
    let recommendedTopic: String
    let relatedConcepts: [String]
}

struct Topic: Identifiable {
    let id = UUID()
    let number: Int
    let name: String
    let description: String
    let progress: Double
    let concepts: Int
    let flashcards: Int
    let isComplete: Bool
}

enum SubjectTab: String, CaseIterable, Identifiable {
    case allSubjects = "All Subjects"
    case myProgress = "My Progress"

    var id: String { rawValue }
}

enum SubjectData {
    static let cardiologyTopics: [Topic] = [
        .init(number: 1, name: "Cardiac Anatomy", description: "Structure of the heart and blood vessels", progress: 1.0, concepts: 32, flashcards: 82, isComplete: true),
        .init(number: 2, name: "Cardiac Physiology", description: "Electrical activity and cardiac cycle", progress: 0.78, concepts: 28, flashcards: 108, isComplete: false),
        .init(number: 3, name: "ECG Interpretation", description: "Understanding ECG waves and rhythms", progress: 0.45, concepts: 24, flashcards: 96, isComplete: false),
        .init(number: 4, name: "Arrhythmias", description: "Types, causes and management", progress: 0.30, concepts: 26, flashcards: 110, isComplete: false),
        .init(number: 5, name: "Heart Failure", description: "Pathophysiology and clinical management", progress: 0.92, concepts: 18, flashcards: 72, isComplete: false),
        .init(number: 6, name: "Hypertension", description: "Diagnosis and treatment", progress: 0.80, concepts: 14, flashcards: 65, isComplete: false),
        .init(number: 7, name: "Valvular Heart Disease", description: "Disorders of heart valves", progress: 0.60, concepts: 20, flashcards: 83, isComplete: false)
    ]

    static let subjects: [Subject] = [
        .init(
            name: "Cardiology", icon: "heart.fill", tint: .red, progress: 0.82,
            concepts: 142, questions: 420, flashcards: 1220,
            description: "Study the structure, function, and disorders of the heart and blood vessels.",
            masteredConcepts: 142, timeStudied: "16h 24m",
            topics: cardiologyTopics,
            recommendedTopic: "ECG Interpretation",
            relatedConcepts: ["SA Node", "AV Node", "Bundle of His", "P Wave", "QRS Complex"]
        ),
        .init(
            name: "Anatomy", icon: "figure.stand", tint: .teal, progress: 0.63,
            concepts: 218, questions: 560, flashcards: 1842,
            description: "Study the structure of the human body, from cells to organ systems.",
            masteredConcepts: 137, timeStudied: "12h 05m",
            topics: [],
            recommendedTopic: "Skeletal System",
            relatedConcepts: ["Femur", "Scapula", "Cranium", "Vertebrae"]
        ),
        .init(
            name: "Pharmacology", icon: "pills.fill", tint: .orange, progress: 0.54,
            concepts: 310, questions: 680, flashcards: 2105,
            description: "Study how drugs interact with biological systems and their clinical uses.",
            masteredConcepts: 167, timeStudied: "9h 40m",
            topics: [],
            recommendedTopic: "Antibiotics",
            relatedConcepts: ["Pharmacokinetics", "Pharmacodynamics", "Half-Life"]
        ),
        .init(
            name: "Pathology", icon: "microscope", tint: .blue, progress: 0.71,
            concepts: 180, questions: 410, flashcards: 1150,
            description: "Study the causes and effects of disease on the body.",
            masteredConcepts: 128, timeStudied: "10h 12m",
            topics: [],
            recommendedTopic: "Neoplasia",
            relatedConcepts: ["Necrosis", "Inflammation", "Apoptosis"]
        ),
        .init(
            name: "Microbiology", icon: "circle.grid.3x3.fill", tint: .purple, progress: 0.43,
            concepts: 126, questions: 300, flashcards: 980,
            description: "Study of bacteria, viruses, fungi, and other microorganisms.",
            masteredConcepts: 54, timeStudied: "5h 30m",
            topics: [],
            recommendedTopic: "Virology",
            relatedConcepts: ["Gram Stain", "Bacteriophage", "Antigen"]
        ),
        .init(
            name: "Neurology", icon: "brain.head.profile", tint: .pink, progress: 0.22,
            concepts: 84, questions: 210, flashcards: 620,
            description: "Study of the nervous system and its disorders.",
            masteredConcepts: 18, timeStudied: "2h 50m",
            topics: [],
            recommendedTopic: "Cranial Nerves",
            relatedConcepts: ["Synapse", "Neuron", "Axon"]
        ),
        .init(
            name: "Pulmonology", icon: "lungs.fill", tint: .cyan, progress: 0.58,
            concepts: 96, questions: 250, flashcards: 720,
            description: "Study of the respiratory system and its disorders.",
            masteredConcepts: 56, timeStudied: "6h 18m",
            topics: [],
            recommendedTopic: "Gas Exchange",
            relatedConcepts: ["Alveoli", "Bronchi", "Diaphragm"]
        )
    ]
}
