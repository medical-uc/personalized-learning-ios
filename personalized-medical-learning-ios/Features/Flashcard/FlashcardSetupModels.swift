//
//  FlashcardSetupModels.swift
//  personalized-medical-learning-ios
//

import Foundation

/// Pre-session snapshot shown on the confirm screen — due count drives the "N cards
/// due" stat, weakestTopic drives the "Focus: X" stat. Both derived client-side
/// (getDueFlashcards + BKTStore) so the confirm screen never needs its own endpoint.
struct FlashcardSessionPreview {
    let dueCount: Int
    let totalCount: Int
    let weakestTopic: MasteryEntry?
}
