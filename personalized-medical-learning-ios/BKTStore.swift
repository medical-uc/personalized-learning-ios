//
//  BKTStore.swift
//  personalized-medical-learning-ios
//

import Foundation

/// On-device Bayesian Knowledge Tracing — mirrors the update rule in the backend's
/// src/quiz/mastery.py (removed server-side; this is now the only place p_know is
/// computed). Same 2-state HMM, same fixed global params, ported line-for-line so the
/// math never drifts from what was validated in notebooks/knowledge_tracing.ipynb.
///
/// Keyed by topic_path — topicTag.joined(separator: " > "), the same delimiter and
/// leaf-topic granularity MasteryEntry.topicPath already uses, so entries line up with
/// zero translation. Persisted in UserDefaults as a single [String: Double] dict,
/// mirroring SessionManager's enum-namespace pattern over a system store — no app-wide
/// persistence layer exists yet, and 56 topics x 8 bytes doesn't warrant one.
enum BKTStore {
    private static let pKnowKey = "bkt.pKnow"
    private static let updatedAtKey = "bkt.updatedAt"

    private static let pInit = 0.30
    private static let pTransit = 0.10
    private static let pSlip = 0.10
    private static let pGuess = 0.25

    private static var pKnowByTopic: [String: Double] {
        get { UserDefaults.standard.dictionary(forKey: pKnowKey) as? [String: Double] ?? [:] }
        set { UserDefaults.standard.set(newValue, forKey: pKnowKey) }
    }

    private static var updatedAtByTopic: [String: Double] {
        get { UserDefaults.standard.dictionary(forKey: updatedAtKey) as? [String: Double] ?? [:] }
        set { UserDefaults.standard.set(newValue, forKey: updatedAtKey) }
    }

    /// Current mastery estimate for a topic, or pInit if this pair has no history yet —
    /// same cold-start fallback src/quiz/attempts.py's _CURRENT_MASTERY_QUERY used.
    static func pKnow(for topicPath: String) -> Double {
        pKnowByTopic[topicPath] ?? pInit
    }

    static func updatedAt(for topicPath: String) -> Date? {
        updatedAtByTopic[topicPath].map { Date(timeIntervalSince1970: $0) }
    }

    /// Records one graded attempt for topicPath: Bayes update on correct/incorrect,
    /// then the learning-transition step. Ported from bkt_update() in the (now-removed)
    /// src/quiz/mastery.py — see that module's history for the original.
    @discardableResult
    static func record(topicPath: String, correct: Bool) -> Double {
        let current = pKnow(for: topicPath)
        let numerator = correct ? current * (1 - pSlip) : current * pSlip
        let denominator = correct
            ? numerator + (1 - current) * pGuess
            : numerator + (1 - current) * (1 - pGuess)
        let posterior = denominator > 0 ? numerator / denominator : current
        let next = posterior + (1 - posterior) * pTransit

        var byTopic = pKnowByTopic
        byTopic[topicPath] = next
        pKnowByTopic = byTopic

        var byUpdatedAt = updatedAtByTopic
        byUpdatedAt[topicPath] = Date().timeIntervalSince1970
        updatedAtByTopic = byUpdatedAt

        return next
    }

    /// All topics with at least one recorded attempt, weakest (lowest pKnow) first —
    /// mirrors mastery_for_student()'s ORDER BY p_know ASC.
    static func allEntries() -> [MasteryEntry] {
        pKnowByTopic
            .map { topicPath, pKnow in
                MasteryEntry(
                    id: topicPath,
                    topicPath: topicPath,
                    pKnow: pKnow,
                    updatedAt: updatedAt(for: topicPath) ?? Date()
                )
            }
            .sorted { $0.pKnow < $1.pKnow }
    }
}
