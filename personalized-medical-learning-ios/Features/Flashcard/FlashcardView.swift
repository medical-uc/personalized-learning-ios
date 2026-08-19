//
//  FlashcardView.swift
//  personalized-medical-learning-ios
//

import SwiftUI

struct FlashcardView: View {
    var topicPath: String?
    var onBack: () -> Void = {}
    var onProgressChange: (Bool) -> Void = { _ in }

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @StateObject private var viewModel = FlashcardViewModel()
    @State private var isFlipped = false
    @State private var showExitConfirm = false

    private func requestExit() {
        if viewModel.hasUnsavedProgress {
            showExitConfirm = true
        } else {
            onBack()
        }
    }

    private func confirmExit() {
        onProgressChange(false)
        onBack()
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                FlashcardHeaderView(onBack: requestExit)

                if viewModel.isLoading {
                    ProgressView("Loading cards…")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 60)
                } else if let errorMessage = viewModel.errorMessage, viewModel.cards.isEmpty {
                    FlashcardErrorView(message: errorMessage) {
                        Task { await viewModel.loadCards() }
                    }
                } else if horizontalSizeClass == .regular {
                    HStack(alignment: .top, spacing: 20) {
                        FlashcardMainCard(isFlipped: $isFlipped, viewModel: viewModel)
                            .frame(maxWidth: .infinity)

                        FlashcardSidePanelView(viewModel: viewModel)
                            .frame(width: 320)
                    }
                } else {
                    VStack(alignment: .leading, spacing: 20) {
                        FlashcardMainCard(isFlipped: $isFlipped, viewModel: viewModel)
                        FlashcardSidePanelView(viewModel: viewModel)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .background(Theme.bg)
        .alert(
            "Leave flashcards?",
            isPresented: $showExitConfirm
        ) {
            Button("Leave", role: .destructive, action: confirmExit)
            Button("Keep Going", role: .cancel) {}
        } message: {
            Text("Your progress on this session will be lost if you leave now.")
        }
        .task {
            await viewModel.loadCards(topicPath: topicPath)
            onProgressChange(viewModel.hasUnsavedProgress)
        }
        .onChange(of: viewModel.currentIndex) {
            isFlipped = false
        }
        .onChange(of: viewModel.hasUnsavedProgress) {
            onProgressChange(viewModel.hasUnsavedProgress)
        }
        .onDisappear {
            viewModel.cancelSession()
        }
    }
}

private struct FlashcardErrorView: View {
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

private struct FlashcardHeaderView: View {
    var onBack: () -> Void = {}

    @State private var isProgressPresented = false

    var body: some View {
        HStack {
            Button(action: onBack) {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.left")
                    Text("Back to Dashboard")
                }
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Theme.dark)
            }

            Spacer()

            Button {
                isProgressPresented = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "chart.pie")
                    Text("Progress")
                }
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Theme.dark)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .popover(isPresented: $isProgressPresented) {
                FlashcardProgressPopoverContent()
            }

            Button {} label: {
                Image(systemName: "bookmark")
                    .foregroundStyle(Theme.dark)
                    .frame(width: 40, height: 40)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            Button {} label: {
                Image(systemName: "ellipsis")
                    .foregroundStyle(Theme.dark)
                    .frame(width: 40, height: 40)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(.top, 24)
    }
}

private struct FlashcardMainCard: View {
    @Binding var isFlipped: Bool
    @ObservedObject var viewModel: FlashcardViewModel
    @State private var displayedFace = false

    private func flip() {
        guard let card = viewModel.currentCard else { return }
        let duration = 0.3
        withAnimation(.easeInOut(duration: duration)) {
            isFlipped.toggle()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + duration / 2) {
            displayedFace = isFlipped
        }
        if card.back == nil {
            Task { await viewModel.revealCurrentCard() }
        }
    }

    var body: some View {
        if let card = viewModel.currentCard {
            VStack(alignment: .leading, spacing: 20) {
                VStack(spacing: 0) {
                    HStack {
                        Label(displayedFace ? "Back" : "Front", systemImage: "questionmark.circle")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Theme.dark)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Theme.bg)
                            .clipShape(RoundedRectangle(cornerRadius: 10))

                        Spacer()

                        Button {} label: {
                            Image(systemName: "star")
                                .foregroundStyle(Theme.dark)
                        }
                    }
                    .padding(24)

                    ZStack {
                        Image(systemName: "heart.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 220, height: 220)
                            .foregroundStyle(Theme.bg)

                        if displayedFace && viewModel.isRevealing {
                            ProgressView()
                        } else {
                            Text(displayedFace ? (card.explanation ?? "") : card.front)
                                .font(.title2.weight(.semibold))
                                .multilineTextAlignment(.center)
                                .foregroundStyle(Theme.dark)
                                .padding(.horizontal, 40)
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 320)
                    .padding(.bottom, 28)
                }
                .background(displayedFace ? Theme.mint.opacity(0.4) : Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .rotation3DEffect(
                    .degrees(isFlipped ? 180 : 0),
                    axis: (x: 0, y: 1, z: 0),
                    perspective: 0.4
                )
                .rotation3DEffect(
                    .degrees(displayedFace ? 180 : 0),
                    axis: (x: 0, y: 1, z: 0)
                )
                .onTapGesture { flip() }

                HStack(spacing: 6) {
                    Image(systemName: "lightbulb")
                    Text("Don't know the answer?")
                        .foregroundStyle(.secondary)
                    Text("Tap to flip the card")
                        .foregroundStyle(Theme.dark)
                        .fontWeight(.medium)
                }
                .font(.subheadline)
                .foregroundStyle(Theme.dark)
                .frame(maxWidth: .infinity, alignment: .center)
                .onTapGesture { flip() }

                FlashcardRatingBar(viewModel: viewModel)
            }
            .onChange(of: viewModel.currentIndex) {
                displayedFace = false
            }
        }
    }
}

private struct FlashcardRatingBar: View {
    @ObservedObject var viewModel: FlashcardViewModel

    private var selectedRating: FlashcardRating? {
        viewModel.currentCard?.rating
    }

    var body: some View {
        HStack(spacing: 12) {
            RatingButton(icon: "arrow.counterclockwise", title: "Again", tint: .red, isFilled: selectedRating == .again) {
                viewModel.rateCurrentCard(.again)
            }
            RatingButton(icon: "minus.circle", title: "Hard", tint: .orange, isFilled: selectedRating == .hard) {
                viewModel.rateCurrentCard(.hard)
            }
            RatingButton(icon: "checkmark.circle", title: "Good", tint: .green, isFilled: selectedRating == .good) {
                viewModel.rateCurrentCard(.good)
            }
            RatingButton(icon: "chevron.right.2", title: "Easy", tint: .green, isFilled: selectedRating == .easy) {
                viewModel.rateCurrentCard(.easy)
            }
        }
        .disabled(selectedRating != nil)
    }
}

private struct RatingButton: View {
    let icon: String
    let title: String
    let tint: Color
    var isFilled: Bool = false
    var onTap: () -> Void = {}

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(systemName: icon).font(.title3)
                Text(title).font(.subheadline.weight(.semibold))
            }
            .foregroundStyle(isFilled ? .white : tint)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isFilled ? Theme.dark : Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

#Preview {
    RootView()
}
