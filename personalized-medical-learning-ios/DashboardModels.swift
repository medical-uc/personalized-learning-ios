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
    case mastery = "Mastery"
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
