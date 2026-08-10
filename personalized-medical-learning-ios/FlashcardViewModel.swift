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

    private let client: APIClient
    private var sessionId: String?
    private var hasEnded = false

    init(client: APIClient = .shared) {
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
        hasEnded = false

        do {
            async let cardsTask = client.getAllCards()
            async let sessionTask = client.startFlashcardSession()
            let (out, session) = try await (cardsTask, sessionTask)
            let byUid = Dictionary(uniqueKeysWithValues: out.map { ($0.uid, $0) })
            let ordered = session.cardUids.compactMap { byUid[$0] }
            cards = ordered
                .map(Flashcard.init(cardOut:))
                .sorted { BKTStore.pKnow(for: $0.topicPath) < BKTStore.pKnow(for: $1.topicPath) }
            sessionId = session.sessionId
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
            cards[index].explanation = result.explanation
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
                if index == cards.count - 1 {
                    await finishSession()
                }
            } catch {
                cards[index].rating = nil
                errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
            }
        }
    }

    func finishSession() async {
        guard let sessionId, !hasEnded else { return }
        hasEnded = true
        do {
            _ = try await client.endFlashcardSession(sessionId: sessionId)
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
        }
    }

    func cancelSession() {
        guard let sessionId, !hasEnded else { return }
        hasEnded = true
        Task { _ = try? await client.cancelFlashcardSession(sessionId: sessionId) }
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
