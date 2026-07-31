//
//  HistoryView.swift
//  personalized-medical-learning-ios
//

import SwiftUI

struct HistoryView: View {
    var onBack: () -> Void = {}

    @StateObject private var viewModel = HistoryViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header

                if viewModel.isLoading {
                    ProgressView("Loading history…")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 60)
                } else if let errorMessage = viewModel.errorMessage, viewModel.sections.isEmpty {
                    HistoryErrorView(message: errorMessage) {
                        Task { await viewModel.loadHistory() }
                    }
                } else if viewModel.sections.isEmpty {
                    HistoryEmptyView()
                } else {
                    VStack(alignment: .leading, spacing: 20) {
                        ForEach(viewModel.sections) { section in
                            HistorySectionView(section: section)
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .background(Theme.bg)
        .task {
            await viewModel.loadHistory()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("History").font(.largeTitle.bold())
            Text("Your past quiz attempts.")
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
                Image(systemName: "questionmark.circle")
                    .font(.title3)
                    .foregroundStyle(entry.tint)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("\(entry.subject) · Quiz")
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

private struct HistoryEmptyView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("No quiz attempts yet.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

private struct HistoryErrorView: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Retry", action: onRetry)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Theme.dark)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

#Preview {
    RootView()
}
