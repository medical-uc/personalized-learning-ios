//
//  DashboardModels.swift
//  personalized-medical-learning-ios
//

import SwiftUI

enum SidebarItem: String, CaseIterable, Identifiable {
    case dashboard = "Dashboard"
    case quiz = "Quiz"
    case subjects = "Subjects"
    case flashcards = "Flashcards"
    case bookmarks = "Bookmarks"
    case history = "History"
    case mastery = "Knowledge Level"
    case settings = "Settings"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .dashboard: return "house.fill"
        case .quiz: return "questionmark.circle"
        case .subjects: return "book"
        case .flashcards: return "rectangle.stack"
        case .bookmarks: return "bookmark"
        case .history: return "clock"
        case .mastery: return "chart.bar.fill"
        case .settings: return "gearshape"
        }
    }
}

enum DashboardData {
    static let weekDays = ["M", "T", "W", "T", "F", "S", "S"]
}

enum Theme {
    static let dark = Color(red: 0.11, green: 0.18, blue: 0.18)
    static let bg = Color(red: 0.96, green: 0.97, blue: 0.97)
    static let card = Color.white
    static let mint = Color(red: 0.86, green: 0.92, blue: 0.90)
}

/// Ordinal read of a 0...1 BKT pKnow value, replacing raw percentages in the UI.
/// Shared thresholds so a topic reads the same tier everywhere it appears
/// (Knowledge Level, Dashboard Focus Areas, Subjects, Quiz Setup).
enum MasteryLevel: String {
    case strong = "Strong"
    case developing = "Developing"
    case needsWork = "Needs Work"

    init(pKnow: Double) {
        if pKnow > 0.70 { self = .strong }
        else if pKnow >= 0.50 { self = .developing }
        else { self = .needsWork }
    }

    var label: String { rawValue }

    var tint: Color {
        switch self {
        case .strong: return .green
        case .developing: return .yellow
        case .needsWork: return .red
        }
    }
}
