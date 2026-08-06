//
//  DashboardView.swift
//  personalized-medical-learning-ios
//

import SwiftUI

struct DashboardView: View {
    @StateObject private var streakViewModel = StreakViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                TopBarView()

                ViewThatFits(in: .horizontal) {
                    HStack(alignment: .top, spacing: 20) {
                        DayStreakCard(currentStreak: streakViewModel.currentStreak, weekActivity: streakViewModel.weekActivity)
                            .frame(maxWidth: .infinity)
                        FocusAreasCard()
                            .frame(maxWidth: .infinity)
                    }

                    VStack(alignment: .leading, spacing: 20) {
                        DayStreakCard(currentStreak: streakViewModel.currentStreak, weekActivity: streakViewModel.weekActivity)
                        FocusAreasCard()
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .background(Theme.bg)
        .task {
            await streakViewModel.loadStreak()
        }
    }
}

private struct DayStreakCard: View {
    let currentStreak: Int
    let weekActivity: [Bool]

    /// Index of today within the Monday-first week row, so it can be ringed like the
    /// old static mock did — weekActivity[weekday] is guaranteed populated by the
    /// backend (see src/student_kg/streak.py::week_activity), Sunday = index 6.
    private var todayIndex: Int {
        (Calendar(identifier: .iso8601).component(.weekday, from: Date()) + 5) % 7
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "flame.fill").foregroundStyle(.orange)
                Text("Day Streak").font(.headline)
            }

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("\(currentStreak)").font(.system(size: 40, weight: .bold))
                    Text("days").font(.subheadline).foregroundStyle(.secondary)
                }

                Spacer()

                HStack(spacing: 14) {
                    ForEach(Array(zip(DashboardData.weekDays.indices, DashboardData.weekDays)), id: \.0) { index, day in
                        VStack(spacing: 8) {
                            Text(day).font(.caption2).foregroundStyle(.secondary)
                            ZStack {
                                Circle()
                                    .fill(isChecked(index) ? Theme.dark : Color.white)
                                    .overlay(Circle().stroke(Theme.dark.opacity(index == todayIndex ? 1 : 0), lineWidth: 2))
                                    .frame(width: 32, height: 32)
                                if isChecked(index) {
                                    Image(systemName: "checkmark")
                                        .font(.caption2.weight(.bold))
                                        .foregroundStyle(.white)
                                }
                            }
                        }
                    }
                }
            }

            Text(currentStreak > 0 ? "Keep it up! You're doing great!" : "Answer a quiz question or review a flashcard today to start a streak.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(18)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private func isChecked(_ index: Int) -> Bool {
        index < weekActivity.count && weekActivity[index]
    }
}

private struct FocusAreasCard: View {
    /// Below-mastery topics only (< 70%) — matches the quiz setup recommendation bar,
    /// so this card and "Recommended for You" always agree on what still needs work.
    private var entries: [MasteryEntry] {
        Array(BKTStore.allEntries().filter { $0.percent < 70 }.prefix(3))
    }

    var body: some View {
        if !entries.isEmpty {
            VStack(alignment: .leading, spacing: 14) {
                SectionHeader(title: "Focus Areas")

                VStack(spacing: 10) {
                    ForEach(entries) { entry in
                        FocusAreaRow(entry: entry)
                    }
                }
            }
            .padding(16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
    }
}

private struct FocusAreaRow: View {
    let entry: MasteryEntry

    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.topicName)
                    .font(.caption.weight(.semibold))
                    .lineLimit(1)
                Text(entry.subjectName)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            Text("\(entry.percent)%")
                .font(.caption.weight(.semibold))
                .foregroundStyle(entry.tint)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(entry.tint.opacity(0.12))
                .clipShape(Capsule())
        }
    }
}

struct SectionHeader: View {
    let title: String
    var actionTitle: String = "View All"

    var body: some View {
        HStack {
            Text(title).font(.headline)
            Spacer()
            HStack(spacing: 2) {
                Text(actionTitle).font(.caption.weight(.medium))
            }
            .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    RootView()
}
