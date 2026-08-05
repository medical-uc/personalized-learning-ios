//
//  FlashcardViewModel.swift
//  personalized-medical-learning-ios
//

import Foundation
import Combine

@MainActor
final class FlashcardViewModel: ObservableObject {
    @Published private(set) var cards: [Flashcard] = []
    @Published private(set) var currentIndex = 0
    @Published private(set) var isLoading = false
    @Published private(set) var isRevealing = false
    @Published var errorMessage: String?

    let topicPath: String
    private let client: APIClient

    init(topicPath: String, client: APIClient = .shared) {
        self.topicPath = topicPath
        self.client = client
    }

    var currentCard: Flashcard? {
        cards.indices.contains(currentIndex) ? cards[currentIndex] : nil
    }

    var totalCards: Int { cards.count }

    func loadCards() async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            let out = try await client.getCards(topicPath: topicPath)
            cards = out.map(Flashcard.init(cardOut:))
            currentIndex = 0
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
        }
    }

    func revealCurrentCard() async {
        guard let card = currentCard, card.back == nil else { return }
        isRevealing = true
        defer { isRevealing = false }

        do {
            let result = try await client.revealCard(uid: card.uid)
            guard let index = cards.firstIndex(where: { $0.uid == card.uid }) else { return }
            cards[index].back = result.back
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
        }
    }

    func rateCurrentCard(_ rating: FlashcardRating) {
        guard let card = currentCard, card.rating == nil else { return }
        guard let index = cards.firstIndex(where: { $0.uid == card.uid }) else { return }
        cards[index].rating = rating

        Task {
            do {
                _ = try await client.logReview(uid: card.uid, rating: rating)
            } catch {
                cards[index].rating = nil
                errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
            }
        }
    }

    func goToNext() {
        guard currentIndex + 1 < cards.count else { return }
        currentIndex += 1
    }

    func goToPrevious() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
    }
}
