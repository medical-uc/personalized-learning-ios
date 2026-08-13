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
/// p_slip/p_guess are confidence-conditional (see the notebook's "BKT baseline
/// (confidence-conditional emissions)" section): a confident-wrong answer is trusted as
/// real evidence of a misconception, while a guessing-correct answer is discounted as a
/// likely lucky guess. p_init/p_transit stay flat global scalars.
///
/// Keyed by topic_path — topicTag.joined(separator: " > "), the same delimiter and
/// leaf-topic granularity MasteryEntry.topicPath already uses, so entries line up with
/// zero translation. Persisted in UserDefaults as a single [String: Double] dict,
/// mirroring SessionManager's enum-namespace pattern over a system store — no app-wide
/// persistence layer exists yet, and 56 topics x 8 bytes doesn't warrant one.
/// One graded attempt's effect on p_know for a topic — the raw material for "why this
/// level" explainability. Kept separate from the pKnow/updatedAt dicts since it's a log,
/// not current state.
struct BKTAttemptRecord: Codable, Identifiable {
    let id: UUID
    let correct: Bool
    let confidence: ConfidenceLevel
    let pKnowBefore: Double
    let pKnowAfter: Double
    let timestamp: Date

    var delta: Double { pKnowAfter - pKnowBefore }
}

extension ConfidenceLevel: Codable {}

enum BKTStore {
    private static let pKnowKey = "bkt.pKnow"
    private static let updatedAtKey = "bkt.updatedAt"
    private static let historyKey = "bkt.history"

    /// Per-topic attempt log is capped so UserDefaults doesn't grow unbounded over a
    /// student's lifetime — only recent attempts are useful for "why this level" anyway,
    /// older evidence is already folded into p_know itself.
    private static let maxHistoryPerTopic = 20

    static let pInit = 0.30
    static let pTransit = 0.10

    static let pSlip: [ConfidenceLevel: Double] = [
        .confident: 0.05,
        .unsure: 0.10,
        .guessing: 0.30,
    ]
    static let pGuess: [ConfidenceLevel: Double] = [
        .confident: 0.10,
        .unsure: 0.25,
        .guessing: 0.50,
    ]

    private static var pKnowByTopic: [String: Double] {
        get { UserDefaults.standard.dictionary(forKey: pKnowKey) as? [String: Double] ?? [:] }
        set { UserDefaults.standard.set(newValue, forKey: pKnowKey) }
    }

    private static var updatedAtByTopic: [String: Double] {
        get { UserDefaults.standard.dictionary(forKey: updatedAtKey) as? [String: Double] ?? [:] }
        set { UserDefaults.standard.set(newValue, forKey: updatedAtKey) }
    }

    /// Codable dict round-tripped through Data since UserDefaults has no native support
    /// for arrays of structs the way it does for the flat [String: Double] state above.
    private static var historyByTopic: [String: [BKTAttemptRecord]] {
        get {
            guard let data = UserDefaults.standard.data(forKey: historyKey) else { return [:] }
            return (try? JSONDecoder().decode([String: [BKTAttemptRecord]].self, from: data)) ?? [:]
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            UserDefaults.standard.set(data, forKey: historyKey)
        }
    }

    /// This topic's recent attempts, most recent first — the evidence trail behind its
    /// current p_know. Empty for a topic with no recorded attempts yet.
    static func history(for topicPath: String) -> [BKTAttemptRecord] {
        (historyByTopic[topicPath] ?? []).reversed()
    }

    /// Current mastery estimate for a topic, or pInit if this pair has no history yet —
    /// same cold-start fallback src/quiz/attempts.py's _CURRENT_MASTERY_QUERY used.
    static func pKnow(for topicPath: String) -> Double {
        pKnowByTopic[topicPath] ?? pInit
    }

    static func updatedAt(for topicPath: String) -> Date? {
        updatedAtByTopic[topicPath].map { Date(timeIntervalSince1970: $0) }
    }

    /// Pure Bayes update + learning-transition step, no persistence. Ported from
    /// bkt_update() in the (now-removed) src/quiz/mastery.py — see that module's
    /// history for the original. Exposed so UI can preview "what if" outcomes
    /// without recording an attempt.
    ///
    /// confidence defaults to .unsure (the middle row) for previews that don't have a
    /// real confidence to hand — same fallback the notebook's bkt_predict_proba()
    /// docstring calls out for live/next-step use.
    static func simulate(current: Double, correct: Bool, confidence: ConfidenceLevel = .unsure) -> Double {
        let slip = pSlip[confidence]!
        let guess = pGuess[confidence]!
        let numerator = correct ? current * (1 - slip) : current * slip
        let denominator = correct
            ? numerator + (1 - current) * guess
            : numerator + (1 - current) * (1 - guess)
        let posterior = denominator > 0 ? numerator / denominator : current
        return posterior + (1 - posterior) * pTransit
    }

    /// Records one graded attempt for topicPath: Bayes update on correct/incorrect,
    /// then the learning-transition step. confidence is the student's self-reported
    /// certainty for this attempt (see ConfidenceLevel) — it selects which p_slip/p_guess
    /// row applies, so a confident-wrong answer moves p_know down harder than a
    /// guessing-wrong answer, and a guessing-correct answer isn't mistaken for mastery.
    @discardableResult
    static func record(topicPath: String, correct: Bool, confidence: ConfidenceLevel) -> Double {
        let before = pKnow(for: topicPath)
        let next = simulate(current: before, correct: correct, confidence: confidence)

        var byTopic = pKnowByTopic
        byTopic[topicPath] = next
        pKnowByTopic = byTopic

        var byUpdatedAt = updatedAtByTopic
        byUpdatedAt[topicPath] = Date().timeIntervalSince1970
        updatedAtByTopic = byUpdatedAt

        var byHistory = historyByTopic
        var topicHistory = byHistory[topicPath] ?? []
        topicHistory.append(BKTAttemptRecord(
            id: UUID(),
            correct: correct,
            confidence: confidence,
            pKnowBefore: before,
            pKnowAfter: next,
            timestamp: Date()
        ))
        if topicHistory.count > maxHistoryPerTopic {
            topicHistory.removeFirst(topicHistory.count - maxHistoryPerTopic)
        }
        byHistory[topicPath] = topicHistory
        historyByTopic = byHistory

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
