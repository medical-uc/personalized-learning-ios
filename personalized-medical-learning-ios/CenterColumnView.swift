//
//  CenterColumnView.swift
//  personalized-medical-learning-ios
//

import SwiftUI

struct CenterColumnView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            DayStreakCard()
            StatisticsSection()
            UpcomingQuizzesSection()
        }
    }
}

private struct DayStreakCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "flame.fill").foregroundStyle(.orange)
                Text("Day Streak").font(.headline)
            }

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("12").font(.system(size: 40, weight: .bold))
                    Text("days").font(.subheadline).foregroundStyle(.secondary)
                }

                Spacer()

                HStack(spacing: 14) {
                    ForEach(Array(zip(DashboardData.weekDays.indices, DashboardData.weekDays)), id: \.0) { index, day in
                        VStack(spacing: 8) {
                            Text(day).font(.caption2).foregroundStyle(.secondary)
                            ZStack {
                                Circle()
                                    .fill(DashboardData.streakChecked[index] ? Theme.dark : Color.white)
                                    .overlay(Circle().stroke(Theme.dark.opacity(index == 4 ? 1 : 0), lineWidth: 2))
                                    .frame(width: 32, height: 32)
                                if DashboardData.streakChecked[index] {
                                    Image(systemName: "checkmark")
                                        .font(.caption2.weight(.bold))
                                        .foregroundStyle(.white)
                                }
                            }
                        }
                    }
                }
            }

            Text("Keep it up! You're doing great!")
                .font(.caption)
                .foregroundStyle(.secondary)

            Divider()
        }
        .padding(18)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

private struct StatisticsSection: View {
    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Your Statistics").font(.headline)
                Spacer()
                HStack(spacing: 4) {
                    Text("This Week").font(.caption.weight(.medium))
                    Image(systemName: "chevron.down").font(.caption2)
                }
                .foregroundStyle(.secondary)
            }

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(DashboardData.stats) { stat in
                    VStack(alignment: .leading, spacing: 10) {
                        ZStack {
                            Circle().fill(stat.tint.opacity(0.15)).frame(width: 36, height: 36)
                            Image(systemName: stat.icon).font(.subheadline).foregroundStyle(stat.tint)
                        }
                        Text(stat.value).font(.title3.bold())
                        Text(stat.label).font(.caption2).foregroundStyle(.secondary)
                        Text(stat.delta).font(.caption2.weight(.medium)).foregroundStyle(.green)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
        }
    }
}

private struct UpcomingQuizzesSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Upcoming Quizzes")

            VStack(spacing: 10) {
                ForEach(DashboardData.upcomingQuizzes) { quiz in
                    UpcomingQuizRow(quiz: quiz)
                }
            }
            .padding(16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 18))

            Button {} label: {
                HStack(spacing: 4) {
                    Text("View More").font(.subheadline.weight(.medium))
                    Image(systemName: "chevron.down").font(.caption)
                }
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            }
        }
    }
}

private struct UpcomingQuizRow: View {
    let quiz: UpcomingQuiz

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(quiz.avatarTint.opacity(0.25))
                .frame(width: 40, height: 40)
                .overlay(Text(quiz.initial).font(.subheadline.bold()).foregroundStyle(Theme.dark))

            VStack(alignment: .leading, spacing: 2) {
                Text(quiz.name).font(.subheadline.bold())
                Text(quiz.room).font(.caption2).foregroundStyle(.secondary)
            }
            .frame(width: 150, alignment: .leading)

            VStack(alignment: .leading, spacing: 2) {
                Text(quiz.medication).font(.subheadline.weight(.medium))
                Text(quiz.detail).font(.caption2).foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Text(quiz.status.rawValue)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(quiz.status.color)
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
                .overlay(Capsule().stroke(quiz.status.color.opacity(0.4)))

            Button {} label: {
                Text("Start")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 9)
                    .background(Theme.dark)
                    .clipShape(Capsule())
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    ScrollView { CenterColumnView().padding() }
        .background(Theme.bg)
}
