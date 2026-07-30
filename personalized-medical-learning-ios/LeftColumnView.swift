//
//  LeftColumnView.swift
//  personalized-medical-learning-ios
//

import SwiftUI

struct LeftColumnView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            DailyTaskCard()
            QuickQuizSection()
            PracticeMoreSection()
        }
    }
}

private struct DailyTaskCard: View {
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Theme.bg)
                    .frame(width: 56, height: 56)
                Image(systemName: "anchor")
                    .font(.title2)
                    .foregroundStyle(Theme.dark)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Daily Task").font(.subheadline.bold())
                Text("14 Questions").font(.caption).foregroundStyle(.secondary)

                HStack(spacing: 8) {
                    ProgressView(value: 9, total: 14)
                        .tint(Theme.dark)
                    Text("9/14").font(.caption2).foregroundStyle(.secondary)
                }
                Text("Progress").font(.caption2).foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 28, height: 28)
                .background(Theme.bg)
                .clipShape(Circle())
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

private struct QuickQuizSection: View {
    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Quick Quiz")

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(DashboardData.quickQuizTopics) { topic in
                    VStack(spacing: 10) {
                        ZStack {
                            Circle().fill(topic.tint.opacity(0.15)).frame(width: 44, height: 44)
                            Image(systemName: topic.icon).foregroundStyle(topic.tint)
                        }
                        Text(topic.name).font(.caption.weight(.medium))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
        }
    }
}

private struct PracticeMoreSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Practice More")

            HStack(spacing: 12) {
                PracticeCard(icon: "doc.text.fill", title: "Topic Quiz", subtitle: "10-15 Questions")
                PracticeCard(icon: "list.clipboard.fill", title: "Exam Simulation", subtitle: "50 Questions")
            }
        }
    }
}

private struct PracticeCard: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(Theme.dark)
            Text(title).font(.subheadline.bold())
            Text(subtitle).font(.caption2).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Theme.bg)
        .clipShape(RoundedRectangle(cornerRadius: 16))
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
    ScrollView { LeftColumnView().padding() }
        .background(Theme.bg)
}
