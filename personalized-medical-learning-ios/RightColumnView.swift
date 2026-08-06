//
//  RightColumnView.swift
//  personalized-medical-learning-ios
//

import SwiftUI

struct RightColumnView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if !WeakTopicsCard.entries.isEmpty {
                WeakTopicsCard()
            }
            TopPerformersCard()
            QuickActionsCard()
            OnFireCard()
        }
    }
}

private struct WeakTopicsCard: View {
    /// Below-mastery topics only (< 70%) — matches the quiz setup recommendation bar,
    /// so this card and "Recommended for You" always agree on what still needs work.
    static var entries: [MasteryEntry] {
        Array(BKTStore.allEntries().filter { $0.percent < 70 }.prefix(3))
    }
    private var entries: [MasteryEntry] { Self.entries }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "Focus Areas")

            VStack(spacing: 10) {
                ForEach(entries) { entry in
                    WeakTopicRow(entry: entry)
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

private struct WeakTopicRow: View {
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

private struct TopPerformersCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "Top Performers")

            VStack(spacing: 14) {
                ForEach(DashboardData.performers) { performer in
                    PerformerRow(performer: performer)
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

private struct PerformerRow: View {
    let performer: Performer

    var rankColor: Color {
        switch performer.rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .brown
        default: return .clear
        }
    }

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                if performer.rank <= 3 {
                    Image(systemName: "crown.fill")
                        .font(.caption2)
                        .foregroundStyle(rankColor)
                } else {
                    Text("\(performer.rank)")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 18)

            Circle()
                .fill(Theme.mint)
                .frame(width: 38, height: 38)
                .overlay(Image(systemName: "person.fill").font(.caption).foregroundStyle(Theme.dark))

            VStack(alignment: .leading, spacing: 2) {
                Text(performer.name).font(.subheadline.weight(.semibold))
                Text("\(performer.xp) XP").font(.caption2).foregroundStyle(.secondary)
            }

            Spacer()

            if performer.isCurrentUser {
                Text("You")
                    .font(.caption2.weight(.medium))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Theme.bg)
                    .clipShape(Capsule())
            }
        }
    }
}

private struct QuickActionsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Quick Actions").font(.headline)

            VStack(spacing: 10) {
                ForEach(DashboardData.quickActions) { action in
                    HStack(spacing: 12) {
                        Image(systemName: action.icon)
                            .foregroundStyle(Theme.dark)
                            .frame(width: 20)
                        Text(action.title).font(.subheadline.weight(.medium))
                        Spacer()
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Theme.bg)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

private struct OnFireCard: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("You're on fire!").font(.subheadline.bold())
                Text("Keep challenging yourself every day.")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "trophy.fill")
                .font(.largeTitle)
                .foregroundStyle(Theme.dark.opacity(0.6))
        }
        .padding(16)
        .background(Theme.mint)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

#Preview {
    ScrollView { RightColumnView().padding() }
        .background(Theme.bg)
}
