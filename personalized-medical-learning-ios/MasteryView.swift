//
//  MasteryView.swift
//  personalized-medical-learning-ios
//

import SwiftUI

struct MasteryView: View {
    var onBack: () -> Void = {}

    @StateObject private var viewModel = MasteryViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header
                content
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .background(Theme.bg)
        .task {
            await viewModel.loadMastery()
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            Text("Loading mastery…")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 60)
        } else if let errorMessage = viewModel.errorMessage, viewModel.entries.isEmpty {
            MasteryErrorView(message: errorMessage) {
                Task { await viewModel.loadMastery() }
            }
        } else if viewModel.entries.isEmpty {
            MasteryEmptyView()
        } else {
            VStack(spacing: 12) {
                ForEach(viewModel.entries) { entry in
                    MasteryRow(entry: entry)
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Mastery").font(.largeTitle.bold())
            Text("Areas to focus on first, based on your quiz performance.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 24)
    }
}

private struct MasteryRow: View {
    let entry: MasteryEntry

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(entry.tint.opacity(0.12))
                    .frame(width: 48, height: 48)
                Image(systemName: "chart.bar.fill")
                    .font(.title3)
                    .foregroundStyle(entry.tint)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(entry.topicName)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(2)
                Text(entry.subjectName)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)

            Text("\(entry.percent)%")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(entry.tint)
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

private struct MasteryEmptyView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar")
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

private struct MasteryErrorView: View {
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
