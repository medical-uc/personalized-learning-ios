//
//  SubjectsAPI.swift
//  personalized-medical-learning-ios
//

import Foundation

extension APIClient {
    func listTopics() async throws -> [String] {
        let response: TopicListResponse = try await get(path: "quiz/topics")
        return response.topics
    }

    func listSubjects() async throws -> [SubjectOut] {
        guard let token = SessionManager.token else {
            throw APIError.server("You must be signed in to view subjects.")
        }
        let response: SubjectListResponse = try await get(path: "quiz/subjects", token: token)
        return response.subjects
    }
}
