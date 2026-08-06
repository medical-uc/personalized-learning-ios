//
//  MasteryModels.swift
//  personalized-medical-learning-ios
//

import SwiftUI

struct MasteryEntry: Identifiable {
    let id: String
    let topicPath: String
    let pKnow: Double
    let updatedAt: Date

    var percent: Int { Int((pKnow * 100).rounded()) }

    var tint: Color {
        if pKnow >= 0.7 { return .green }
        if pKnow >= 0.4 { return .orange }
        return .red
    }

    /// Deepest segment of topic_path (e.g. "ENDOCRINOLOGY > Thyroid hormone synthesis" -> "Thyroid hormone synthesis"),
    /// same leaf-vs-subject split the backend's topic_tag chain already encodes.
    var topicName: String {
        topicPath.components(separatedBy: " > ").last ?? topicPath
    }

    var subjectName: String {
        let parts = topicPath.components(separatedBy: " > ")
        return parts.count > 1 ? parts.first ?? topicPath : topicPath
    }
}

extension MasteryEntry {
    init(item: MasteryItem) {
        id = item.topicPath
        topicPath = item.topicPath
        pKnow = item.pKnow
        updatedAt = item.updatedAt
    }
}
