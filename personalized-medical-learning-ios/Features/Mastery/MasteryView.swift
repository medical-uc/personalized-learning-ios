//
//  MasteryView.swift
//  personalized-medical-learning-ios
//

import SwiftUI

struct MasteryView: View {
    var onBack: () -> Void = {}

    @StateObject private var viewModel = MasteryViewModel()
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
            Text("Knowledge Level").font(.largeTitle.bold())
            Text("Areas to focus on first, based on your quiz performance.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 24)
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

                Text(entry.statusLabel)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(entry.tint)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(entry.tint.opacity(0.12))
                    .clipShape(Capsule())

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

struct MasteryDetailView: View {
    let entry: MasteryEntry
    @Environment(\.dismiss) private var dismiss
    @State private var streakConfidence: ConfidenceLevel = .unsure

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
                            Image(systemName: "chart.bar.fill")
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
                        Text("Why this level")
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

                    attemptHistory

                    bktBreakdown

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

    /// Chains simulate() n times so each row reflects n *consecutive* answers of the
    /// same kind, not n independent single-attempt previews — that's the "how many
    /// questions to get there" the tiles were missing. confidence is driven by the
    /// picker below so a student can see e.g. "5 confident-correct in a row" vs.
    /// "5 guessing-correct in a row" move p_know very differently.
    private func streak(correct: Bool, count: Int) -> [MasteryLevel] {
        var results: [MasteryLevel] = []
        var current = entry.pKnow
        for _ in 0..<count {
            current = BKTStore.simulate(current: current, correct: correct, confidence: streakConfidence)
            results.append(MasteryLevel(pKnow: current))
        }
        return results
    }

    private var correctStreak: [MasteryLevel] { streak(correct: true, count: 5) }
    private var incorrectStreak: [MasteryLevel] { streak(correct: false, count: 5) }

    private var recentHistory: [BKTAttemptRecord] { BKTStore.history(for: entry.topicPath) }

    /// Real evidence trail for this topic, most recent first — each row is an actual
    /// graded attempt, not a simulation. Empty state covers a topic with a p_know from
    /// before this log existed, or genuinely zero attempts (cold-start default).
    private var attemptHistory: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Recent attempts")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.dark)

            if recentHistory.isEmpty {
                Text("No attempt history recorded for this topic yet.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                VStack(spacing: 8) {
                    ForEach(recentHistory) { record in
                        AttemptHistoryRow(record: record)
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.black.opacity(0.06)))
    }

    private var bktBreakdown: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("How this score is calculated")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.dark)

            Text("Every topic starts at Needs Work. Each time you answer a question, your level moves depending on whether you got it right — and on how confident you said you were. A confident right answer counts as strong evidence you know it; a confident wrong answer counts as a real gap, not a slip. A guess barely moves the needle either way, since it's close to a coin flip regardless of outcome.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 6) {
                ConfidenceRuleRow(level: .confident, note: "trusted as real evidence, right or wrong")
                ConfidenceRuleRow(level: .unsure, note: "moderate evidence either way")
                ConfidenceRuleRow(level: .guessing, note: "close to a coin flip — barely moves your score")
            }

            Divider()

            Text("Preview: answering with this confidence")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Picker("Confidence", selection: $streakConfidence) {
                ForEach(ConfidenceLevel.allCases) { level in
                    Text(level.rawValue).tag(level)
                }
            }
            .pickerStyle(.segmented)

            Text("If your next questions go correct")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            StreakRow(values: correctStreak)

            Text("If your next questions go incorrect")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            StreakRow(values: incorrectStreak)

            Text("Each column assumes you keep answering the same way, with the confidence selected above, starting from your current level.")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.black.opacity(0.06)))
    }
}

private struct ConfidenceRuleRow: View {
    let level: ConfidenceLevel
    let note: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: level.icon)
                .font(.caption)
                .foregroundStyle(level.tint)
                .frame(width: 16)
            Text(level.rawValue)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Theme.dark)
            Text("— \(note)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

private struct AttemptHistoryRow: View {
    let record: BKTAttemptRecord

    private var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: record.timestamp, relativeTo: Date())
    }

    private var deltaLabel: String {
        let percent = Int((record.delta * 100).rounded())
        return percent >= 0 ? "+\(percent)%" : "\(percent)%"
    }

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: record.correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundStyle(record.correct ? .green : .red)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Image(systemName: record.confidence.icon)
                        .font(.caption2)
                        .foregroundStyle(record.confidence.tint)
                    Text(record.confidence.rawValue)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Theme.dark)
                }
                Text(timeAgo)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(deltaLabel)
                .font(.caption.weight(.semibold))
                .foregroundStyle(record.delta >= 0 ? .green : .red)
        }
    }
}

private struct StreakRow: View {
    let values: [MasteryLevel]

    var body: some View {
        HStack(spacing: 8) {
            ForEach(Array(values.enumerated()), id: \.offset) { index, value in
                VStack(spacing: 4) {
                    Text("\(index + 1)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(value.label)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(value.tint)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(value.tint.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }
}

#Preview {
    RootView()
}
