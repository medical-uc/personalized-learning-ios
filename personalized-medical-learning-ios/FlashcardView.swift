//
//  FlashcardView.swift
//  personalized-medical-learning-ios
//

import SwiftUI

struct FlashcardView: View {
    var onBack: () -> Void = {}

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var isFlipped = false
    @State private var showAnswerFirst = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                FlashcardHeaderView(onBack: onBack)
                FlashcardFilterBar(showAnswerFirst: $showAnswerFirst)

                if horizontalSizeClass == .regular {
                    HStack(alignment: .top, spacing: 20) {
                        FlashcardMainCard(isFlipped: $isFlipped)
                            .frame(maxWidth: .infinity)

                        FlashcardSidePanelView()
                            .frame(width: 320)
                    }
                } else {
                    VStack(alignment: .leading, spacing: 20) {
                        FlashcardMainCard(isFlipped: $isFlipped)
                        FlashcardSidePanelView()
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .background(Theme.bg)
    }
}

private struct FlashcardHeaderView: View {
    var onBack: () -> Void

    @State private var isProgressPresented = false

    var body: some View {
        HStack {
            Button(action: onBack) {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.left")
                    Text("Flashcards")
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

private struct FlashcardFilterBar: View {
    @Binding var showAnswerFirst: Bool

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack {
                filters
                Spacer()
                toggle
            }

            VStack(alignment: .leading, spacing: 12) {
                filters
                toggle
            }
        }
    }

    private var filters: some View {
        HStack(spacing: 12) {
            FilterDropdown(title: "Cardiology")
            FilterDropdown(title: "All Topics")
        }
    }

    private var toggle: some View {
        HStack(spacing: 10) {
            Text("Show Answer First")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Toggle("", isOn: $showAnswerFirst)
                .labelsHidden()
                .tint(Theme.dark)
        }
    }
}

private struct FilterDropdown: View {
    let title: String

    var body: some View {
        Button {} label: {
            HStack(spacing: 8) {
                Text(title).font(.subheadline.weight(.medium))
                Image(systemName: "chevron.down").font(.caption2)
            }
            .foregroundStyle(Theme.dark)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

private struct FlashcardMainCard: View {
    @Binding var isFlipped: Bool
    @State private var displayedFace = false

    private var card: Flashcard { FlashcardData.cards[0] }

    private func flip() {
        let duration = 0.3
        withAnimation(.easeInOut(duration: duration)) {
            isFlipped.toggle()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + duration / 2) {
            displayedFace = isFlipped
        }
    }

    var body: some View {
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

                    Text(displayedFace ? card.answer : card.question)
                        .font(.title2.weight(.semibold))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Theme.dark)
                        .padding(.horizontal, 40)
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

            FlashcardRatingBar()
        }
    }
}

private struct FlashcardRatingBar: View {
    var body: some View {
        HStack(spacing: 12) {
            RatingButton(icon: "arrow.counterclockwise", title: "Again", tint: .red)
            RatingButton(icon: "minus.circle", title: "Difficult", tint: .orange)
            RatingButton(icon: "checkmark.circle", title: "Good", tint: .green)
            RatingButton(icon: "chevron.right.2", title: "Easy", tint: .white, isFilled: true)
        }
    }
}

private struct RatingButton: View {
    let icon: String
    let title: String
    let tint: Color
    var isFilled: Bool = false

    var body: some View {
        Button {} label: {
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
