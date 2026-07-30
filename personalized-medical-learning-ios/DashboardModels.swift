//
//  DashboardModels.swift
//  personalized-medical-learning-ios
//

import SwiftUI

enum SidebarItem: String, CaseIterable, Identifiable {
    case dashboard = "Dashboard"
    case dailyTask = "Daily Task"
    case quiz = "Quiz"
    case subjects = "Subjects"
    case flashcards = "Flashcards"
    case practice = "Practice"
    case leaderboard = "Leaderboard"
    case bookmarks = "Bookmarks"
    case history = "History"
    case settings = "Settings"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .dashboard: return "house.fill"
        case .dailyTask: return "calendar"
        case .quiz: return "questionmark.circle"
        case .subjects: return "book"
        case .flashcards: return "rectangle.stack"
        case .practice: return "doc.text"
        case .leaderboard: return "trophy"
        case .bookmarks: return "bookmark"
        case .history: return "clock"
        case .settings: return "gearshape"
        }
    }
}

struct QuickQuizTopic: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let tint: Color
}

struct StatItem: Identifiable {
    let id = UUID()
    let icon: String
    let tint: Color
    let value: String
    let label: String
    let delta: String
}

enum QuizStatus: String {
    case expired, soon, scheduled

    var color: Color {
        switch self {
        case .expired: return .red
        case .soon: return .orange
        case .scheduled: return .secondary
        }
    }
}

struct UpcomingQuiz: Identifiable {
    let id = UUID()
    let initial: String
    let avatarTint: Color
    let name: String
    let room: String
    let medication: String
    let detail: String
    let status: QuizStatus
}

struct Performer: Identifiable {
    let id = UUID()
    let rank: Int
    let name: String
    let xp: Int
    let isCurrentUser: Bool
}

struct QuickAction: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
}

enum DashboardData {
    static let quickQuizTopics: [QuickQuizTopic] = [
        .init(name: "Anatomy", icon: "heart.fill", tint: .red),
        .init(name: "Pharmacology", icon: "pills.fill", tint: .teal),
        .init(name: "Microbiology", icon: "microscope", tint: .gray),
        .init(name: "Pathology", icon: "circle.grid.3x3.fill", tint: .purple),
        .init(name: "Physiology", icon: "lungs.fill", tint: .pink),
        .init(name: "Surgery", icon: "scalpel", tint: .blue)
    ]

    static let stats: [StatItem] = [
        .init(icon: "checkmark.square", tint: .green, value: "24", label: "Questions Answered", delta: "↑ 15%"),
        .init(icon: "heart.text.square", tint: .red, value: "18", label: "Correct Answers", delta: "↑ 12%"),
        .init(icon: "clock", tint: .orange, value: "75%", label: "Accuracy Rate", delta: "↑ 8%"),
        .init(icon: "arrow.triangle.2.circlepath", tint: .blue, value: "2h 45m", label: "Study Time", delta: "↑ 20m")
    ]

    static let upcomingQuizzes: [UpcomingQuiz] = [
        .init(initial: "K", avatarTint: .green, name: "Kovalenko Oleg", room: "Room No. 156", medication: "Metformin", detail: "500 ml · 🕐 8:00", status: .expired),
        .init(initial: "B", avatarTint: .yellow, name: "Bondarenko Lina", room: "Room No. 46", medication: "Alvedon", detail: "250 ml · 🕐 10:00", status: .soon),
        .init(initial: "P", avatarTint: .blue, name: "Petrenko Nazar", room: "Room No. 234", medication: "Smecta", detail: "1 piece · 🕐 12:00", status: .scheduled),
        .init(initial: "M", avatarTint: .purple, name: "Markiv Dmytro", room: "Room No. 156", medication: "Omeprazole", detail: "80 ml · 🕐 1:00 PM", status: .scheduled)
    ]

    static let performers: [Performer] = [
        .init(rank: 1, name: "Roxane Harley", xp: 4320, isCurrentUser: true),
        .init(rank: 2, name: "Dina Danchenko", xp: 3890, isCurrentUser: false),
        .init(rank: 3, name: "Oleg Kovalenko", xp: 3580, isCurrentUser: false),
        .init(rank: 4, name: "Lina Bondarenko", xp: 3200, isCurrentUser: false),
        .init(rank: 5, name: "Nazar Petrenko", xp: 2980, isCurrentUser: false)
    ]

    static let quickActions: [QuickAction] = [
        .init(icon: "viewfinder", title: "Scan Patient"),
        .init(icon: "viewfinder", title: "Scan Medication"),
        .init(icon: "doc.text", title: "Request Medication"),
        .init(icon: "bubble.left", title: "Report an Issue")
    ]

    static let weekDays = ["M", "T", "W", "T", "F", "S", "S"]
    static let streakChecked = [true, true, true, true, true, true, false]
}

enum Theme {
    static let dark = Color(red: 0.11, green: 0.18, blue: 0.18)
    static let bg = Color(red: 0.96, green: 0.97, blue: 0.97)
    static let card = Color.white
    static let mint = Color(red: 0.86, green: 0.92, blue: 0.90)
}
