//
//  SessionManager.swift
//  personalized-medical-learning-ios
//

import Foundation

enum SessionManager {
    private static let tokenKey = "session.token"
    private static let studentIdKey = "session.studentId"
    private static let expiresAtKey = "session.expiresAt"

    static var token: String? {
        KeychainStore.get(forKey: tokenKey)
    }

    static var studentId: String? {
        KeychainStore.get(forKey: studentIdKey)
    }

    private static var expiresAt: Date? {
        guard let raw = KeychainStore.get(forKey: expiresAtKey) else { return nil }
        return ISO8601DateFormatter().date(from: raw)
    }

    static var isValid: Bool {
        guard token != nil, let expiresAt else { return false }
        return expiresAt > Date()
    }

    static func start(studentId: String, token: String, expiresAt: Date) {
        KeychainStore.set(studentId, forKey: studentIdKey)
        KeychainStore.set(token, forKey: tokenKey)
        KeychainStore.set(ISO8601DateFormatter().string(from: expiresAt), forKey: expiresAtKey)
    }

    static func end() {
        KeychainStore.remove(forKey: studentIdKey)
        KeychainStore.remove(forKey: tokenKey)
        KeychainStore.remove(forKey: expiresAtKey)
    }
}
