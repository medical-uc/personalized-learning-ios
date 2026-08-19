//
//  FlashcardSidePanelView.swift
//  personalized-medical-learning-ios
//

import SwiftUI

struct FlashcardSidePanelView: View {
    @ObservedObject var viewModel: FlashcardViewModel
    var onEndSession: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if !viewModel.cards.isEmpty {
                Text("Card \(viewModel.currentIndex + 1) of \(viewModel.cards.count)")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
            }
            NavigationCard(viewModel: viewModel)
            EndSessionButton(action: onEndSession)
        }
    }
}

private struct EndSessionButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: "stop.circle")
                Text("End Session")
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.red)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

private struct NavigationCard: View {
    @ObservedObject var viewModel: FlashcardViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Navigation").font(.headline)

            HStack(spacing: 20) {
                Button(action: viewModel.goToPrevious) {
                    Image(systemName: "chevron.left")
                        .frame(width: 36, height: 36)
                        .background(Theme.bg)
                        .clipShape(Circle())
                }
                .disabled(viewModel.currentIndex == 0)

                Text("\(min(viewModel.currentIndex + 1, viewModel.totalCards)) / \(viewModel.totalCards)")
                    .font(.subheadline.weight(.medium))
                    .frame(maxWidth: .infinity, alignment: .center)

                Button(action: viewModel.goToNext) {
                    Image(systemName: "chevron.right")
                        .frame(width: 36, height: 36)
                        .background(Theme.bg)
                        .clipShape(Circle())
                }
                .disabled(viewModel.currentIndex + 1 >= viewModel.totalCards)
            }
            .foregroundStyle(Theme.dark)
        }
        .padding(18)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    ScrollView {
        FlashcardSidePanelView(viewModel: FlashcardViewModel())
            .padding()
            .frame(width: 340)
    }
    .background(Theme.bg)
}
