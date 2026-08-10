//
//  HistoryModels.swift
//  personalized-medical-learning-ios
//

import SwiftUI

struct HistoryItem: Decodable {
    let sessionId: String
    let topicPath: String
    let questionCount: Int
    let correctCount: Int
    let scorePercent: Int
    let durationSeconds: Int
    let startedAt: Date
    let endedAt: Date

    enum CodingKeys: String, CodingKey {
        case sessionId = "session_id"
        case topicPath = "topic_path"
        case questionCount = "question_count"
        case correctCount = "correct_count"
        case scorePercent = "score_percent"
        case durationSeconds = "duration_seconds"
        case startedAt = "started_at"
        case endedAt = "ended_at"
    }
}

struct HistoryListResponse: Decodable {
    let items: [HistoryItem]
}

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

struct HistorySection<Entry: Identifiable>: Identifiable {
    let id: String
    let title: String
    let entries: [Entry]
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

struct FlashcardHistoryEntry: Identifiable {
    let id: String
    let front: String
    let topicPath: String
    let rating: FlashcardRating
    let ts: Date
    let timeLabel: String

    init(item: FlashcardHistoryItem) {
        self.id = item.eventId
        self.front = item.front
        self.topicPath = item.topicPath
        self.rating = item.rating
        self.ts = item.ts
        self.timeLabel = Self.timeLabelText(date: item.ts)
    }

    private static func timeLabelText(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

extension FlashcardRating {
    var tint: Color {
        switch self {
        case .again: return .red
        case .hard: return .orange
        case .good: return .blue
        case .easy: return .green
        }
    }

    var label: String {
        switch self {
        case .again: return "Again"
        case .hard: return "Hard"
        case .good: return "Good"
        case .easy: return "Easy"
        }
    }
}

enum HistoryGrouping {
    static func dayTitle(for date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) { return "Today" }
        if calendar.isDateInYesterday(date) { return "Yesterday" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: date)
    }

    static func sections<Entry: Identifiable>(
        from entries: [Entry],
        date: (Entry) -> Date
    ) -> [HistorySection<Entry>] {
        let calendar = Calendar.current
        let sorted = entries.sorted { date($0) > date($1) }

        var order: [Date] = []
        var buckets: [Date: [Entry]] = [:]

        for entry in sorted {
            let day = calendar.startOfDay(for: date(entry))
            if buckets[day] == nil {
                buckets[day] = []
                order.append(day)
            }
            buckets[day]?.append(entry)
        }

        return order.map { day in
            HistorySection(
                id: ISO8601DateFormatter().string(from: day),
                title: dayTitle(for: day),
                entries: buckets[day] ?? []
            )
        }
    }

    static func sections(from items: [HistoryItem]) -> [HistorySection<HistoryEntry>] {
        sections(from: items.map(HistoryEntry.init(item:)), date: \.startedAt)
    }

    static func sections(from items: [FlashcardHistoryItem]) -> [HistorySection<FlashcardHistoryEntry>] {
        sections(from: items.map(FlashcardHistoryEntry.init(item:)), date: \.ts)
    }
}
