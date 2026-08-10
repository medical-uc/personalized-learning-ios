//
//  FlashcardSetupView.swift
//  personalized-medical-learning-ios
//

import SwiftUI

/// Confirm screen shown before every flashcard session — no topic picker (unlike
/// QuizSetupView) since the session's card selection is fully automatic: due
/// reviews first, then remaining cards filled in weakest-topic-first. This screen
/// just previews what that session will contain and lets the student begin it.
struct FlashcardSetupView: View {
    var onBegin: () -> Void = {}

    @StateObject private var viewModel = FlashcardSetupViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Flashcard Session")
                        .font(.largeTitle.bold())
                        .foregroundStyle(Theme.dark)
                    Text("Review cards due today, prioritized by your weakest topics.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 24)

                if viewModel.isLoading {
                    ProgressView("Loading…")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 60)
                } else if let errorMessage = viewModel.errorMessage {
                    VStack(spacing: 16) {
                        Text(errorMessage)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        Button("Retry") {
                            Task { await viewModel.loadPreview() }
                        }
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Theme.dark)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 60)
                } else if let preview = viewModel.preview {
                    SessionPreviewCard(preview: preview, onBegin: onBegin)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .background(Theme.bg)
        .task {
            await viewModel.loadPreview()
        }
    }
}

private struct SessionPreviewCard: View {
    let preview: FlashcardSessionPreview
    var onBegin: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 0) {
                PreviewStatTile(icon: "clock.badge.exclamationmark", tint: .orange, value: "\(preview.dueCount)", label: "Due Now")
                PreviewStatTile(icon: "square.stack.3d.up.fill", tint: Theme.dark, value: "\(preview.totalCount)", label: "Total Cards")
                if let weakestTopic = preview.weakestTopic {
                    PreviewStatTile(icon: "target", tint: .red, value: "\(weakestTopic.percent)%", label: "Weakest")
                }
            }
            .padding(.vertical, 4)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.black.opacity(0.08)))

            if let weakestTopic = preview.weakestTopic {
                HStack(spacing: 12) {
                    ZStack {
                        Circle().fill(weakestTopic.tint.opacity(0.15)).frame(width: 36, height: 36)
                        Image(systemName: "exclamationmark.triangle.fill").font(.subheadline).foregroundStyle(weakestTopic.tint)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Focus Area").font(.caption).foregroundStyle(.secondary)
                        Text(weakestTopic.topicName).font(.subheadline.bold()).foregroundStyle(Theme.dark)
                    }
                    Spacer()
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Theme.bg)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }

            Text(preview.dueCount > 0
                 ? "Due cards come first, then the rest ordered by what needs the most work."
                 : "Nothing's due right now — you'll review cards ordered by what needs the most work.")
                .font(.caption)
                .foregroundStyle(.secondary)

            Button(action: onBegin) {
                HStack(spacing: 6) {
                    Text("Begin Session")
                    Image(systemName: "chevron.right")
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Theme.dark)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
            .disabled(preview.totalCount == 0)
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

private struct PreviewStatTile: View {
    let icon: String
    let tint: Color
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle().fill(tint.opacity(0.15)).frame(width: 44, height: 44)
                Image(systemName: icon).foregroundStyle(tint)
            }
            Text(value).font(.title3.bold()).foregroundStyle(Theme.dark)
            Text(label).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }
}

#Preview {
    FlashcardSetupView()
}
