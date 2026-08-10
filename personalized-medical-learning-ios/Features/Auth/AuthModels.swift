//
//  AuthModels.swift
//  personalized-medical-learning-ios
//

import Foundation

struct StudentRegisterRequest: Encodable {
    let fullName: String
    let studentNumber: String
    let academicYear: Int

    enum CodingKeys: String, CodingKey {
        case fullName = "full_name"
        case studentNumber = "student_number"
        case academicYear = "academic_year"
    }
}

struct StudentRegisterResponse: Decodable {
    let studentId: String
    let token: String
    let expiresAt: Date

    enum CodingKeys: String, CodingKey {
        case studentId = "student_id"
        case token
        case expiresAt = "expires_at"
    }
}

struct StudentLoginRequest: Encodable {
    let studentNumber: String

    enum CodingKeys: String, CodingKey {
        case studentNumber = "student_number"
    }
}

struct SessionResponse: Decodable {
    let studentId: String
    let token: String
    let expiresAt: Date

    enum CodingKeys: String, CodingKey {
        case studentId = "student_id"
        case token
        case expiresAt = "expires_at"
    }
}

struct SessionCheckResponse: Decodable {
    let authenticated: Bool
    let studentId: String

    enum CodingKeys: String, CodingKey {
        case authenticated
        case studentId = "student_id"
    }
}
