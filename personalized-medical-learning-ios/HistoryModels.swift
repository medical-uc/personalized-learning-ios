//
//  HistoryModels.swift
//  personalized-medical-learning-ios
//

import SwiftUI

struct HistoryEntry: Identifiable {
    let id: String
    let subject: String
    let tint: Color
    let questionCount: Int
    let accuracy: Int
    let duration: String
    let timeLabel: String
    let startedAt: Date
}

struct HistorySection: Identifiable {
    let id: String
    let title: String
    let entries: [HistoryEntry]
}

private let historyTints: [Color] = [.red, .orange, .pink, .blue, .teal, .purple, .green, .indigo]

extension HistoryEntry {
    init(item: HistoryItem) {
        self.id = item.sessionId
        self.subject = item.topicPath.capitalized
        self.tint = historyTints[abs(item.topicPath.hashValue) % historyTints.count]
        self.questionCount = item.questionCount
        self.accuracy = item.scorePercent
        self.duration = HistoryEntry.durationText(seconds: item.durationSeconds)
        self.timeLabel = HistoryEntry.timeLabelText(date: item.startedAt)
        self.startedAt = item.startedAt
    }

    private static func durationText(seconds: Int) -> String {
        let minutes = max(1, seconds / 60)
        return "\(minutes)m"
    }

    private static func timeLabelText(date: Date) -> String {
        let formatter = DateFormatter()
        if Calendar.current.isDateInToday(date) || Calendar.current.isDateInYesterday(date) {
            formatter.dateFormat = "h:mm a"
        } else {
            formatter.dateFormat = "EEE, h:mm a"
        }
        return formatter.string(from: date)
    }
}

enum HistoryGrouping {
    static func sections(from items: [HistoryItem]) -> [HistorySection] {
        let calendar = Calendar.current
        let now = Date()

        var today: [HistoryEntry] = []
        var yesterday: [HistoryEntry] = []
        var thisWeek: [HistoryEntry] = []
        var older: [HistoryEntry] = []

        for item in items.sorted(by: { $0.startedAt > $1.startedAt }) {
            let entry = HistoryEntry(item: item)
            if calendar.isDateInToday(item.startedAt) {
                today.append(entry)
            } else if calendar.isDateInYesterday(item.startedAt) {
                yesterday.append(entry)
            } else if let weekAgo = calendar.date(byAdding: .day, value: -7, to: now), item.startedAt >= weekAgo {
                thisWeek.append(entry)
            } else {
                older.append(entry)
            }
        }

        var sections: [HistorySection] = []
        if !today.isEmpty { sections.append(.init(id: "today", title: "Today", entries: today)) }
        if !yesterday.isEmpty { sections.append(.init(id: "yesterday", title: "Yesterday", entries: yesterday)) }
        if !thisWeek.isEmpty { sections.append(.init(id: "thisWeek", title: "This Week", entries: thisWeek)) }
        if !older.isEmpty { sections.append(.init(id: "older", title: "Older", entries: older)) }
        return sections
    }
}
