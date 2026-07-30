//
//  HistoryView.swift
//  personalized-medical-learning-ios
//

import SwiftUI

struct HistoryView: View {
    var onBack: () -> Void = {}

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header

                VStack(alignment: .leading, spacing: 20) {
                    ForEach(HistoryData.sections) { section in
                        HistorySectionView(section: section)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .background(Theme.bg)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("History").font(.largeTitle.bold())
            Text("Your past quiz attempts and flashcard sessions.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 24)
    }
}

private struct HistorySectionView: View {
    let section: HistorySection

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(section.title).font(.headline)

            VStack(spacing: 12) {
                ForEach(section.entries) { entry in
                    HistoryRow(entry: entry)
                }
            }
        }
    }
}

private struct HistoryRow: View {
    let entry: HistoryEntry

    private var accuracyColor: Color {
        if entry.accuracy >= 80 { return .green }
        if entry.accuracy >= 60 { return .orange }
        return .red
    }

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(entry.tint.opacity(0.12))
                    .frame(width: 48, height: 48)
                Image(systemName: entry.type.icon)
                    .font(.title3)
                    .foregroundStyle(entry.tint)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("\(entry.subject) · \(entry.type.label)")
                    .font(.subheadline.weight(.semibold))
                Text("\(entry.questionCount) questions · \(entry.duration)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)

            VStack(alignment: .trailing, spacing: 4) {
                Text("\(entry.accuracy)%")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(accuracyColor)
                Text(entry.timeLabel)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

#Preview {
    RootView()
}
