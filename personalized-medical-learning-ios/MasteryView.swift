//
//  MasteryView.swift
//  personalized-medical-learning-ios
//

import SwiftUI

struct MasteryView: View {
    var onBack: () -> Void = {}

    @StateObject private var viewModel = MasteryViewModel()
    @State private var showInfo = false
    @State private var selectedEntry: MasteryEntry?

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
        .sheet(item: $selectedEntry) { entry in
            MasteryDetailView(entry: entry)
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
                    MasteryRow(entry: entry) {
                        selectedEntry = entry
                    }
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Text("Knowledge Level").font(.largeTitle.bold())
                Button(action: { showInfo = true }) {
                    Image(systemName: "info.circle")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .popover(isPresented: $showInfo) {
                    MasteryInfoView()
                }
            }
            Text("Areas to focus on first, based on your quiz performance.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 24)
    }
}

private struct MasteryInfoView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("How this score works")
                .font(.headline)
                .foregroundStyle(Theme.dark)

            Text("This is an estimate of how well you actually know a topic — not just your last quiz grade.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 10) {
                InfoBullet(text: "It accounts for lucky guesses, so guessing right doesn't inflate your score.")
                InfoBullet(text: "It accounts for careless mistakes, so one slip doesn't tank a topic you know well.")
                InfoBullet(text: "It updates a little after every question you answer, correct or not.")
            }

            Text("Lower percentages surface first so you know what to practice next.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(20)
        .frame(width: 320)
    }
}

private struct InfoBullet: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(Theme.dark.opacity(0.5))
                .frame(width: 5, height: 5)
                .padding(.top, 6)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(Theme.dark)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct MasteryRow: View {
    let entry: MasteryEntry
    var onTap: () -> Void = {}

    var body: some View {
        Button(action: onTap) {
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
                        .foregroundStyle(Theme.dark)
                        .lineLimit(2)
                    Text(entry.subjectName)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 0)

                Text("\(entry.percent)%")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(entry.tint)

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
        .buttonStyle(.plain)
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

private struct MasteryDetailView: View {
    let entry: MasteryEntry
    @Environment(\.dismiss) private var dismiss

    private var lastPracticed: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: entry.updatedAt, relativeTo: Date())
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(spacing: 16) {
                        ZStack {
                            Circle().fill(entry.tint.opacity(0.12)).frame(width: 96, height: 96)
                            Text("\(entry.percent)%")
                                .font(.title.bold())
                                .foregroundStyle(entry.tint)
                        }

                        VStack(spacing: 4) {
                            Text(entry.topicName)
                                .font(.headline)
                                .foregroundStyle(Theme.dark)
                                .multilineTextAlignment(.center)
                            Text(entry.subjectName)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Text(entry.statusLabel)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(entry.tint)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(entry.tint.opacity(0.12))
                            .clipShape(Capsule())
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 12)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Why this number")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Theme.dark)
                        Text(explanation)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(16)
                    .background(Theme.mint.opacity(0.4))
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    HStack(spacing: 8) {
                        Image(systemName: "clock").foregroundStyle(.secondary)
                        Text("Last practiced \(lastPracticed)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(20)
            }
            .background(Theme.bg)
            .navigationTitle("Topic Breakdown")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", action: { dismiss() })
                }
            }
        }
    }

    private var explanation: String {
        switch entry.statusLabel {
        case "Strong":
            return "You're consistently answering \(entry.topicName) questions correctly, even accounting for lucky guesses. Keep it up with occasional review."
        case "Developing":
            return "You're getting some \(entry.topicName) questions right, but the estimate isn't confident yet — a few more attempts will sharpen this score. A bit more practice here will help."
        default:
            return "Recent attempts on \(entry.topicName) suggest this isn't solid yet. This score already discounts lucky guesses, so it reflects real gaps — a good candidate for focused practice."
        }
    }
}

#Preview {
    RootView()
}
