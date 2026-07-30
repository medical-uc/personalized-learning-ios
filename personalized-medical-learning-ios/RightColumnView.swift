//
//  RightColumnView.swift
//  personalized-medical-learning-ios
//

import SwiftUI

struct RightColumnView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            TopPerformersCard()
            QuickActionsCard()
            OnFireCard()
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
