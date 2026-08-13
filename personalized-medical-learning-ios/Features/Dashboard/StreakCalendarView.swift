//
//  StreakCalendarView.swift
//  personalized-medical-learning-ios
//

import SwiftUI

/// Month calendar view of streak activity. activityDates comes straight from
/// StreakViewModel (backend's StreakResponse.activity_dates) — full history, already
/// fetched by the time DashboardView presents this, so no separate loading here.
struct StreakCalendarView: View {
    let currentStreak: Int
    let activityDates: Set<Date>

    @State private var visibleMonth: Date = Calendar.current.startOfDay(for: Date())
    @State private var selectedDay: Date?

    private var calendar: Calendar { Calendar.current }

    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: visibleMonth)
    }

    /// Leading nils pad the grid so day 1 lands under the correct weekday column.
    private var daysInMonth: [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: visibleMonth),
              let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: visibleMonth))
        else { return [] }

        let firstWeekday = calendar.component(.weekday, from: firstOfMonth)
        let leadingBlanks = (firstWeekday - calendar.firstWeekday + 7) % 7

        let days = range.compactMap { day in
            calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth)
        }
        return Array(repeating: nil, count: leadingBlanks) + days
    }

    private var canGoToNextMonth: Bool {
        guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: visibleMonth) else { return false }
        return nextMonth <= Date()
    }

    private func hasActivity(_ day: Date) -> Bool {
        activityDates.contains(calendar.startOfDay(for: day))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    streakSummary
                    monthNavigator
                    weekdayHeader
                    monthGrid

                    if let selectedDay {
                        DaySelectionDetail(day: selectedDay, hasActivity: hasActivity(selectedDay))
                    }
                }
                .padding(20)
            }
            .background(Theme.bg)
            .navigationTitle("Activity Calendar")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var streakSummary: some View {
        HStack(spacing: 10) {
            Image(systemName: "flame.fill").foregroundStyle(.orange)
            Text("\(currentStreak)-day streak")
                .font(.headline)
            Spacer()
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var monthNavigator: some View {
        HStack {
            Button {
                if let prev = calendar.date(byAdding: .month, value: -1, to: visibleMonth) {
                    visibleMonth = prev
                    selectedDay = nil
                }
            } label: {
                Image(systemName: "chevron.left")
                    .frame(width: 32, height: 32)
                    .background(Color.white)
                    .clipShape(Circle())
            }

            Spacer()

            Text(monthTitle)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.dark)

            Spacer()

            Button {
                if let next = calendar.date(byAdding: .month, value: 1, to: visibleMonth) {
                    visibleMonth = next
                    selectedDay = nil
                }
            } label: {
                Image(systemName: "chevron.right")
                    .frame(width: 32, height: 32)
                    .background(Color.white)
                    .clipShape(Circle())
            }
            .disabled(!canGoToNextMonth)
            .opacity(canGoToNextMonth ? 1 : 0.35)
        }
        .foregroundStyle(Theme.dark)
    }

    private var weekdayHeader: some View {
        let symbols = calendar.veryShortStandaloneWeekdaySymbols
        let ordered = Array(symbols[(calendar.firstWeekday - 1)...] + symbols[..<(calendar.firstWeekday - 1)])
        return HStack(spacing: 0) {
            ForEach(Array(ordered.enumerated()), id: \.offset) { _, symbol in
                Text(symbol)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var monthGrid: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
        return LazyVGrid(columns: columns, spacing: 8) {
            ForEach(Array(daysInMonth.enumerated()), id: \.offset) { _, day in
                if let day {
                    DayCell(
                        day: day,
                        hasActivity: hasActivity(day),
                        isToday: calendar.isDateInToday(day),
                        isFuture: day > Date(),
                        isSelected: selectedDay.map { calendar.isDate($0, inSameDayAs: day) } ?? false
                    )
                    .onTapGesture {
                        guard day <= Date() else { return }
                        selectedDay = calendar.isDate(selectedDay ?? .distantPast, inSameDayAs: day) ? nil : day
                    }
                } else {
                    Color.clear.frame(height: 40)
                }
            }
        }
    }
}

private struct DayCell: View {
    let day: Date
    let hasActivity: Bool
    let isToday: Bool
    let isFuture: Bool
    let isSelected: Bool

    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: day)
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(hasActivity ? Color.orange : Color.white)
                .overlay(Circle().stroke(isSelected ? Theme.dark : Color.clear, lineWidth: 2))
                .overlay(Circle().stroke(isToday && !hasActivity ? Theme.dark.opacity(0.4) : Color.clear, lineWidth: 1.5))

            Text(dayNumber)
                .font(.caption.weight(isToday ? .bold : .regular))
                .foregroundStyle(hasActivity ? .white : (isFuture ? .secondary.opacity(0.4) : Theme.dark))

            if hasActivity {
                Image(systemName: "flame.fill")
                    .font(.system(size: 9))
                    .foregroundStyle(.white)
                    .padding(3)
                    .background(Circle().fill(Color.orange).overlay(Circle().stroke(Color.white, lineWidth: 1)))
                    .offset(x: 12, y: -12)
            }
        }
        .frame(height: 40)
        .opacity(isFuture ? 0.5 : 1)
    }
}

private struct DaySelectionDetail: View {
    let day: Date
    let hasActivity: Bool

    private var dateLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: day)
    }

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: hasActivity ? "flame.fill" : "circle")
                .foregroundStyle(hasActivity ? .orange : .secondary)
            VStack(alignment: .leading, spacing: 2) {
                Text(dateLabel)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.dark)
                Text(hasActivity ? "You were active this day." : "No activity this day.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    RootView()
}
