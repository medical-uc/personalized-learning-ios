//
//  DashboardView.swift
//  personalized-medical-learning-ios
//

import SwiftUI

struct DashboardView: View {
    var onPracticeTopic: (QuizTopic) -> Void = { _ in }
    var onViewAllWeakAreas: () -> Void = {}

    @StateObject private var streakViewModel = StreakViewModel()
    @StateObject private var nudgeViewModel = NudgeViewModel()
    @State private var showBrokenStreakSheet = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                TopBarView()

                if nudgeViewModel.totalDueCount > 0 {
                    DueForReviewCard(
                        quizDueCount: nudgeViewModel.quizDueCount,
                        flashcardDueCount: nudgeViewModel.flashcardDueCount,
                        totalDueCount: nudgeViewModel.totalDueCount
                    )
                }

                DashboardTopCardsLayout {
                    DayStreakCard(
                        currentStreak: streakViewModel.currentStreak,
                        weekActivity: streakViewModel.weekActivity,
                        brokenStreakLength: streakViewModel.brokenStreakLength
                    )
                } focusAreas: {
                    FocusAreasCard(onPracticeTopic: onPracticeTopic, onViewAll: onViewAllWeakAreas)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .background(Theme.bg)
        .task {
            await streakViewModel.loadStreak()
            await nudgeViewModel.loadNudge()
            if streakViewModel.brokenStreakLength != nil {
                showBrokenStreakSheet = true
            }
        }
        .sheet(isPresented: $showBrokenStreakSheet) {
            if let brokenStreakLength = streakViewModel.brokenStreakLength {
                StreakBrokenView(streakLength: brokenStreakLength)
            }
        }
    }
}

private struct StreakBrokenView: View {
    let streakLength: Int
    @Environment(\.dismiss) private var dismiss

    private var dayWord: String { streakLength == 1 ? "day" : "days" }

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle().fill(Color.orange.opacity(0.12)).frame(width: 88, height: 88)
                Image(systemName: "flame.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(Color.orange)
            }
            .padding(.top, 8)

            VStack(spacing: 8) {
                Text("Streak broken")
                    .font(.title2.bold())
                    .foregroundStyle(Theme.dark)
                Text("Your \(streakLength)-\(dayWord) streak ended. Answer a quiz question or review a flashcard today to start a new one.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Button(action: { dismiss() }) {
                Text("Got it")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Theme.dark)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)
        }
        .padding(24)
        .presentationDetents([.height(320)])
    }
}

/// Side-by-side on wide screens, stacked on narrow — a single Layout instead of
/// ViewThatFits so each card is instantiated exactly once. ViewThatFits duplicates its
/// child views to measure every branch, which double-created FocusAreasCard (and its
/// Practice Now closures) and made taps land on a stale, already-discarded instance.
private struct DashboardTopCardsLayout<DayStreak: View, FocusAreas: View>: View {
    @ViewBuilder let dayStreak: DayStreak
    @ViewBuilder let focusAreas: FocusAreas

    init(@ViewBuilder dayStreak: () -> DayStreak, @ViewBuilder focusAreas: () -> FocusAreas) {
        self.dayStreak = dayStreak()
        self.focusAreas = focusAreas()
    }

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .top, spacing: 20) {
                dayStreak.frame(maxWidth: .infinity)
                focusAreas.frame(maxWidth: .infinity)
            }
            VStack(alignment: .leading, spacing: 20) {
                dayStreak
                focusAreas
            }
        }
    }
}

private struct DueForReviewCard: View {
    let quizDueCount: Int
    let flashcardDueCount: Int
    let totalDueCount: Int

    private var subtitle: String {
        var parts: [String] = []
        if quizDueCount > 0 { parts.append("\(quizDueCount) quiz question\(quizDueCount == 1 ? "" : "s")") }
        if flashcardDueCount > 0 { parts.append("\(flashcardDueCount) flashcard\(flashcardDueCount == 1 ? "" : "s")") }
        return parts.joined(separator: " and ") + " due for review."
    }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: "arrow.clockwise")
                    .foregroundStyle(.orange)
                    .font(.system(size: 18, weight: .semibold))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("\(totalDueCount) due for review")
                    .font(.subheadline.weight(.semibold))
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 8)
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

private struct DayStreakCard: View {
    let currentStreak: Int
    let weekActivity: [Bool]
    var brokenStreakLength: Int? = nil

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

            if let brokenStreakLength, currentStreak == 0 {
                HStack(spacing: 6) {
                    Image(systemName: "flame.slash.fill")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                    Text("Your \(brokenStreakLength)-day streak ended. Start a new one today.")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            } else {
                Text(currentStreak > 0 ? "Keep it up! You're doing great!" : "Answer a quiz question or review a flashcard today to start a streak.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
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
    var onPracticeTopic: (QuizTopic) -> Void
    var onViewAll: () -> Void

    /// Below-mastery topics only (< 70%) — matches the quiz setup recommendation bar,
    /// so this card and "Recommended for You" always agree on what still needs work.
    private var entries: [MasteryEntry] {
        Array(BKTStore.allEntries().filter { $0.percent < 70 }.prefix(3))
    }

    var body: some View {
        if !entries.isEmpty {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Areas to Improve").font(.headline)
                        Text("Topics that need more attention")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Button(action: onViewAll) {
                        Text("View All")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(Theme.dark)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Theme.bg)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                }

                VStack(spacing: 10) {
                    ForEach(entries) { entry in
                        FocusAreaRow(entry: entry) {
                            onPracticeTopic(QuizTopic(
                                path: entry.topicPath,
                                subject: entry.subjectName,
                                name: entry.topicName,
                                icon: entry.subjectIcon,
                                tint: entry.subjectIconTint
                            ))
                        }
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
    var onPractice: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle().fill(entry.subjectIconTint.opacity(0.15)).frame(width: 44, height: 44)
                Image(systemName: entry.subjectIcon).foregroundStyle(entry.subjectIconTint)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(entry.topicName)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                Text(entry.subjectName)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Text(entry.statusLabel)
                .font(.caption.weight(.semibold))
                .foregroundStyle(entry.tint)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(entry.tint.opacity(0.12))
                .clipShape(Capsule())

            Button(action: onPractice) {
                Text("Practice Now")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.dark)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Theme.bg)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(Theme.bg.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 14))
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

#Preview("Streak Broken") {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            StreakBrokenView(streakLength: 12)
        }
}
